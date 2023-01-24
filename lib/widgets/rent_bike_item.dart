import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bikesharing/models/station.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../helpers/app.dart';
import '../models/bike.dart';
import '../models/rent.dart';

class RentBikeItem extends StatefulWidget {
  final Bike bike;
  final Station stand;
  final Function unlockTrigger;

  const RentBikeItem(this.bike, this.stand, this.unlockTrigger, {Key? key})
      : super(key: key);

  @override
  State<RentBikeItem> createState() => _RentBikeItemState();
}

class _RentBikeItemState extends State<RentBikeItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: ListTile(
          onLongPress: () async {
            await App.reportBike(widget.bike.id.toString(), context);
          },
          onTap: () async {
            print('a');
            if (kDebugMode && !kIsWeb) {
              final parameters = DynamicLinkParameters(
                // The Dynamic Link URI domain. You can view created URIs on your Firebase console
                uriPrefix: 'https://bikesharingf3e11.page.link',
                // The deep Link passed to your application which you can use to affect change
                link: Uri.parse(
                    'https://bikesharingf3e11.page.link/?id=${widget.bike.id}'),
                // Android application details needed for opening correct app on device/Play Store
                androidParameters: const AndroidParameters(
                  packageName: 'com.belsoft.bikesharing',
                  minimumVersion: 1,
                ),
                // iOS application details needed for opening correct app on device/App Store
                iosParameters: const IOSParameters(
                  bundleId: 'com.belsoft.bikesharing',
                  minimumVersion: '1',
                ),
              );

              try {
                final shortDynamicLink = await FirebaseDynamicLinks.instance
                    .buildShortLink(parameters);
                final uri = shortDynamicLink.shortUrl;
                if (kDebugMode) {
                  print(uri);
                }
              } catch (error) {
                if (kDebugMode) {
                  print('Error: $error');
                }
              }
            }
            print('a');
            widget.unlockTrigger(context, widget.bike, widget.stand);
          },
          leading: const FittedBox(
            child: Icon(
              Icons.directions_bike,
              color: Colors.blue,
              size: 54,
            ),
          ),
          title: Text(
            widget.bike.id.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.timelapse),
            onPressed: () async {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.QUESTION,
                animType: AnimType.BOTTOMSLIDE,
                headerAnimationLoop: false,
                body: Text('Rezervovať bicykel ${widget.bike.id}?'),
                btnOkText: 'Áno',
                btnCancelOnPress: () {},
                btnCancelText: 'Zrušiť',
                btnOkOnPress: () async {
                  App.user.reservations.add(Rent.getDummyRent());
                },
              ).show();
            },
          ),
        ),
      ),
    );
  }
}
