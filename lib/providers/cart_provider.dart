import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cartItems.length;
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  void loadCartItems(String userId) {
    _cartService.getCartItems(userId).listen(
      (cartItems) {
        _cartItems = cartItems;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addToCart({
    required String userId,
    required Product product,
    int quantity = 1,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _cartService.addToCart(
        userId: userId,
        product: product,
        quantity: quantity,
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateQuantity({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _cartService.updateCartItemQuantity(
        userId: userId,
        cartItemId: cartItemId,
        quantity: quantity,
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeFromCart({
    required String userId,
    required String cartItemId,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _cartService.removeFromCart(
        userId: userId,
        cartItemId: cartItemId,
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> clearCart(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _cartService.clearCart(userId);
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
