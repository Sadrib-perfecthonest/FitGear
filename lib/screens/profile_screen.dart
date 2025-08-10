import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';
import '../models/order.dart' as app_models;
import '../widgets/custom_button.dart';
import '../constants/app_constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please login to view your profile',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(authProvider),
                
                const SizedBox(height: AppSizes.paddingLarge),
                
                // Order History
                _buildOrderHistory(authProvider.user!.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final user = authProvider.user!;
    final appUser = authProvider.appUser;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Profile Avatar
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // User Name
            Text(
              appUser?.name ?? user.displayName ?? 'User',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            
            // User Email
            Text(
              user.email ?? 'No email',
              style: AppTextStyles.bodyText.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            
            // User Info Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<List<app_models.Order>>(
                          stream: _orderService.getUserOrders(user.uid),
                          builder: (context, snapshot) {
                            final orderCount = snapshot.data?.length ?? 0;
                            return Text(
                              '$orderCount',
                              style: AppTextStyles.heading3.copyWith(
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        Text(
                          'Orders',
                          style: AppTextStyles.bodyTextSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Since',
                          style: AppTextStyles.bodyTextSmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${DateTime.fromMillisecondsSinceEpoch(user.metadata.creationTime?.millisecondsSinceEpoch ?? 0).year}',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sign Out Button
            CustomButton(
              text: 'Sign Out',
              onPressed: () => _showSignOutDialog(context, authProvider),
              isOutlined: true,
              backgroundColor: Colors.white,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory(String userId) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Text(
              'Order History',
              style: AppTextStyles.heading3,
            ),
          ),
          const Divider(height: 1),
          StreamBuilder<List<app_models.Order>>(
            stream: _orderService.getUserOrders(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading orders',
                          style: AppTextStyles.bodyText,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final orders = snapshot.data ?? [];

              if (orders.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No orders yet',
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start shopping to see your orders here',
                          style: AppTextStyles.bodyTextSmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderItem(order);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(app_models.Order order) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, 8)}',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.statusDisplayName,
                  style: AppTextStyles.caption.copyWith(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Order Date
          Text(
            'Ordered on ${_formatDate(order.createdAt)}',
            style: AppTextStyles.bodyTextSmall,
          ),
          const SizedBox(height: 8),
          
          // Items Count and Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                style: AppTextStyles.bodyTextSmall,
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(app_models.OrderStatus status) {
    switch (status) {
      case app_models.OrderStatus.pending:
        return Colors.orange;
      case app_models.OrderStatus.confirmed:
        return Colors.blue;
      case app_models.OrderStatus.processing:
        return Colors.purple;
      case app_models.OrderStatus.shipped:
        return Colors.teal;
      case app_models.OrderStatus.delivered:
        return Colors.green;
      case app_models.OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
