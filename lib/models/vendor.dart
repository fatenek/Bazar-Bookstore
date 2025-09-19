class Vendor {
  final int id;
  final String name;
  final String? imageUrl;

  Vendor({required this.id, required this.name, this.imageUrl});

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      Vendor(id: json['id'], name: json['name'], imageUrl: json['image_url']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
  };
}
