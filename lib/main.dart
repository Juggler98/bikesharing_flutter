import 'package:bikesharing/firebase_options.dart';
import 'package:bikesharing/navigation/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    return FutureBuilder(
      future: initialization,
      builder: (context, appSnapshot) {
        if (appSnapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        return MaterialApp(
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
          home: const HomeScreen(),
        );
      },
    );
  }
}
