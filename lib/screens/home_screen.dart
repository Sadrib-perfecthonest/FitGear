import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/order_service.dart'; // Re-enabled for debugging
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../constants/app_constants.dart';
import '../constants/firebase_constants.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService(); // Re-enabled for debugging
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    FirebaseConstants.dumbbellsCategory,
    FirebaseConstants.barbellsCategory,
    FirebaseConstants.strengthCategory,
    FirebaseConstants.cardioCategory,
    FirebaseConstants.accessoriesCategory,
    FirebaseConstants.supplementsCategory,
  ];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    // Temporarily re-enable mock data loading to ensure products exist
    _loadDummyData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCartItems() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      cartProvider.loadCartItems(authProvider.user!.uid);
      // Mock orders loading disabled - data already in database
      // _loadDummyOrders(authProvider.user!.uid);
    }
  }

  // Mock data methods temporarily re-enabled for debugging
  Future<void> _loadDummyData() async {
    print('🔄 Loading dummy data...');
    try {
      await _productService.addDummyProducts();
      print('✅ Dummy data loading completed');
    } catch (e) {
      print('❌ Error loading dummy data: $e');
    }
  }

  Future<void> _loadDummyOrders(String userId) async {
    try {
      await _orderService.addDummyOrders(userId);
    } catch (e) {
      // Ignore errors - dummy orders might already exist
    }
  }

  Stream<List<Product>> _getProductsStream() {
    if (_searchQuery.isNotEmpty) {
      return _productService.searchProducts(_searchQuery);
    } else if (_selectedCategory == 'All') {
      return _productService.getAllProducts();
    } else {
      return _productService.getProductsByCategory(_selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const CartScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text(
        'FitGear',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: _selectedIndex == 0
          ? [
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
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
            ]
          : null,
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          color: AppColors.surface,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Category Filter
        if (_searchQuery.isEmpty)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        
        // Products Grid
        Expanded(
          child: StreamBuilder<List<Product>>(
            stream: _getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading products',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again later',
                        style: AppTextStyles.bodyTextSmall,
                      ),
                    ],
                  ),
                );
              }
              
              final products = snapshot.data ?? [];
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching for something else',
                        style: AppTextStyles.bodyTextSmall,
                      ),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: AppSizes.paddingMedium,
                  mainAxisSpacing: AppSizes.paddingMedium,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
