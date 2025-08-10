import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_button.dart';
import '../constants/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: Text(widget.product.name),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images
                  _buildImageSection(),
                  
                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name and Category
                        Text(
                          widget.product.name,
                          style: AppTextStyles.heading1.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.product.category,
                            style: AppTextStyles.bodyTextSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingMedium),
                        
                        // Rating and Reviews
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < widget.product.rating.floor()
                                    ? Icons.star
                                    : index < widget.product.rating
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
                              style: AppTextStyles.bodyTextSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Price
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Description
                        Text(
                          'Description',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Stock Status
                        Row(
                          children: [
                            Icon(
                              widget.product.stockQuantity > 0
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: widget.product.stockQuantity > 0
                                  ? Colors.green
                                  : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.product.stockQuantity > 0
                                  ? 'In Stock (${widget.product.stockQuantity} available)'
                                  : 'Out of Stock',
                              style: AppTextStyles.bodyText.copyWith(
                                color: widget.product.stockQuantity > 0
                                    ? Colors.green
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        
                        // Quantity Selector
                        Text(
                          'Quantity',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$_quantity',
                                  style: AppTextStyles.heading3,
                                ),
                              ),
                              IconButton(
                                onPressed: _quantity < widget.product.stockQuantity
                                    ? () {
                                        setState(() {
                                          _quantity++;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Add to Cart Button
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
            child: Consumer2<AuthProvider, CartProvider>(
              builder: (context, authProvider, cartProvider, child) {
                return CustomButton(
                  text: 'Add to Cart - \$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                  onPressed: widget.product.stockQuantity > 0
                      ? () => _addToCart(authProvider, cartProvider)
                      : () {}, // Empty function instead of null
                  isLoading: cartProvider.isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 300,
      color: AppColors.surface,
      child: widget.product.imageUrls.isNotEmpty
          ? Column(
              children: [
                // Main Image
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrls[_selectedImageIndex],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Image Thumbnails (if multiple images)
                if (widget.product.imageUrls.length > 1)
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.paddingSmall,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.imageUrls.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedImageIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageIndex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: widget.product.imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.fitness_center,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            )
          : const Center(
              child: Icon(
                Icons.fitness_center,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
    );
  }

  Future<void> _addToCart(AuthProvider authProvider, CartProvider cartProvider) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add items to cart'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await cartProvider.addToCart(
      userId: authProvider.user!.uid,
      product: widget.product,
      quantity: _quantity,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Added to cart successfully!'
                : cartProvider.errorMessage ?? 'Failed to add to cart',
          ),
          backgroundColor: success ? AppColors.primary : AppColors.error,
        ),
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }
}
