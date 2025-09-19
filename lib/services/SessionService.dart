import 'package:supabase_flutter/supabase_flutter.dart';

class SessionService {
  final SupabaseClient _client = Supabase.instance.client;

  bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }
}
