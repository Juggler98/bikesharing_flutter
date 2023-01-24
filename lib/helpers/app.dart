import 'dart:convert';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bikesharing/models/bike.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/rent.dart';
import '../models/station.dart';
import '../models/user.dart';
import '../models/vehicle_type.dart';

class App {
  static final List<Station> stations = [];
  static final List<Bike> bikes = [];

  static final user = User(
    id: '0',
    email: 'test',
  );

  static bool openDialog(int id, BuildContext context) {
    var value = false;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.QUESTION,
      animType: AnimType.BOTTOMSLIDE,
      headerAnimationLoop: false,
      body: Text('Odomknúť bicykel $id?'),
      btnOkText: 'Áno',
      btnOkOnPress: () async {
        if (App.user.actualRides.isEmpty) {
          final bike = App.bikes.firstWhere((element) => element.id == id);

          Rent ride = Rent(
            bike: bike,
            id: Random().nextInt(100),
            startDate: DateTime.now(),
            vehicleType: VehicleType.bike,
          );

          final url = Uri.parse('http://$ipAddress:$port/api/v1/rent/new');
          final response = await http.post(
            url,
            body: {
              "id_bike": bike.id,
              "id_user": 1,
            },
          );

          App.user.actualRides.add(ride);

          bike.stand?.bikes.remove(bike);
          bike.stand = null;

          Fluttertoast.showToast(
            msg: 'Bicykel bol odomknutý',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black54,
          );
          value = true;
        } else {
          Fluttertoast.showToast(
            msg: 'Môžeš si požičať len jeden bicykel',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black54,
          );
        }
        //Navigator.of(context).pop();
      },
    ).show();
    return value;
  }

  static Future<void> reportBike(String bikeId, BuildContext context) async {
    final actions = [
      const SheetAction(key: 1, label: 'Defekt'),
      const SheetAction(key: 2, label: 'Nejdú brzdy'),
      const SheetAction(key: 3, label: 'Problém s reťazou'),
      const SheetAction(key: 4, label: 'Problém s kolesom'),
      const SheetAction(key: 5, label: 'Chýba časť bicykla'),
    ];

    final reportType = await showModalActionSheet(
      context: context,
      actions: actions,
    );

    if (reportType == null) {
      return;
    }

    final url = Uri.parse(
        'https://us-central1-bikesharing-f3e11.cloudfunctions.net/reportNotify');
    try {
      final url2 = Uri.parse('http://$ipAddress:$port/api/v1/report');

      final body2 = {
        "id_bike": bikeId.toString(),
        "id_user": "1",
        "id_report_type": reportType.toString()
      };
      print(body2);
      final response = await http.post(url2, body: body2);
      if (response.statusCode == 200) {}
      print(response.statusCode);

      final data = {
        'userId': 'mfHfRPjbWPaEc2OqHnW5TzYRDjI3',
        'bikeId': bikeId,
        'reportType': reportType
      };
      var body = json.encode(data);
      //final response = await http.post(url, body: body);
      await Future.delayed(const Duration(milliseconds: 500));
      FirebaseFunctions.instance.httpsCallable('reportNotify2').call([
        'mfHfRPjbWPaEc2OqHnW5TzYRDjI3',
        bikeId.toString(),
        reportType.toString(),
      ]);
      Fluttertoast.showToast(msg: 'Hlásenie odoslané.');
      //print('response ' + response.toString());
    } catch (error) {
      print('ERROR: $error');
    }
  }
}
