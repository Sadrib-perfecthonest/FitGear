import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../constants/firebase_constants.dart';
import 'package:uuid/uuid.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Get cart items for user
  Stream<List<CartItem>> getCartItems(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .collection(FirebaseConstants.cartCollection)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItem.fromMap(doc.data()))
            .toList());
  }

  // Add item to cart
  Future<void> addToCart({
    required String userId,
    required Product product,
    int quantity = 1,
  }) async {
    try {
      final cartRef = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.cartCollection);

      // Check if item already exists in cart
      final existingItemQuery = await cartRef
          .where('productId', isEqualTo: product.id)
          .get();

      if (existingItemQuery.docs.isNotEmpty) {
        // Update quantity if item exists
        final existingItem = CartItem.fromMap(existingItemQuery.docs.first.data());
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
        
        await cartRef.doc(existingItem.id).update(updatedItem.toMap());
      } else {
        // Add new item
        final cartItem = CartItem(
          id: _uuid.v4(),
          productId: product.id,
          productName: product.name,
          productImage: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
          price: product.price,
          quantity: quantity,
          addedAt: DateTime.now(),
        );

        await cartRef.doc(cartItem.id).set(cartItem.toMap());
      }
    } catch (e) {
      throw Exception('Failed to add to cart: ${e.toString()}');
    }
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId: userId, cartItemId: cartItemId);
        return;
      }

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.cartCollection)
          .doc(cartItemId)
          .update({'quantity': quantity});
    } catch (e) {
      throw Exception('Failed to update cart item: ${e.toString()}');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart({
    required String userId,
    required String cartItemId,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.cartCollection)
          .doc(cartItemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }

  // Clear cart
  Future<void> clearCart(String userId) async {
    try {
      final cartRef = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.cartCollection);

      final snapshot = await cartRef.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }

  // Get cart total
  Future<double> getCartTotal(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .collection(FirebaseConstants.cartCollection)
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final cartItem = CartItem.fromMap(doc.data());
        total += cartItem.totalPrice;
      }

      return total;
    } catch (e) {
      throw Exception('Failed to calculate cart total: ${e.toString()}');
    }
  }
}
