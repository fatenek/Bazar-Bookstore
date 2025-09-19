import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDetailsPage extends StatefulWidget {
  final int bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? book;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  Future<void> _loadBookDetails() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('id', widget.bookId)
          .maybeSingle(); // 👈 important: return one row or null

      setState(() {
        book = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading book details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (book == null) {
      return const Scaffold(body: Center(child: Text('Book not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(book!['title'] ?? 'Book Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book!['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book!['image_url'],
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              book!['title'] ?? 'Unknown Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: \$${book!['price']?.toString() ?? '0.00'}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              book!['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
