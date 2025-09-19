import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<User?> signUp(String fullName, String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await _client.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
        });
      }
      return user;
    } catch (e) {
      print('Sign up error: $e');

      rethrow;
    }
  }

  Future<User?> signUpSimple(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await _client.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
        });
      }
      return user;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  Future<void> updateProfile(
    String userId, {
    String? fullName,
    String? avatarUrl,
  }) async {
    final updateData = <String, dynamic>{};
    if (fullName != null) updateData['full_name'] = fullName;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

    if (updateData.isNotEmpty) {
      await _client.from('profiles').update(updateData).eq('id', userId);
    }
  }
}
