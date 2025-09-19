import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist.dart';

class WishlistService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<WishlistItem>> getWishlist(String userId) async {
    final data = await _client.from('wishlist').select() as List<dynamic>;
    return data
        .where((w) => w['user_id'] == userId)
        .map((w) => WishlistItem.fromJson(w))
        .toList();
  }

  Future<void> addToWishlist(String userId, int bookId) async {
    await _client.from('wishlist').insert({
      'user_id': userId,
      'book_id': bookId,
    });
  }

  Future<void> removeFromWishlist(String userId, int bookId) async {
    await _client
        .from('wishlist')
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
  }

  Future<bool> isBookInWishlist(String userId, int bookId) async {
    final data =
        await _client
                .from('wishlist')
                .select()
                .eq('user_id', userId)
                .eq('book_id', bookId)
            as List<dynamic>;
    return data.isNotEmpty;
  }
}
