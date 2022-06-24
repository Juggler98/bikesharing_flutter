import 'dart:math';

import 'package:bikesharing/models/ride.dart';
import 'package:bikesharing/models/vehicle_type.dart';
import 'package:bikesharing/screens/history_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({Key? key}) : super(key: key);

  final List<Ride> history = [
    for (int i = 1; i < 100; i++)
      Ride(
        id: '$i',
        locationStart: LatLng(
            49.21 + Random().nextDouble(), 18.71 + Random().nextDouble()),
        locationEnd: LatLng(
            49.21 + Random().nextDouble(), 18.71 + Random().nextDouble()),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(minutes: Random().nextInt(50))),
        vehicleType: Random().nextDouble() < 0.8
            ? VehicleType.bike
            : VehicleType.scooter,
        price: Random().nextInt(400) * 1.0,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('História jázd'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: history.map((history) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => HistoryDetailScreen(history: history),
              ));
            },
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
              child: ListTile(
                leading: Icon(
                  history.vehicleType == VehicleType.bike
                      ? Icons.directions_bike
                      : Icons.electric_scooter,
                  color: Colors.blue,
                  size: 30,
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${history.locationEnd != null ? (Geolocator.distanceBetween(history.locationStart.latitude, history.locationStart.longitude, history.locationEnd!.latitude, history.locationEnd!.longitude) / 100).ceil() / 10 : '?'} km - ${history.endDate != null ? history.endDate?.difference(history.startDate).inMinutes : DateTime.now().difference(history.startDate).inMinutes} min',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat.yMd(Localizations.localeOf(context).toString()).format(history.startDate)} ${DateFormat.Hm(Localizations.localeOf(context).toString()).format(history.startDate)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: history.price != null
                    ? Text(
                        '${history.price! / 100} €',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
