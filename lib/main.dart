import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal/firebase_options.dart';
import 'package:journal/pages/login_page.dart';
import 'package:journal/pages/myhomepage.dart';
import 'package:journal/pages/questionWalls/questions/provider/question_provider.dart';
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => QuestionsProvider()),
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
       ChangeNotifierProxyProvider<UserProvider, DBProvider>(
  create: (_) => DBProvider(),
  update: (context, userProv, dbProv) {
    dbProv!.userId = userProv.userId;
    return dbProv;
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
    final themeProv = context.watch<ThemeProvider>();

    Widget appContent(BuildContext context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProv.themeData,
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
          home: loggedIn ? const MyHomePage() : const LoginPage(),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return appContent(context);
        }

        // WRAP WITH DIRECTIONALITY TO FIX THE ERROR
        return Directionality(
          textDirection: TextDirection.ltr, // Standard left-to-right direction
          child: Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: DeviceFrame(
                  device: Devices.android.googlePixel9,
                  isFrameVisible: true,
                  orientation: Orientation.portrait,
                  screen: appContent(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
