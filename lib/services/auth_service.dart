import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  /// Sign up user with email & password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Verify the email OTP
  static Future<bool> verifyEmailCode(String email, String code) async {
    try {
      await _client.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: code,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Send phone verification code
  static Future<bool> sendPhoneCode(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Verify the phone OTP
  static Future<bool> verifyPhoneCode(String phone, String code) async {
    try {
      await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: code,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
