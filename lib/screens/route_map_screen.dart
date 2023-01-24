import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class RouteMapScreen extends StatefulWidget {
  static const routeName = '/stone-locations-map';

  const RouteMapScreen({Key? key}) : super(key: key);

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late GoogleMapController _googleMapController;

  final List<Marker> _markerList = [];
  final List<Polyline> _polylineList = [];
  final List<LatLng> _polylinePoints = [];

  void _getMarkers() async {
    List<Map<String, dynamic>> newLocations = [];
    final url = Uri.parse('http://$ipAddress:$port/api/v1/path/shortest/mock');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final path = jsonResponse['path'] as List<dynamic>;
      final double distance = jsonResponse['total_distance'] / 1000;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${distance.toStringAsFixed(2)} km')));
      for (var p in path) {
        newLocations.add({
          'lat': p['lon'],
          'lon': p['lat'],
        });
      }
    }
    if (newLocations.isNotEmpty) {
      _googleMapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              newLocations[(newLocations.length / 2).ceil()]['lat'],
              newLocations[(newLocations.length / 2).ceil()]['lon'],
            ),
            zoom: 15,
          ),
        ),
      );
    }
    setState(() {
      for (int i = 0; i < newLocations.length; i++) {
        var latitude = newLocations[i]['lat'];
        var longitude = newLocations[i]['lon'];
        if (i == 0 || i == newLocations.length - 1) {
          _markerList.add(
            Marker(
              markerId: MarkerId(i.toString()),
              position: LatLng(
                latitude,
                longitude,
              ),
              icon: i == 0
                  ? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen)
                  : BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueViolet),
            ),
          );
        }
        _polylinePoints.add(
          LatLng(
            latitude,
            longitude,
          ),
        );
      }
      _polylineList.add(Polyline(
        polylineId: const PolylineId('a'),
        points: _polylinePoints,
        color: Colors.red,
        width: 4,
      ));
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  void setStateTrigger() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _googleMapController = controller;
              _getMarkers();
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 0,
            ),
            markers: _markerList.toSet(),
            polylines: _polylineList.toSet(),
          ),
        ],
      ),
    );
  }
}
