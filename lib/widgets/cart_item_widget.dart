import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';
import '../constants/app_constants.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                child: cartItem.productImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: cartItem.productImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.fitness_center,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.productName,
                    style: AppTextStyles.heading3.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${cartItem.price.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: cartItem.quantity > 1
                                  ? () => onQuantityChanged(cartItem.quantity - 1)
                                  : null,
                              icon: const Icon(Icons.remove, size: 18),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '${cartItem.quantity}',
                                style: AppTextStyles.bodyText.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                              icon: const Icon(Icons.add, size: 18),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Total Price
                      Text(
                        '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            // Remove Button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}
