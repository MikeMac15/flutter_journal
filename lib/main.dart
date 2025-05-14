import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:journal/firebase_options.dart';
import 'package:journal/pages/home_page.dart';
import 'package:journal/pages/login_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Explicitly ask for LOCAL persistence in the browser
  if (kIsWeb) {
    // Only web supports persistence modes
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, DBProvider>(
          // 1. create a “blank” DBProvider
          create: (_) => DBProvider(),
          // 2. whenever UserProvider changes, update DBProvider
          update: (context, userProv, dbProv) {
            // if the user just logged in…
            if (userProv.userId != null && dbProv!.userId != userProv.userId) {
              // set the new UID and re-init
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
    final loggedIn = context.watch<UserProvider>().isLoggedIn;
    return MaterialApp(
      home: loggedIn ? HomePage() : LoginPage(),
    );
  }
}
