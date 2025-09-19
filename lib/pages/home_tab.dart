import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'book_details.dart';
import 'books_list.dart';
import 'vendors_page.dart';
import 'authors_page.dart'; // ✅ import AuthorsPage
import 'author_details_page.dart'; // ✅ import AuthorDetailsPage

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> featuredBooks = [];
  List<Map<String, dynamic>> topWeekBooks = [];
  List<Map<String, dynamic>> vendors = [];
  List<Map<String, dynamic>> authors = [];
  Map<String, dynamic>? specialOffer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final featuredResponse = await _supabase
          .from('books')
          .select()
          .eq('is_featured', true)
          .limit(3);

      final topWeekResponse = await _supabase
          .from('books')
          .select()
          .eq('is_top_week', true)
          .limit(3);

      final vendorsResponse = await _supabase.from('vendors').select().limit(6);

      final authorsResponse = await _supabase.from('authors').select().limit(5);

      final offerResponse = await _supabase.from('offers').select().limit(1);

      setState(() {
        featuredBooks = List<Map<String, dynamic>>.from(featuredResponse);
        topWeekBooks = List<Map<String, dynamic>>.from(topWeekResponse);
        vendors = List<Map<String, dynamic>>.from(vendorsResponse);
        authors = List<Map<String, dynamic>>.from(authorsResponse);
        if (offerResponse.isNotEmpty) {
          specialOffer = offerResponse.first;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          title: const Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        // === Special Offer ===
        if (specialOffer != null) _buildSpecialOffer(),

        // === Top of Week ===
        if (topWeekBooks.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Top of Week',
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BooksListPage()),
              );
            },
          ),
          _buildBooksList(topWeekBooks),
        ],

        // === Best Vendors ===
        if (vendors.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Best Vendors',
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VendorsPage()),
              );
            },
          ),
          _buildVendorsList(),
        ],

        // === Authors ===
        if (authors.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Authors',
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorsPage()), // ✅
              );
            },
          ),
          _buildAuthorsList(),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  // === Special Offer Card ===
  Widget _buildSpecialOffer() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF54408C), Color(0xFF8B5A9F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        specialOffer!['title'] ?? 'Special Offer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discount ${specialOffer!['discount'] ?? 25}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF54408C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(specialOffer!['cta_text'] ?? 'Order Now'),
                      ),
                    ],
                  ),
                ),
                if (specialOffer!['image_url'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      specialOffer!['image_url'],
                      height: 100,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: 80,
                        color: Colors.white24,
                        child: const Icon(Icons.book, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === Section Header ===
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: onSeeAll, child: const Text("See All")),
          ],
        ),
      ),
    );
  }

  // === Book List ===
  Widget _buildBooksList(List<Map<String, dynamic>> books) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 280,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _buildBookCard(book, context);
          },
        ),
      ),
    );
  }

  // === Vendors List ===
  Widget _buildVendorsList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return _buildVendorCard(vendor);
          },
        ),
      ),
    );
  }

  // === Authors List ===
  Widget _buildAuthorsList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: authors.length,
          itemBuilder: (context, index) {
            final author = authors[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AuthorDetailsPage(authorId: author['id']), // ✅
                  ),
                );
              },
              child: _buildAuthorCard(author),
            );
          },
        ),
      ),
    );
  }

  // === Book Card ===
  Widget _buildBookCard(Map<String, dynamic> book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailsPage(bookId: (book['id'] as int)),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                book['cover_url'] ?? '',
                height: 200,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book['title'] ?? 'Unknown Title',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${book['price']?.toString() ?? '0.00'}',
              style: const TextStyle(
                color: Color(0xFF54408C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Vendor Card ===
  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: vendor['image_url'] != null
                  ? Image.network(
                      vendor['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.store, size: 40),
                    )
                  : const Icon(Icons.store, size: 40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vendor['name'] ?? 'Unknown Vendor',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // === Author Card ===
  Widget _buildAuthorCard(Map<String, dynamic> author) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: author['image_url'] != null
                  ? Image.network(
                      author['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 30),
                    )
                  : const Icon(Icons.person, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            author['name'] ?? 'Unknown Author',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
