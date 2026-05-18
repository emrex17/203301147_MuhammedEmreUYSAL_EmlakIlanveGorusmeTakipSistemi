class MeetingModel {
  final String id;
  final String listingId;
  final String listingTitle;
  final String listingLocation;
  final String ownerId;
  final String ownerName;
  final String customerId;
  final String customerName;
  final DateTime meetingDate;
  final String? notes;
  final String status;
  final DateTime createdAt;

  const MeetingModel({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingLocation,
    required this.ownerId,
    required this.ownerName,
    required this.customerId,
    required this.customerName,
    required this.meetingDate,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final listingsData = json['listings'] as Map<String, dynamic>?;
    final ownerProfile = json['owner_profile'] as Map<String, dynamic>?;
    final customerProfile = json['customer_profile'] as Map<String, dynamic>?;

    return MeetingModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      listingTitle: listingsData?['title'] as String? ?? 'Bilinmiyor',
      listingLocation: listingsData?['location'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      ownerName: ownerProfile?['full_name'] as String? ?? 'Bilinmiyor',
      customerId: json['customer_id'] as String,
      customerName: customerProfile?['full_name'] as String? ?? 'Bilinmiyor',
      meetingDate: DateTime.parse(json['meeting_date'] as String),
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'beklemede':
        return 'Beklemede';
      case 'onaylandi':
        return 'Onaylandı';
      case 'iptal':
        return 'İptal';
      default:
        return status;
    }
  }
}
