import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing_model.dart';
import 'log_service.dart';

class ListingService {
  static final _supabase = Supabase.instance.client;

  static Future<List<ListingModel>> getListings() async {
    final data = await _supabase
        .from('listings')
        .select('*, profiles!owner_id(full_name)')
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return (data as List).map((e) => ListingModel.fromJson(e)).toList();
  }

  static Future<List<ListingModel>> getOwnerListings(String ownerId) async {
    final data = await _supabase
        .from('listings')
        .select('*, profiles!owner_id(full_name)')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => ListingModel.fromJson(e)).toList();
  }

  static Future<ListingModel> createListing({
    required String ownerId,
    required String ownerEmail,
    required String ownerName,
    required String title,
    String? description,
    required double price,
    required String location,
    required String propertyType,
    String? roomCount,
    double? area,
  }) async {
    final data = await _supabase
        .from('listings')
        .insert({
          'owner_id': ownerId,
          'title': title,
          'description': description,
          'price': price,
          'location': location,
          'property_type': propertyType,
          'room_count': roomCount,
          'area': area,
          'status': 'active',
        })
        .select('*, profiles!owner_id(full_name)')
        .single();

    await LogService.addLog(
      userId: ownerId,
      userEmail: ownerEmail,
      action: 'İLAN_EKLEME',
      details: '$ownerName "$title" ilanını ekledi',
    );

    return ListingModel.fromJson(data);
  }

  static Future<void> updateListing({
    required String id,
    required String userId,
    required String userEmail,
    required String userName,
    required String title,
    String? description,
    required double price,
    required String location,
    required String propertyType,
    String? roomCount,
    double? area,
    required String status,
  }) async {
    await _supabase.from('listings').update({
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'property_type': propertyType,
      'room_count': roomCount,
      'area': area,
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);

    await LogService.addLog(
      userId: userId,
      userEmail: userEmail,
      action: 'İLAN_GÜNCELLEME',
      details: '$userName "$title" ilanını güncelledi',
    );
  }

  static Future<void> deleteListing({
    required String id,
    required String userId,
    required String userEmail,
    required String userName,
    required String listingTitle,
  }) async {
    await _supabase.from('listings').delete().eq('id', id);

    await LogService.addLog(
      userId: userId,
      userEmail: userEmail,
      action: 'İLAN_SİLME',
      details: '$userName "$listingTitle" ilanını sildi',
    );
  }
}
