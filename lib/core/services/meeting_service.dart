import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting_model.dart';
import 'log_service.dart';

class MeetingService {
  static final _supabase = Supabase.instance.client;

  static Future<List<MeetingModel>> getMeetings(String userId) async {
    final data = await _supabase.from('meetings').select('''
          *,
          listings(title, location),
          owner_profile:profiles!owner_id(full_name),
          customer_profile:profiles!customer_id(full_name)
        ''').or('owner_id.eq.$userId,customer_id.eq.$userId').order(
        'created_at',
        ascending: false);

    return (data as List).map((e) => MeetingModel.fromJson(e)).toList();
  }

  static Future<void> createMeeting({
    required String listingId,
    required String ownerId,
    required String customerId,
    required String customerEmail,
    required String customerName,
    required DateTime meetingDate,
    String? notes,
  }) async {
    await _supabase.from('meetings').insert({
      'listing_id': listingId,
      'owner_id': ownerId,
      'customer_id': customerId,
      'meeting_date': meetingDate.toIso8601String(),
      'notes': notes,
      'status': 'beklemede',
    });

    await LogService.addLog(
      userId: customerId,
      userEmail: customerEmail,
      action: 'GÖRÜŞME_TALEBİ',
      details: '$customerName görüşme talebinde bulundu',
    );
  }

  static Future<void> updateMeetingStatus({
    required String id,
    required String userId,
    required String userEmail,
    required String userName,
    required String status,
  }) async {
    await _supabase.from('meetings').update({'status': status}).eq('id', id);

    final statusText = status == 'onaylandi' ? 'onayladı' : 'iptal etti';
    await LogService.addLog(
      userId: userId,
      userEmail: userEmail,
      action: 'GÖRÜŞME_DURUM',
      details: '$userName görüşmeyi $statusText',
    );
  }
}
