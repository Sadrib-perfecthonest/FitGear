import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../constants/firebase_constants.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<Product>> getAllProducts() {
    print('🔍 Getting all products from Firestore...');
    return _firestore
        .collection(FirebaseConstants.productsCollection)
        // Temporarily removed isAvailable filter for testing
        // .where('isAvailable', isEqualTo: true)
        // Removed orderBy to avoid index issues
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📦 Firestore snapshot received: ${snapshot.docs.length} documents');
          final products = snapshot.docs
              .map((doc) {
                print('📄 Document ID: ${doc.id}');
                try {
                  return Product.fromMap(doc.data());
                } catch (e) {
                  print('❌ Error parsing document ${doc.id}: $e');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<Product>()
              .toList();
          print('✅ Successfully parsed ${products.length} products');
          return products;
        });
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    print('🔍 Getting products by category: $category');
    return _firestore
        .collection(FirebaseConstants.productsCollection)
        .where('category', isEqualTo: category)
        // Temporarily removed isAvailable filter for testing
        // .where('isAvailable', isEqualTo: true)
        // Removed orderBy to avoid index issues
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📦 Category snapshot received: ${snapshot.docs.length} documents for $category');
          final products = snapshot.docs
              .map((doc) {
                try {
                  return Product.fromMap(doc.data());
                } catch (e) {
                  print('❌ Error parsing category document ${doc.id}: $e');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<Product>()
              .toList();
          print('✅ Successfully parsed ${products.length} products for category $category');
          return products;
        });
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstants.productsCollection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  // Search products
  Stream<List<Product>> searchProducts(String query) {
    return _firestore
        .collection(FirebaseConstants.productsCollection)
        // Temporarily removed isAvailable filter for testing
        // .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data()))
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()) ||
                product.category.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // Add dummy data (for testing)
  Future<void> addDummyProducts() async {
    try {
      final List<Product> dummyProducts = [
        // Strength Training Equipment
        Product(
          id: 'dumbbell_set_1',
          name: 'Adjustable Dumbbell Set',
          description: 'Professional adjustable dumbbell set with quick-change weight plates. Perfect for home gym setup with weight range from 5-50 lbs per dumbbell.',
          price: 299.99,
          category: FirebaseConstants.dumbbellsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500&q=80'],
          stockQuantity: 25,
          rating: 4.5,
          reviewCount: 128,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'barbell_set_1',
          name: 'Olympic Barbell Set',
          description: 'Complete Olympic barbell set with 45lb bar and weight plates. Built for serious strength training with commercial-grade quality.',
          price: 599.99,
          category: FirebaseConstants.barbellsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1534368270820-9de3d8053204?w=500&q=80'],
          stockQuantity: 15,
          rating: 4.8,
          reviewCount: 89,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'kettlebell_set_1',
          name: 'Kettlebell Set 20-50lb',
          description: 'Professional kettlebell set with weights from 20lb to 50lb. Wide handle for comfortable grip during swings and Turkish get-ups.',
          price: 249.99,
          category: FirebaseConstants.strengthCategory,
          imageUrls: ['https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500&q=80'],
          stockQuantity: 18,
          rating: 4.4,
          reviewCount: 203,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'power_rack_1',
          name: 'Heavy Duty Power Rack',
          description: 'Commercial-grade power rack with pull-up bar, dip handles, and safety bars. Perfect for serious strength training and home gyms.',
          price: 899.99,
          category: FirebaseConstants.strengthCategory,
          imageUrls: ['https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&q=80'],
          stockQuantity: 5,
          rating: 4.8,
          reviewCount: 67,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'weight_plates_set',
          name: 'Olympic Weight Plates Set',
          description: 'Complete set of Olympic weight plates including 45lb, 25lb, 10lb, 5lb, and 2.5lb plates. Cast iron construction with rubber coating.',
          price: 399.99,
          category: FirebaseConstants.strengthCategory,
          imageUrls: ['https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=500&q=80'],
          stockQuantity: 12,
          rating: 4.6,
          reviewCount: 156,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        // Cardio Equipment
        Product(
          id: 'treadmill_1',
          name: 'Professional Treadmill',
          description: 'High-performance treadmill with advanced display and multiple workout programs. Speed up to 12mph with 15% incline capability.',
          price: 1299.99,
          category: FirebaseConstants.cardioCategory,
          imageUrls: ['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&q=80'],
          stockQuantity: 8,
          rating: 4.3,
          reviewCount: 67,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'exercise_bike_1',
          name: 'Stationary Exercise Bike',
          description: 'Magnetic resistance exercise bike with adjustable seat and handlebars. Digital display shows time, speed, distance, and calories burned.',
          price: 399.99,
          category: FirebaseConstants.cardioCategory,
          imageUrls: ['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=500&q=80'],
          stockQuantity: 12,
          rating: 4.2,
          reviewCount: 134,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'rowing_machine_1',
          name: 'Water Resistance Rowing Machine',
          description: 'Full-body cardio workout machine with smooth water resistance. Foldable design for easy storage with performance monitor.',
          price: 699.99,
          category: FirebaseConstants.cardioCategory,
          imageUrls: ['https://images.unsplash.com/photo-1506629905607-bb5526e3c50a?w=500&q=80'],
          stockQuantity: 6,
          rating: 4.5,
          reviewCount: 89,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'elliptical_1',
          name: 'Elliptical Cross Trainer',
          description: 'Low-impact elliptical trainer with 16 resistance levels and heart rate monitoring. Perfect for joint-friendly cardio workouts.',
          price: 799.99,
          category: FirebaseConstants.cardioCategory,
          imageUrls: ['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&q=80'],
          stockQuantity: 7,
          rating: 4.4,
          reviewCount: 112,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        // Accessories
        Product(
          id: 'resistance_bands_1',
          name: 'Resistance Bands Set',
          description: 'Complete set of resistance bands with different resistance levels (light, medium, heavy). Includes door anchor and workout guide.',
          price: 49.99,
          category: FirebaseConstants.accessoriesCategory,
          imageUrls: ['https://images.unsplash.com/photo-1599058918949-bd7e887b3c42?w=500&q=80'],
          stockQuantity: 50,
          rating: 4.2,
          reviewCount: 203,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'yoga_mat_1',
          name: 'Premium Yoga Mat',
          description: 'Non-slip yoga mat made from eco-friendly TPE material. 6mm thick for extra cushioning during floor exercises and stretching.',
          price: 39.99,
          category: FirebaseConstants.accessoriesCategory,
          imageUrls: ['https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80'],
          stockQuantity: 75,
          rating: 4.6,
          reviewCount: 324,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'gym_gloves_1',
          name: 'Weight Lifting Gloves',
          description: 'Professional weight lifting gloves with wrist support and palm padding. Breathable mesh back for comfort during intense workouts.',
          price: 24.99,
          category: FirebaseConstants.accessoriesCategory,
          imageUrls: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500&q=80'],
          stockQuantity: 45,
          rating: 4.1,
          reviewCount: 156,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'foam_roller_1',
          name: 'High-Density Foam Roller',
          description: 'High-density foam roller for muscle recovery and massage. 18-inch length perfect for full-body use and myofascial release.',
          price: 29.99,
          category: FirebaseConstants.accessoriesCategory,
          imageUrls: ['https://images.unsplash.com/photo-1599058918949-bd7e887b3c42?w=500&q=80'],
          stockQuantity: 30,
          rating: 4.3,
          reviewCount: 89,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'gym_bag_1',
          name: 'Premium Sport Gym Bag',
          description: 'Spacious gym bag with separate shoe compartment and water bottle holder. Durable polyester construction with reinforced handles.',
          price: 59.99,
          category: FirebaseConstants.accessoriesCategory,
          imageUrls: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&q=80'],
          stockQuantity: 25,
          rating: 4.0,
          reviewCount: 78,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'battle_ropes_1',
          name: 'Battle Ropes Training Set',
          description: '30ft heavy battle ropes for high-intensity interval training. 2-inch diameter for comfortable grip during cardio and strength workouts.',
          price: 89.99,
          category: FirebaseConstants.accessoriesCategory,
          imageUrls: ['https://images.unsplash.com/photo-1599058918949-bd7e887b3c42?w=500&q=80'],
          stockQuantity: 15,
          rating: 4.4,
          reviewCount: 95,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),

        // Supplements
        Product(
          id: 'protein_powder_1',
          name: 'Whey Protein Powder - Vanilla',
          description: 'Premium whey protein powder for muscle building and recovery. 25g protein per serving with all essential amino acids. Great taste!',
          price: 79.99,
          category: FirebaseConstants.supplementsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=500&q=80'],
          stockQuantity: 100,
          rating: 4.6,
          reviewCount: 445,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'protein_powder_2',
          name: 'Whey Protein Powder - Chocolate',
          description: 'Premium whey protein powder in rich chocolate flavor. 25g protein per serving with minimal carbs and fats.',
          price: 79.99,
          category: FirebaseConstants.supplementsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=500&q=80'],
          stockQuantity: 85,
          rating: 4.7,
          reviewCount: 523,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'creatine_1',
          name: 'Creatine Monohydrate',
          description: 'Pure creatine monohydrate powder for increased strength and power. Unflavored and mixes easily with any drink. 5g per serving.',
          price: 34.99,
          category: FirebaseConstants.supplementsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=500&q=80'],
          stockQuantity: 80,
          rating: 4.5,
          reviewCount: 267,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'pre_workout_1',
          name: 'Pre-Workout Energy Boost',
          description: 'High-energy pre-workout supplement with caffeine, beta-alanine, and citrulline for enhanced performance and focus.',
          price: 49.99,
          category: FirebaseConstants.supplementsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=500&q=80'],
          stockQuantity: 60,
          rating: 4.4,
          reviewCount: 189,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'bcaa_1',
          name: 'BCAA Recovery Formula',
          description: 'Branched-chain amino acids for muscle recovery and reduced fatigue. Tropical punch flavor with 2:1:1 ratio.',
          price: 39.99,
          category: FirebaseConstants.supplementsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=500&q=80'],
          stockQuantity: 70,
          rating: 4.2,
          reviewCount: 134,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'multivitamin_1',
          name: 'Athletic Performance Multivitamin',
          description: 'Complete multivitamin designed for active individuals. Supports energy, immunity, and overall health with 23 essential nutrients.',
          price: 29.99,
          category: FirebaseConstants.supplementsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=500&q=80'],
          stockQuantity: 90,
          rating: 4.1,
          reviewCount: 201,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'fish_oil_1',
          name: 'Omega-3 Fish Oil',
          description: 'High-potency fish oil capsules with EPA and DHA for heart health and joint support. 1000mg per softgel.',
          price: 24.99,
          category: FirebaseConstants.supplementsCategory,
          imageUrls: ['https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=500&q=80'],
          stockQuantity: 95,
          rating: 4.3,
          reviewCount: 178,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final batch = _firestore.batch();
      for (final product in dummyProducts) {
        final docRef = _firestore
            .collection(FirebaseConstants.productsCollection)
            .doc(product.id);
        batch.set(docRef, product.toMap());
      }

      await batch.commit();
      print('✅ Dummy products added successfully');
    } catch (e) {
      // Silently handle errors - products might already exist or permissions might be restricted
      print('ℹ️ Note: Could not add dummy products - ${e.toString()}');
      print('ℹ️ This is normal if products already exist or if using restricted permissions');
    }
  }
}
