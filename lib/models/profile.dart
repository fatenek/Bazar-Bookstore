class Profile {
  final String id;
  final String fullName;
  final String? avatarUrl;

  Profile({required this.id, required this.fullName, this.avatarUrl});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'],
    fullName: json['full_name'],
    avatarUrl: json['avatar_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'avatar_url': avatarUrl,
  };
}
