import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/author.dart';

class AuthorsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Author>> getAllAuthors() async {
    final data = await _client.from('authors').select() as List<dynamic>;
    return data.map((a) => Author.fromJson(a)).toList();
  }

  Future<Author?> getAuthorById(int authorId) async {
    final data =
        await _client.from('authors').select().eq('id', authorId)
            as List<dynamic>;
    if (data.isEmpty) return null;
    return Author.fromJson(data.first);
  }

  Future<List<Author>> searchAuthors(String query) async {
    final data =
        await _client.from('authors').select().ilike('name', '%$query%')
            as List<dynamic>;
    return data.map((a) => Author.fromJson(a)).toList();
  }
}
