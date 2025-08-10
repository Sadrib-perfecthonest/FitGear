import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_models;
import '../models/cart_item.dart';
import '../constants/firebase_constants.dart';
import 'cart_service.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartService _cartService = CartService();
  final Uuid _uuid = const Uuid();

  // Create order from cart
  Future<String> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required String shippingAddress,
    String? notes,
  }) async {
    try {
      final double totalAmount = cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final order = app_models.Order(
        id: _uuid.v4(),
        userId: userId,
        items: cartItems,
        totalAmount: totalAmount,
        status: app_models.OrderStatus.pending,
        shippingAddress: shippingAddress,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add order to Firestore
      await _firestore
          .collection(FirebaseConstants.ordersCollection)
          .doc(order.id)
          .set(order.toMap());

      // Clear cart after successful order
      await _cartService.clearCart(userId);

      return order.id;
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Get user orders
  Stream<List<app_models.Order>> getUserOrders(String userId) {
    return _firestore
        .collection(FirebaseConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => app_models.Order.fromMap(doc.data()))
            .toList());
  }

  // Get order by ID
  Future<app_models.Order?> getOrderById(String orderId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstants.ordersCollection)
          .doc(orderId)
          .get();

      if (doc.exists) {
        return app_models.Order.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, app_models.OrderStatus status) async {
    try {
      await _firestore
          .collection(FirebaseConstants.ordersCollection)
          .doc(orderId)
          .update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, app_models.OrderStatus.cancelled);
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  // Add dummy orders for testing
  Future<void> addDummyOrders(String userId) async {
    try {
      final List<app_models.Order> dummyOrders = [
        app_models.Order(
          id: 'order_001',
          userId: userId,
          items: [
            CartItem(
              id: 'cart_001',
              productId: 'dumbbell_set_1',
              productName: 'Adjustable Dumbbell Set',
              price: 299.99,
              quantity: 1,
              productImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
              addedAt: DateTime.now().subtract(const Duration(days: 15)),
            ),
            CartItem(
              id: 'cart_002',
              productId: 'yoga_mat_1',
              productName: 'Premium Yoga Mat',
              price: 39.99,
              quantity: 2,
              productImage: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500',
              addedAt: DateTime.now().subtract(const Duration(days: 15)),
            ),
          ],
          totalAmount: 379.97,
          status: app_models.OrderStatus.delivered,
          shippingAddress: '123 Fitness St, Gym City, GC 12345',
          notes: 'Leave package at front door',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        app_models.Order(
          id: 'order_002',
          userId: userId,
          items: [
            CartItem(
              id: 'cart_003',
              productId: 'protein_powder_1',
              productName: 'Whey Protein Powder - Vanilla',
              price: 79.99,
              quantity: 2,
              productImage: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=500',
              addedAt: DateTime.now().subtract(const Duration(days: 5)),
            ),
            CartItem(
              id: 'cart_004',
              productId: 'creatine_1',
              productName: 'Creatine Monohydrate',
              price: 34.99,
              quantity: 1,
              productImage: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=500',
              addedAt: DateTime.now().subtract(const Duration(days: 5)),
            ),
          ],
          totalAmount: 194.97,
          status: app_models.OrderStatus.shipped,
          shippingAddress: '123 Fitness St, Gym City, GC 12345',
          notes: 'Call before delivery',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        app_models.Order(
          id: 'order_003',
          userId: userId,
          items: [
            CartItem(
              id: 'cart_005',
              productId: 'resistance_bands_1',
              productName: 'Resistance Bands Set',
              price: 49.99,
              quantity: 1,
              productImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500',
              addedAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          totalAmount: 49.99,
          status: app_models.OrderStatus.pending,
          shippingAddress: '123 Fitness St, Gym City, GC 12345',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      final batch = _firestore.batch();
      for (final order in dummyOrders) {
        final docRef = _firestore
            .collection(FirebaseConstants.ordersCollection)
            .doc(order.id);
        batch.set(docRef, order.toMap());
      }

      await batch.commit();
      print('✅ Dummy orders added successfully');
    } catch (e) {
      // Silently handle errors - orders might already exist or permissions might be restricted
      print('ℹ️ Note: Could not add dummy orders - ${e.toString()}');
      print('ℹ️ This is normal if orders already exist or if using restricted permissions');
    }
  }
}
