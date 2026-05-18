class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        role: json['role'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  bool get isOwner => role == 'ilan_sahibi';
  String get roleDisplay => role == 'ilan_sahibi' ? 'İlan Sahibi' : 'Müşteri';
}
