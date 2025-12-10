// New AuthErrorPage widget
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journal/pages/journal_entry_page.dart';

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  Future<void> _signIn(BuildContext context) async {
    try {
      // Example: Sign in with email/password (replace with your auth method)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'test@example.com', // Replace with actual login logic
        password: 'password123',    // Replace with actual login logic
      );
      // After successful sign-in, go back to JournalEntryPage
    if (!context.mounted) return; // Ensure widget is still in the tree

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => JournalEntryPage()),
    );
  } catch (e) {
    if (!context.mounted) return; // Ensure widget is still in the tree

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-in failed: $e')),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Required'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'You are not signed in!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please sign in to access your journal.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signIn(context),
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                // Optionally, go back or exit the app
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}