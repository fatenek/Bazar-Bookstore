import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDetailsPage extends StatefulWidget {
  final int bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  Map<String, dynamic>? _book;
  Map<String, dynamic>? _vendor;
  bool _loading = true;
  bool _inWishlist = false;
  int _quantity = 1;
  int _userRating = 0;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    try {
      final user = supabase.auth.currentUser;

      final bookRes = await supabase
          .from('books')
          .select('id, title, price, image_url, description')
          .eq('id', widget.bookId)
          .single();

      Map<String, dynamic>? vendorData;

      bool inWishlist = false;
      if (user != null) {
        final wishlistRes = await supabase
            .from('wishlist')
            .select('id')
            .eq('user_id', user.id)
            .eq('book_id', widget.bookId)
            .maybeSingle();
        inWishlist = wishlistRes != null;
      }

      setState(() {
        _book = bookRes;
        _vendor = vendorData;
        _inWishlist = inWishlist;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching book details: $e');
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading book details: $e')),
        );
      }
    }
  }

  Future<void> _toggleWishlist() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add to wishlist')),
      );
      return;
    }

    if (_book == null) return;

    try {
      if (_inWishlist) {
        await supabase
            .from('wishlist')
            .delete()
            .eq('user_id', user.id)
            .eq('book_id', widget.bookId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from wishlist')),
          );
        }
      } else {
        await supabase.from('wishlist').insert({
          'user_id': user.id,
          'book_id': widget.bookId,
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to wishlist')));
        }
      }

      setState(() {
        _inWishlist = !_inWishlist;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  double get _totalPrice {
    final price = _book?['price'] ?? 0;
    return (price is String)
        ? (double.tryParse(price) ?? 0) * _quantity
        : (price.toDouble()) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF54408C)),
        ),
      );
    }

    if (_book == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("Book not found")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _book!['image_url'] ?? '',
                  width: 200,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200,
                    height: 280,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _book!['title'] ?? 'Unknown Title',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _toggleWishlist,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _inWishlist ? Icons.favorite : Icons.favorite_border,
                      color: _inWishlist ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              _book!['description'] ?? 'No description available.',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _userRating = index + 1;
                    });
                  },
                  child: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Color(0xFF54408C),
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$_quantity",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF54408C),
                        size: 32,
                      ),
                    ),
                  ],
                ),

                Text(
                  "\$${_totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF54408C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF54408C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continue Shopping",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      DefaultTabController.of(context)?.animateTo(2);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF54408C),
                      side: const BorderSide(
                        color: Color(0xFF54408C),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "View Cart",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
