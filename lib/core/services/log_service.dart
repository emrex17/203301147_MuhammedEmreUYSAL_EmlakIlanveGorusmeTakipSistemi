import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/log_model.dart';

class LogService {
  static final _supabase = Supabase.instance.client;

  static Future<void> addLog({
    required String userId,
    required String userEmail,
    required String action,
    String? details,
  }) async {
    try {
      await _supabase.from('logs').insert({
        'user_id': userId,
        'user_email': userEmail,
        'action': action,
        'details': details,
      });
    } catch (_) {
      // Log hatası uygulamayı bozmasın
    }
  }

  static Future<List<LogModel>> getLogs(String userId) async {
    final data = await _supabase
        .from('logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);

    return (data as List).map((e) => LogModel.fromJson(e)).toList();
  }
}
