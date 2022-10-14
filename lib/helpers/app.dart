import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bikesharing/models/bike.dart';
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
}
