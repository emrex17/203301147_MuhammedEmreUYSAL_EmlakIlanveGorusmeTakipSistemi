class LogModel {
  final String id;
  final String userId;
  final String userEmail;
  final String action;
  final String? details;
  final DateTime createdAt;

  const LogModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.action,
    this.details,
    required this.createdAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userEmail: json['user_email'] as String? ?? '',
        action: json['action'] as String,
        details: json['details'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
