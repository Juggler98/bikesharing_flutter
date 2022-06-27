import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StaticMethods {
  static void openDialog(String? id, BuildContext context) {
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
        Navigator.of(context).pop();
      },
    ).show();
  }
}
