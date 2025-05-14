import 'package:flutter/material.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:journal/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Check if user is already logged in and initialize the DB
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userId != null) {
      _initDB();
    }
  }

  // Function to initialize the DB
  Future<void> _initDB() async {
    final dbProvider = Provider.of<DBProvider>(context, listen: false);
    await dbProvider
        .init(); // Initialize DB (fetch journal entries and chapters)
  }

  void navToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // print('Sign in with Google button pressed');
            try {
              // Call the sign-in method from UserProvider
              await userProvider.signIn();
              // print('After signin before homepage navigation');
              // Initialize the DB and navigate to HomePage
              await _initDB();
              navToHomePage();
            } catch (error) {
              // print('Sign-in failed: $error');
              // Handle error (e.g., show error message)

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign-in failed: $error')),
                );
              }
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
