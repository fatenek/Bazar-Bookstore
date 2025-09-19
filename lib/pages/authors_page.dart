import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'author_details_page.dart';

class AuthorsPage extends StatefulWidget {
  const AuthorsPage({super.key});

  @override
  State<AuthorsPage> createState() => _AuthorsPageState();
}

class _AuthorsPageState extends State<AuthorsPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> authors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    try {
      final response = await _supabase.from('authors').select();
      setState(() {
        authors = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading authors: $e')));
    }
  }

  Widget _buildAuthorTile(Map<String, dynamic> author) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: author['image_url'] != null
            ? NetworkImage(author['image_url'])
            : null,
        child: author['image_url'] == null ? const Icon(Icons.person) : null,
      ),
      title: Text(
        author['name'] ?? 'Unknown Author',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        author['role'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AuthorDetailsPage(authorId: author['id']),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authors")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: authors.length,
              itemBuilder: (context, index) => _buildAuthorTile(authors[index]),
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
    );
  }
}
