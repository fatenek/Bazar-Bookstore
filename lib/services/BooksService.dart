import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';

class BooksService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Book>> getAllBooks() async {
    final data = await _client.from('books').select() as List<dynamic>;
    return data.map((b) => Book.fromJson(b)).toList();
  }

  Future<Book?> getBookById(int bookId) async {
    final data =
        await _client.from('books').select().eq('id', bookId) as List<dynamic>;
    if (data.isEmpty) return null;
    return Book.fromJson(data.first);
  }

  Future<List<Book>> getFeaturedBooks() async {
    final data =
        await _client.from('books').select().eq('is_featured', true)
            as List<dynamic>;
    return data.map((b) => Book.fromJson(b)).toList();
  }

  Future<List<Book>> getTopWeekBooks() async {
    final data =
        await _client.from('books').select().eq('is_top_week', true)
            as List<dynamic>;
    return data.map((b) => Book.fromJson(b)).toList();
  }

  Future<List<Book>> searchBooks(String query) async {
    final data =
        await _client.from('books').select().ilike('title', '%$query%')
            as List<dynamic>;
    return data.map((b) => Book.fromJson(b)).toList();
  }
}
