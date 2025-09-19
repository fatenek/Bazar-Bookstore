import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/splash.dart';
import 'pages/sign_in.dart';
import 'pages/sign_up.dart';
import 'pages/forgot_password/passwor_choice.dart';
import 'pages/home.dart';
import 'pages/wishlist_tab.dart';
import 'pages/books_list.dart';
import 'pages/vendors_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jtlahdozatesxrfmjicj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0bGFoZG96YXRlc3hyZm1qaWNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxMzMzODgsImV4cCI6MjA3MzcwOTM4OH0.x9TDS14chp8wkXbdQoqj_XSFHhkPvBBQhRjI-vhlRjo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookstore',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      routes: {
        '/signin': (_) => const SignInPage(),
        '/signup': (_) => SignUpPage(),
        '/forgot': (_) => const ForgotPasswordChoicePage(),
        '/home': (_) => const HomePage(),
        '/wishlist': (context) => const WishlistTab(),
        '/books': (_) => const BooksListPage(),
        '/vendors': (_) => VendorsPage(),
      },
    );
  }
}
