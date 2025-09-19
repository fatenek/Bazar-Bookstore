import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Sign in
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

  // Sign up with better error handling
  Future<User?> signUp(String fullName, String email, String password) async {
    try {
      // First, sign up the user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // Create profile with minimal required data
        // Remove fields that might not exist in your table
        await _client.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
          // Only include fields that definitely exist in your profiles table
          // Remove 'email' and 'created_at' if they don't exist or are auto-generated
        });
      }
      return user;
    } catch (e) {
      print('Sign up error: $e');
      // If profile creation fails but user was created, you might want to handle this
      rethrow;
    }
  }

  // Alternative signup method - let database handle timestamps
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
        // Minimal insert - only essential fields
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

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Get profile with better error handling
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle() instead of casting

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // Update profile
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
