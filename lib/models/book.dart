class Book {
  final int id;
  final String title;
  final double? price;
  final String? imageUrl;
  final String? description;
  final bool isFeatured;
  final bool isTopWeek;

  Book({
    required this.id,
    required this.title,
    this.price,
    this.imageUrl,
    this.description,
    this.isFeatured = false,
    this.isTopWeek = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    imageUrl: json['image_url'],
    description: json['description'],
    isFeatured: json['is_featured'] ?? false,
    isTopWeek: json['is_top_week'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'image_url': imageUrl,
    'description': description,
    'is_featured': isFeatured,
    'is_top_week': isTopWeek,
  };
}
