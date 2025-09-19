class Author {
  final int id;
  final String name;
  final String? role;
  final String? imageUrl;

  Author({required this.id, required this.name, this.role, this.imageUrl});

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    id: json['id'],
    name: json['name'],
    role: json['role'],
    imageUrl: json['image_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'image_url': imageUrl,
  };
}
