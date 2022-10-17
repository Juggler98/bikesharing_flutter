import 'package:bikesharing/helpers/app.dart';
import 'package:bikesharing/main_drawer.dart';
import 'package:bikesharing/screens/map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _setupDynamicLinks();
      _setupInteractedMessage();
      _setToken();
    }
  }

  void _setupDynamicLinks() async {
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final id = int.parse(initialLink.link.queryParameters['id'].toString());
      _openDialog(id);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final id =
          int.parse(dynamicLinkData.link.queryParameters['id'].toString());
      if (mounted) {
        _openDialog(id);
      }
    }).onError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    });
  }

  Future<void> _setupInteractedMessage() async {
    // Request permission for the iOs
    FirebaseMessaging.instance.requestPermission();

    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification != null) {}
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        var messageBody = message.data['body'];
        if (messageBody != null) {
          if (mounted) {
            if (ScaffoldMessenger.of(context).mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 10),
                content: GestureDetector(
                  child: Text(messageBody),
                  onTap: () {},
                ),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    final auth = Provider.of<Auth>(context, listen: false);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.userId)
          .update({
        'tokens': FieldValue.arrayUnion([token]),
      });
    } catch (error) {
      FirebaseFirestore.instance.collection('users').doc(auth.userId).set({
        'tokens': FieldValue.arrayUnion([token]),
      });
    }
  }

  void _setToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    await _saveTokenToDatabase(token!);
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);
  }

  void _openDialog(int id) {
    App.openDialog(id, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          const MapScreen(),
          Positioned(
            left: 10,
            top: kIsWeb ? 20 : 40,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.menu),
                color: Colors.black,
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
