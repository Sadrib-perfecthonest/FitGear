class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> imageUrls;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    required this.stockQuantity,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      stockQuantity: map['stockQuantity'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrls': imageUrls,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? imageUrls,
    int? stockQuantity,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
