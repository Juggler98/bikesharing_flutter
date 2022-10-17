import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:bikesharing/models/rent.dart';
import 'package:bikesharing/models/station.dart';
import 'package:bikesharing/models/vehicle_type.dart';
import 'package:bikesharing/screens/history/history_detail_screen.dart';
import 'package:bikesharing/widgets/progress_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../helpers/app.dart';
import '../../models/bike.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Rent> history = [
    // for (int i = 1; i < 100; i++)
    //   Rent(
    //     bike: Bike(id: 1),
    //     id: i,
    //     locationStart: LatLng(
    //         49.21 + Random().nextDouble(), 18.71 + Random().nextDouble()),
    //     locationEnd: LatLng(
    //         49.21 + Random().nextDouble(), 18.71 + Random().nextDouble()),
    //     startDate: DateTime.now(),
    //     endDate: DateTime.now().add(Duration(minutes: Random().nextInt(50))),
    //     vehicleType: Random().nextDouble() < 0.8
    //         ? VehicleType.bike
    //         : VehicleType.scooter,
    //     price: Random().nextInt(400) * 1.0,
    //   ),
  ];

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final url = Uri.parse('http://$ipAddress:$port/api/v1/history/1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as List<dynamic>;
        for (var h in jsonResponse) {
          LatLng locStart = LatLng(1.0, 1.0);
          LatLng locEnd = LatLng(1.0, 1.0);
          try {
            locStart = LatLng(h['start_lat'] * 1.0, h['start_lon'] * 1.0);
            locEnd = LatLng(h['start_lat'] * 1.0, h['start_lon'] * 1.0);
          } catch (error) {}

          if (h['id_station'] != null) {
            try {
              final startStation = App.stations
                  .firstWhere((element) => element.id == h['id_station']);
              locStart = LatLng(startStation.location.latitude,
                  startStation.location.longitude);
            } catch (error) {
              if (kDebugMode) {
                print(error);
              }
            }
          }
          if (h['id_station_end'] != null) {
            try {
              final endStation = App.stations
                  .firstWhere((element) => element.id == h['id_station_end']);
              locEnd = LatLng(
                  endStation.location.latitude, endStation.location.longitude);
            } catch (error) {
              if (kDebugMode) {
                print(error);
              }
            }
          }
          final rent = Rent(
            bike: Bike(id: h['id_bike']),
            id: h['id_rent'],
            locationStart: locStart,
            locationEnd: locEnd,
            startDate: DateTime.parse(h['start_rent_date']),
            endDate: DateTime.parse(h['end_rent_date']),
            vehicleType: VehicleType.bike,
            price: Random().nextInt(400) * 1.0,
          );
          history.add(rent);
        }
        setState(() {
          history = history.reversed.toList();
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('História jázd'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CustomProgressIndicator())
          : ListView(
              children: history.map((history) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => HistoryDetailScreen(history: history),
                    ));
                  },
                  child: Card(
                    elevation: 0,
                    margin:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
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
                              '${history.locationEnd != null ? (Geolocator.distanceBetween(history.standStart == null ? history.locationStart!.latitude : history.standStart!.location.latitude, history.standStart == null ? history.locationStart!.longitude : history.standStart!.location.longitude, history.standEnd == null ? history.locationEnd!.latitude : history.standEnd!.location.latitude, history.standEnd == null ? history.locationEnd!.longitude : history.standEnd!.location.longitude) / 100).ceil() / 10 : '?'} km - ${history.endDate != null ? history.endDate?.difference(history.startDate).inMinutes : DateTime.now().difference(history.startDate).inMinutes} min',
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
