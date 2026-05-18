class ListingModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final String? description;
  final double price;
  final String location;
  final String propertyType;
  final String? roomCount;
  final double? area;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListingModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    this.description,
    required this.price,
    required this.location,
    required this.propertyType,
    this.roomCount,
    this.area,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return ListingModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      ownerName: profileData?['full_name'] as String? ?? 'Bilinmiyor',
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      propertyType: json['property_type'] as String,
      roomCount: json['room_count'] as String?,
      area: json['area'] != null ? (json['area'] as num).toDouble() : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  bool get isActive => status == 'active';
}
