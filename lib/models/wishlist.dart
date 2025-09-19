class WishlistItem {
  final int id;
  final String userId;
  final int bookId;
  final DateTime createdAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
    id: json['id'],
    userId: json['user_id'],
    bookId: json['book_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'book_id': bookId,
    'created_at': createdAt.toIso8601String(),
  };
}
