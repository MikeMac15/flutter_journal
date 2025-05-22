import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journal/firebase_options.dart';
import 'package:journal/pages/home_page.dart';
import 'package:journal/pages/login_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:journal/providers/theme_provider.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(
    MultiProvider(
      providers: [
        // 1) First, make UserProvider available:
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // 2) Now that UserProvider exists, proxy it to ThemeProvider:
        ChangeNotifierProxyProvider<UserProvider, ThemeProvider>(
          create: (_) => ThemeProvider(),
          update: (context, userProv, themeProv) {
            final uid = userProv.userId;
            if (uid != null) {
              themeProv!.loadPreferences(uid);
            }
            return themeProv!;
          },
        ),

        // 3) Finally, the DBProvider proxy:
        ChangeNotifierProxyProvider<UserProvider, DBProvider>(
          create: (_) => DBProvider(),
          update: (context, userProv, dbProv) {
            if (userProv.userId != null && dbProv!.userId != userProv.userId) {
              dbProv.userId = userProv.userId;
              dbProv.init();
            }
            return dbProv!;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3) Watch login state
    final loggedIn = context.watch<UserProvider>().isLoggedIn;
    // 4) Watch ThemeProvider for dynamic theme
    final themeProv = context.watch<ThemeProvider>();

    return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: themeProv.themeData,
  // Wrap *all* routes in this gradient
  builder: (context, child) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProv.backgroundGradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  },
  home: loggedIn ? const HomePage() : const LoginPage(),
);
  }
}
