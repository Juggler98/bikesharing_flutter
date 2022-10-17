import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bikesharing/models/station.dart';
import 'package:bikesharing/widgets/progress_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../helpers/app.dart';
import '../../models/bike.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  var isLoading = true;

  void _loadBikesFromServer() async {
    final url = Uri.parse('http://$ipAddress:$port/api/v1/bikes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        App.bikes.clear();
        final bikes = jsonResponse['bikes'];
        for (var b in bikes) {
          final bike = Bike(
            id: b['id_bike'],
            stand: b['id_station'] == null
                ? null
                : App.stations.firstWhere(
                    (element) => element.id == b['id_station'],
                    orElse: () => Station(
                        id: 0, name: 'a', location: LatLng(0, 0), capacity: 0)),
            location: LatLng(b['lat'] * 1.0, b['lon'] * 1.0),
          );
          App.bikes.add(bike);
        }
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}.');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBikesFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bicykle'),
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : ListView(
              children: App.bikes.map((bike) {
                return InkWell(
                  onTap: () async {
                    final textFields = [
                      const DialogTextField(hintText: 'ID stanice'),
                    ];
                    final result = await showTextInputDialog(
                        context: context,
                        textFields: textFields,
                        title: 'Nastav stanicu');

                    if (result == null) {
                      return;
                    }

                    final station = result[0];

                    print(station);
                    try {
                      final url = Uri.parse(
                          'http://$ipAddress:$port/api/v1/bikes/${bike.id}');

                      final data = {
                        'id_station': station.toString(),
                        'lat': 1.0.toString(),
                        'lon': 1.0.toString(),
                      };

                      final b = {
                        "id_station": station.toString(),
                        "lat": "1.0",
                        "lon": "1.0"
                      };
                      var body = json.encode(data);
                      print(body);
                      final response = await http.patch(url, body: b);
                      if (response.statusCode == 200) {}
                      print(response.statusCode);
                    } catch (error) {
                      print('Error: $error');
                    }
                  },
                  child: Card(
                    elevation: 0,
                    margin:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                    child: ListTile(
                        leading: const FittedBox(
                          child: Icon(
                            Icons.directions_bike,
                            color: Colors.blue,
                            size: 54,
                          ),
                        ),
                        title: Column(
                          children: [
                            Text(bike.id.toString(),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(
                                'Stanica: ${bike.stand == null ? '' : bike.stand!.id}'),
                            Text('Poloha: ${bike.location}'),
                          ],
                        )),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
