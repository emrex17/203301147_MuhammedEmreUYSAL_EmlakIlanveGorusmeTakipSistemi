import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'log_service.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) return null;

    await _supabase.from('profiles').insert({
      'id': response.user!.id,
      'email': email,
      'full_name': fullName,
      'role': role,
    });

    await LogService.addLog(
      userId: response.user!.id,
      userEmail: email,
      action: 'KAYIT',
      details: '$fullName ($role) kaydoldu',
    );

    return getProfile(response.user!.id);
  }

  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return null;

    final profile = await getProfile(response.user!.id);

    await LogService.addLog(
      userId: response.user!.id,
      userEmail: email,
      action: 'GİRİŞ',
      details: '${profile?.fullName ?? email} giriş yaptı',
    );

    return profile;
  }

  static Future<void> signOut(UserModel user) async {
    await LogService.addLog(
      userId: user.id,
      userEmail: user.email,
      action: 'ÇIKIŞ',
      details: '${user.fullName} çıkış yaptı',
    );
    await _supabase.auth.signOut();
  }

  static Future<UserModel?> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(data);
  }

  static Future<UserModel?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return getProfile(user.id);
  }

  static bool get isLoggedIn => _supabase.auth.currentUser != null;
}
