import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/cart_item_widget.dart';
import '../constants/app_constants.dart';
import '../models/cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final OrderService _orderService = OrderService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.appUser?.address != null) {
      _addressController.text = authProvider.appUser!.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your shipping address';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Checkout'),
      ),
      body: Consumer2<AuthProvider, CartProvider>(
        builder: (context, authProvider, cartProvider, child) {
          if (authProvider.user == null || cartProvider.cartItems.isEmpty) {
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
                    'No items to checkout',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary
                        _buildOrderSummary(cartProvider.cartItems),
                        
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Shipping Information
                        _buildShippingInfo(authProvider),
                        
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Order Total
                        _buildOrderTotal(cartProvider),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Place Order Button
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
                child: CustomButton(
                  text: 'Place Order - \$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  onPressed: () => _placeOrder(authProvider, cartProvider),
                  isLoading: _isProcessing,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(List<CartItem> cartItems) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'Order Summary',
              style: AppTextStyles.heading3,
            ),
          ),
          const Divider(height: 1),
          ...cartItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyTextSmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppSizes.paddingSmall),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Information',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Customer Name
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authProvider.appUser?.name ?? 'Unknown User',
                    style: AppTextStyles.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Email
            Row(
              children: [
                const Icon(Icons.email, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authProvider.user?.email ?? 'No email',
                    style: AppTextStyles.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Shipping Address
            CustomTextField(
              label: 'Shipping Address',
              hint: 'Enter your complete shipping address',
              controller: _addressController,
              validator: _validateAddress,
              maxLines: 3,
              prefixIcon: const Icon(Icons.location_on),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Order Notes
            CustomTextField(
              label: 'Order Notes (Optional)',
              hint: 'Any special instructions for your order',
              controller: _notesController,
              maxLines: 2,
              prefixIcon: const Icon(Icons.note),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTotal(CartProvider cartProvider) {
    final subtotal = cartProvider.totalAmount;
    const shipping = 9.99;
    const tax = 0.0; // Tax calculation can be added here
    final total = subtotal + shipping + tax;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            const Text(
              'Order Total',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: AppTextStyles.bodyText),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Shipping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping:', style: AppTextStyles.bodyText),
                Text(
                  '\$${shipping.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Tax
            if (tax > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax:', style: AppTextStyles.bodyText),
                  Text(
                    '\$${tax.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyText,
                  ),
                ],
              ),
            
            const Divider(),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: AppTextStyles.heading3,
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(AuthProvider authProvider, CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final orderId = await _orderService.createOrder(
        userId: authProvider.user!.uid,
        cartItems: cartProvider.cartItems,
        shippingAddress: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Order Placed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your order has been placed successfully.'),
                const SizedBox(height: 8),
                Text(
                  'Order ID: $orderId',
                  style: AppTextStyles.bodyTextSmall.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                const Text('You will receive an email confirmation shortly.'),
              ],
            ),
            actions: [
              CustomButton(
                text: 'Continue Shopping',
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to home
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
