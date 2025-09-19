import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthorDetailsPage extends StatefulWidget {
  final int authorId;
  const AuthorDetailsPage({super.key, required this.authorId});

  @override
  State<AuthorDetailsPage> createState() => _AuthorDetailsPageState();
}

class _AuthorDetailsPageState extends State<AuthorDetailsPage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? author;
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    try {
      final authorResponse = await _supabase
          .from('authors')
          .select()
          .eq('id', widget.authorId)
          .single();

      final booksResponse = await _supabase
          .from('books')
          .select()
          .eq('author_id', widget.authorId);

      setState(() {
        author = authorResponse;
        books = List<Map<String, dynamic>>.from(booksResponse);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading author: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (author == null) {
      return const Scaffold(body: Center(child: Text("Author not found")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Authors")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: author!['image_url'] != null
                      ? NetworkImage(author!['image_url'])
                      : null,
                  child: author!['image_url'] == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author!['name'] ?? 'Unknown Author',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        author!['role'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(
                            Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text("(4.0)"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // About section
            const Text(
              "About",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              author!['bio'] ?? 'No biography available.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Products (books)
            const Text(
              "Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: book['image_url'] != null
                                ? Image.network(
                                    book['image_url'],
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.book,
                                      size: 50,
                                      color: Colors.black45,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book['title'] ?? 'Untitled',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "\$${book['price'] ?? '0.00'}",
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
