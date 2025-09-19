class Offer {
  final int id;
  final String? title;
  final int? discount;
  final String? imageUrl;
  final String? ctaText;

  Offer({
    required this.id,
    this.title,
    this.discount,
    this.imageUrl,
    this.ctaText,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
    id: json['id'],
    title: json['title'],
    discount: json['discount'],
    imageUrl: json['image_url'],
    ctaText: json['cta_text'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'discount': discount,
    'image_url': imageUrl,
    'cta_text': ctaText,
  };
}
