import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bikesharing/main_drawer.dart';
import 'package:bikesharing/navigation/map_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    }
  }

  void _setupDynamicLinks() async {
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final id = initialLink.link.queryParameters['id'];
      _openDialog(id);
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final id = dynamicLinkData.link.queryParameters['id'];
      if (mounted) {
        _openDialog(id);
      }
    }).onError((error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    });
  }

  void _openDialog(String? id) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.QUESTION,
      animType: AnimType.BOTTOMSLIDE,
      headerAnimationLoop: false,
      body: Text('Odomknúť bicykel $id?'),
      btnOkText: 'Áno',
      btnOkOnPress: () {
        // Ride ride = Ride(
        //     id: Random().nextInt(100).toString(),
        //     startDate: DateTime.now(),
        //     locationStart: stand.location,
        //     vehicleType: VehicleType.bike);
        Fluttertoast.showToast(
          msg: 'Bicykel bol odomknutý',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.black54,
        );
      },
    ).show();
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
