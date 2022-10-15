import 'package:bikesharing/firebase_options.dart';
import 'package:bikesharing/screens/auth/auth_screen.dart';
import 'package:bikesharing/screens/home_screen.dart';
import 'package:bikesharing/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final initialization =
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
      ],
      child: FutureBuilder(
        future: initialization,
        builder: (context, appSnapshot) {
          if (appSnapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          return Consumer<Auth>(
            builder: (ctx, auth, _) => MaterialApp(
              title: 'Bikesharing',
              theme: ThemeData(
                primarySwatch: Colors.green,
              ),
              supportedLocales: const [
                Locale('sk', 'SK'),
                Locale('en', 'GB'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                // THIS CLASS WILL BE ADDED LATER
                // A class which loads the translations from JSON files
                // Built-in localization of basic text for Material widgets
                GlobalMaterialLocalizations.delegate,
                // Built-in localization for text direction LTR/RTL
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: auth.isAuth
                  ? const HomeScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const SplashScreen()
                              : const AuthScreen(),
                    ),
            ),
          );
        },
      ),
    );
  }
}
