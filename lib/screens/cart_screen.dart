import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/custom_button.dart';
import '../constants/app_constants.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer2<AuthProvider, CartProvider>(
        builder: (context, authProvider, cartProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please login to view your cart',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
            );
          }

          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: AppTextStyles.heading3,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: AppTextStyles.bodyTextSmall,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return CartItemWidget(
                      cartItem: cartItem,
                      onRemove: () => _removeFromCart(
                        context,
                        authProvider,
                        cartProvider,
                        cartItem.id,
                      ),
                      onQuantityChanged: (quantity) => _updateQuantity(
                        context,
                        authProvider,
                        cartProvider,
                        cartItem.id,
                        quantity,
                      ),
                    );
                  },
                ),
              ),
              
              // Cart Summary
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: AppTextStyles.bodyText,
                        ),
                        Text(
                          '${cartProvider.itemCount}',
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: AppTextStyles.heading3,
                        ),
                        Text(
                          '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Clear Cart',
                            onPressed: () => _showClearCartDialog(
                              context,
                              authProvider,
                              cartProvider,
                            ),
                            isOutlined: true,
                            backgroundColor: AppColors.error,
                            textColor: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            text: 'Checkout',
                            onPressed: () => _navigateToCheckout(context),
                            isLoading: cartProvider.isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeFromCart(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
    String cartItemId,
  ) async {
    final success = await cartProvider.removeFromCart(
      userId: authProvider.user!.uid,
      cartItemId: cartItemId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Item removed from cart'
                : cartProvider.errorMessage ?? 'Failed to remove item',
          ),
          backgroundColor: success ? AppColors.primary : AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateQuantity(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
    String cartItemId,
    int quantity,
  ) async {
    final success = await cartProvider.updateQuantity(
      userId: authProvider.user!.uid,
      cartItemId: cartItemId,
      quantity: quantity,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cartProvider.errorMessage ?? 'Failed to update quantity',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showClearCartDialog(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await cartProvider.clearCart(authProvider.user!.uid);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Cart cleared successfully'
                          : cartProvider.errorMessage ?? 'Failed to clear cart',
                    ),
                    backgroundColor: success ? AppColors.primary : AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }
}
