import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vendor.dart';

class VendorsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Vendor>> getAllVendors() async {
    final data = await _client.from('vendors').select() as List<dynamic>;
    return data.map((v) => Vendor.fromJson(v)).toList();
  }

  Future<Vendor?> getVendorById(int vendorId) async {
    final data =
        await _client.from('vendors').select().eq('id', vendorId)
            as List<dynamic>;
    if (data.isEmpty) return null;
    return Vendor.fromJson(data.first);
  }
}
