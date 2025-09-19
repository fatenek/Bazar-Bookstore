import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/offer.dart';

class OffersService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Offer>> getAllOffers() async {
    final data = await _client.from('offers').select() as List<dynamic>;
    return data.map((o) => Offer.fromJson(o)).toList();
  }

  Future<Offer?> getOfferById(int offerId) async {
    final data =
        await _client.from('offers').select().eq('id', offerId)
            as List<dynamic>;
    if (data.isEmpty) return null;
    return Offer.fromJson(data.first);
  }
}
