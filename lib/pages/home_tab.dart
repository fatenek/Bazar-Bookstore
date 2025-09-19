import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'book_details.dart';
import 'books_list.dart';
import 'vendors_page.dart';
import 'authors_page.dart';
import 'author_details_page.dart';
import 'dart:async';

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

      final offerResponse = await _supabase.from('offers').select();

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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                const Text(
                  'Home',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          if (specialOffer != null) _buildSpecialOffer(),

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

          if (authors.isNotEmpty) ...[
            _buildSectionHeader(
              title: 'Authors',
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthorsPage()),
                );
              },
            ),
            _buildAuthorsList(),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSpecialOffer() {
    final offers = [
      specialOffer!,
      {
        'title': 'Flash Sale',
        'discount': 30,
        'cta_text': 'Shop Now',
        'image_url': specialOffer!['image_url'],
      },
      {
        'title': 'Weekend Deal',
        'discount': 40,
        'cta_text': 'Get Yours',
        'image_url': specialOffer!['image_url'],
      },
    ];

    return SliverToBoxAdapter(child: SpecialOfferCarousel(offers: offers));
  }

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
            return _buildBookCard(book);
          },
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailsPage(bookId: book['id']),
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
                book['image_url'] ?? '',
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

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
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
                    builder: (_) => AuthorDetailsPage(authorId: author['id']),
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

// === Special Offer Carousel ===
class SpecialOfferCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> offers;
  const SpecialOfferCarousel({super.key, required this.offers});

  @override
  State<SpecialOfferCarousel> createState() => _SpecialOfferCarouselState();
}

class _SpecialOfferCarouselState extends State<SpecialOfferCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.offers.length > 1) _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) {
        timer.cancel();
        return;
      }
      int nextPage = (_currentPage + 1) % widget.offers.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.offers.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
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
                                offer['title'] ?? 'Special Offer',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discount ${offer['discount'] ?? 25}%',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF54408C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(offer['cta_text'] ?? 'Order Now'),
                              ),
                            ],
                          ),
                        ),
                        if (offer['image_url'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              offer['image_url'],
                              height: 250,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 100,
                                    width: 80,
                                    color: Colors.white24,
                                    child: const Icon(
                                      Icons.book,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.offers.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF54408C)
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
