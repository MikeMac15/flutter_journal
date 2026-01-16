import 'package:flutter/material.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/pages/myhomepage.dart';
import 'package:journal/pages/questionWalls/questions/provider/question_provider.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // If user is already cached/logged in, go to DB init
    if (userProvider.userId != null) {
      _initDBAndNavigate();
    }
  }

  Future<void> _initDBAndNavigate() async {
    setState(() => _isLoading = true);
    try {
      final dbProvider = Provider.of<DBProvider>(context, listen: false);
      await dbProvider.init();
      if (mounted) _navToHomePage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.signIn();
      // Only proceed if sign in actually happened (didn't cancel)
      if (userProvider.isLoggedIn) {
        await _initDBAndNavigate();
      } else {
         setState(() => _isLoading = false);
      }
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $error')),
        );
      }
    }
  }

void _handleDemoLogin() {
    setState(() => _isLoading = true);
    
    // 1. User Provider (Auth)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.enterDemoMode();

    // 2. DB Provider (Journal Entries)
    final dbProvider = Provider.of<DBProvider>(context, listen: false);
    dbProvider.enableDemoMode();

    // 3. Questions Provider (NEW - Switch to Mock Data)
    final questionsProvider = Provider.of<QuestionsProvider>(context, listen: false);
    questionsProvider.enableDemoMode();

    // 4. Navigate
    _navToHomePage();
  }

  @override
  Widget build(BuildContext context) {
    // You can access theme here to match your app styling
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or App Name Area
              const Icon(Icons.menu_book_rounded, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 16),
              Text(
                "Photo Journal",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Capture memories, thoughts, and moments.",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),

              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                // 1. Google Sign In (Standard)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                    onPressed: _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text("OR", style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ]),
                
                const SizedBox(height: 16),

                // 2. Recruiter / Demo Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Demo (Recruiter Mode)'),
                    onPressed: _handleDemoLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pink.shade400,
                      side: BorderSide(color: Colors.pink.shade200, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                Text(
                  "Explore the app populated with sample data.\nNo login or account required.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}