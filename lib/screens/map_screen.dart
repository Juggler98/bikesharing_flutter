import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:bikesharing/constants.dart';
import 'package:bikesharing/helpers/app.dart';
import 'package:bikesharing/models/bike.dart';
import 'package:bikesharing/models/rent.dart';
import 'package:bikesharing/models/station.dart';
import 'package:bikesharing/models/vehicle_type.dart';
import 'package:bikesharing/widgets/bottom_timer.dart';
import 'package:bikesharing/widgets/buttons/code_button.dart';
import 'package:bikesharing/widgets/rent_bike_item.dart';
import 'package:bikesharing/widgets/stop_timer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../widgets/buttons/scanner_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin<MapScreen> {
  @override
  bool get wantKeepAlive => true;

  ClusterManager? _manager;
  GoogleMapController? _googleMapController;
  SharedPreferences? _prefs;
  Map<String, dynamic>? _extractedMapData;

  final _controller = Completer();
  Set<Marker> markers = {};

  var _isMapLoading = false;
  var _areMarkersLoading = true;

  // List<Station> items = [
  //   for (int i = 1; i < 10; i++)
  //     Station(
  //         name: 'S',
  //         id: i,
  //         location: LatLng(49.2 + i * 0.001, 18.7 + i * 0.001),
  //         capacity: 10),
  // ];

  // void _addTempBikes() {
  //   final random = Random();
  //   for (int i = 1; i < 8; i++) {
  //     Bike bike = Bike(id: random.nextInt(1000));
  //     items[0].addBike(bike);
  //   }
  //   for (int i = 1; i < 4; i++) {
  //     Bike bike = Bike(id: random.nextInt(1000));
  //     items[1].addBike(bike);
  //   }
  //   for (int i = 1; i < 10; i++) {
  //     Bike bike = Bike(id: random.nextInt(1000));
  //     items[3].addBike(bike);
  //   }
  //   for (int i = 1; i < 3; i++) {
  //     Bike bike = Bike(id: random.nextInt(1000));
  //     items[6].addBike(bike);
  //   }
  //   for (int i = 1; i < 2; i++) {
  //     Bike bike = Bike(id: random.nextInt(1000));
  //     items[7].addBike(bike);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      //_addTempBikes();
    }
    _loadStandsFromServer();
    _loadRide();
    SharedPreferences.getInstance().then((value) {
      _prefs = value;
      if (_prefs!.containsKey('mapData')) {
        _extractedMapData =
            json.decode(_prefs!.getString('mapData')!) as Map<String, dynamic>;
      }
    });
    if (mounted) {
      _manager = _initClusterManager();
    }
  }

  void _loadStandsFromServer() async {
    final url = Uri.parse('http://$ipAddress:$port/api/v1/stations');
    //try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as List<dynamic>;
      App.bikes.clear();
      App.stations.clear();
      for (var s in jsonResponse) {
        final bikes = s['bikes'];

        final station = Station(
          name: s['name'],
          id: s['id'],
          location: LatLng(
            s['latitude'],
            s['longitude'],
          ),
          capacity: s['capacity'],
        );

        for (var b in bikes) {
          final bike = Bike(
            id: b['id_bike'],
            stand: station,
            location: LatLng(b['lat'] * 1.0, b['lon'] * 1.0),
          );
          station.addBike(bike);
          App.bikes.add(bike);
        }

        App.stations.add(station);
      }
      _loadStands();
      if (kDebugMode) {
        //print('Response body: ${response.body}');
      }
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
    // } catch (error) {
    if (kDebugMode) {
      //print(error);
    }
    //}
    if (mounted) {
      setState(() {
        _areMarkersLoading = false;
      });
    }
  }

  void _loadRide() async {
    final url = Uri.parse('http://$ipAddress:$port/api/v1/rent/actualRent/1');
    try {
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);

        final jsonResponse = jsonDecode(response.body) as List<dynamic>;

        final f = jsonResponse.first;
        print(jsonResponse.length);

        LatLng locStart = const LatLng(1.0, 1.0);
        if (f['start_lat'] != null) {
          locStart = LatLng(f['start_lat'] * 1.0, f['start_lon'] * 1.0);
        }
        if (f['id_station'] != null) {
          try {
            final startStation = App.stations
                .firstWhere((element) => element.id == f['id_station']);
            locStart = LatLng(startStation.location.latitude,
                startStation.location.longitude);
          } catch (error) {
            if (kDebugMode) {
              print(error);
            }
          }
        }

        Bike? bike;

        final url =
            Uri.parse('http://$ipAddress:$port/api/v1/bikes/${f['id_bike']}');
        try {
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);
            bike = Bike(id: jsonResponse['bike']['id_bike']);
          }
        } catch (error) {
          if (kDebugMode) {
            print(error);
          }
        }

        Rent ride = Rent(
          bike: bike!,
          id: f['id_rent'],
          startDate: DateTime.parse(f['start_rent_date']),
          locationStart: locStart,
          vehicleType: VehicleType.bike,
        );

        setState(() {
          App.user.actualRides.add(ride);
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Station>(App.stations, _updateMarkers,
        markerBuilder: _markerBuilder,
        extraPercent: 0.2,
        stopClusteringZoom: 12.0);
  }

  void _updateMarkers(Set<Marker> markers) {
    if (mounted) {
      setState(() {
        this.markers = markers;
      });
    }
  }

  var firstLoad = false;

  // void _moveCamera(double latitude, double longitude) {
  //   try {
  //     _googleMapController!.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         (CameraPosition(
  //           target: LatLng(latitude, longitude),
  //           zoom: 14,
  //         )),
  //       ),
  //     );
  //     firstLoad = true;
  //   } catch (error) {
  //     if (kDebugMode) {
  //       print(error);
  //     }
  //   }
  // }

  LocationData? locationData;

  void _changeLastLocation() async {
    try {
      final locationData = await Location().getLocation();
      final latitude = locationData.latitude;
      final longitude = locationData.longitude;
      this.locationData = locationData;
      // if (mounted) _moveCamera(latitude!, longitude!);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void _askForLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _changeLastLocation();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void _toLatestPosition() {
    try {
      if (_extractedMapData != null) {
        if (mounted) {
          _googleMapController!.moveCamera(
            CameraUpdate.newCameraPosition(
              (CameraPosition(
                target: LatLng(
                    _extractedMapData!['lat']!, _extractedMapData!['lon']!),
                zoom: _extractedMapData!['zoom']!,
              )),
            ),
          );
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  var isInit = true;

  void _loadStands() async {
    if (mounted) {
      setState(() {
        _areMarkersLoading = true;
      });
    } else {
      return;
    }

    if (_manager == null) {
      return;
    }

    _manager?.setItems(App.stations.toList());

    if (mounted) {
      setState(() {
        _areMarkersLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_googleMapController != null) {
      _googleMapController?.dispose();
    }
    markers.clear();
  }

  void _openDialog(int id) {
    App.openDialog(id, context);
    setState(() {});
  }

  void _stopRide() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.QUESTION,
      animType: AnimType.BOTTOMSLIDE,
      headerAnimationLoop: false,
      body: const Text('Ukončiť jazdu?'),
      btnOkText: 'Áno',
      btnOkOnPress: () async {
        final url = Uri.parse('http://$ipAddress:$port/api/v1/rent/endRent');

        final response = await http.post(
          url,
          body: {
            "id_rent": App.user.actualRides.first.id.toString(),
            "id_station": "17",
          },
        );

        print(App.user.actualRides.first.id);

        setState(() {
          App.user.actualRides.removeAt(0);
        });
        _loadStandsFromServer();
        Fluttertoast.showToast(
          msg: 'Jazda ukončená',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.black54,
        );
      },
    ).show();
  }

  void _unlockBike(BuildContext context, Bike bike, Station stand) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.QUESTION,
      animType: AnimType.BOTTOMSLIDE,
      headerAnimationLoop: false,
      body: Text('Odomknúť bicykel ${bike.id}?'),
      btnOkText: 'Áno',
      btnOkOnPress: () async {
        if (App.user.actualRides.isEmpty) {
          final url = Uri.parse('http://$ipAddress:$port/api/v1/rent/new');
          print(bike.id);
          final response = await http.post(
            url,
            body: {
              "id_bike": bike.id.toString(),
              "id_user": "1",
            },
          );

          if (response.statusCode == 200) {
            print(bike.id);

            print(response.body);

            final jsonResponse =
                jsonDecode(response.body) as Map<String, dynamic>;

            Rent ride = Rent(
              bike: bike,
              id: jsonResponse['id_rent'],
              startDate: DateTime.now(),
              locationStart: stand.location,
              vehicleType: VehicleType.bike,
            );

            setState(() {
              App.user.actualRides.add(ride);
              bike.stand = null;
              stand.bikes.removeWhere((element) => element.id == bike.id);
            });
            Fluttertoast.showToast(
              msg: 'Bicykel bol odomknutý',
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.black54,
            );
          } else {
            print(response.statusCode);
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Môžeš si požičať len jeden bicykel',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black54,
          );
        }
        Navigator.of(context).pop();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Opacity(
                opacity: _isMapLoading ? 0 : 1,
                child: !mounted
                    ? Row()
                    : GoogleMap(
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        compassEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              _extractedMapData == null
                                  ? 0
                                  : _extractedMapData?['lat']!,
                              _extractedMapData == null
                                  ? 0
                                  : _extractedMapData?['lon']!),
                          zoom: _extractedMapData == null
                              ? 0
                              : _extractedMapData?['zoom']!,
                        ),
                        markers: markers,
                        onTap: (LatLng position) {
                          if (locationData != null) {
                            _getMarkers(locationData!, position);
                          }
                        },
                        polylines: _polylineList.toSet(),
                        onMapCreated: (GoogleMapController? controller) {
                          if (mounted) {
                            _controller.complete(controller);
                            if (_manager != null) {
                              _manager!.setMapId(controller!.mapId);
                            }
                            _googleMapController = controller;
                            if (mounted) _toLatestPosition();
                            //_loadStands();
                            if (mounted) _askForLocation();
                            _isMapLoading = false;
                            if (mounted && _manager != null) {
                              _manager?.updateMap();
                            }
                          }
                        },
                        onCameraMove: (CameraPosition position) {
                          if (_manager != null) {
                            _manager?.onCameraMove(position);
                          }
                          final mapData = json.encode({
                            'lat': position.target.latitude,
                            'lon': position.target.longitude,
                            'zoom': position.zoom,
                          });
                          if (_prefs != null) {
                            _prefs?.setString('mapData', mapData);
                          }
                        },
                        onCameraIdle: () {
                          if (mounted && _manager != null) {
                            _manager?.updateMap();
                          }
                        },
                      ),
              ),
              if (_areMarkersLoading)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 42.0, horizontal: 8),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Card(
                      elevation: 2,
                      color: Colors.grey.withOpacity(0.9),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          'Načítavanie',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!kIsWeb) const ScannerButton() else const CodeButton(),
            ],
          ),
        ),
        if (App.user.actualRides.isNotEmpty)
          BottomTimer('Jazda prebieha', _stopRide,
              App.user.actualRides.first.startDate),
        if (App.user.reservations.isNotEmpty)
          BottomTimer(
            'Rezervácia prebieha',
            () {
              setState(() {
                App.user.reservations.clear();
              });
            },
            App.user.reservations.first.startDate,
          ),
      ],
    );
  }

  void _getMarkers(LocationData start, LatLng end) async {
    List<Map<String, dynamic>> newLocations = [];
    _polylineList.clear();
    _polylinePoints.clear();
    final url = Uri.parse('http://$ipAddress:$port/api/v1/path/shortestNearestPoints');
    final response = await http.post(
      url,
      body: {
        "x1": start.longitude,
        "y1": start.latitude,
        "x2": end.longitude,
        "y2": start.latitude,
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final path = jsonResponse['path'] as List<dynamic>;
      final double distance = jsonResponse['total_distance'] / 1000;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${distance.toStringAsFixed(2)} km')));
      for (var p in path) {
        newLocations.add({
          'lat': p['lat'],
          'lon': p['lon'],
        });
      }
    }
    setState(() {
      for (int i = 0; i < newLocations.length; i++) {
        var latitude = newLocations[i]['lat'];
        var longitude = newLocations[i]['lon'];
        if (i == newLocations.length - 1) {
          markers.add(
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

  final List<Polyline> _polylineList = [];
  final List<LatLng> _polylinePoints = [];

  Future<Marker> Function(Cluster<Station>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            Station stand = cluster.items.first;
            showModalBottomSheet(
                context: context,
                builder: (BuildContext buildContext) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Stojan ${stand.id}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        endIndent: 8,
                        indent: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Badge(
                          position: const BadgePosition(end: -24, top: -8),
                          padding: const EdgeInsets.all(4),
                          shape: BadgeShape.square,
                          borderRadius: const BorderRadius.all(
                              Radius.elliptical(200, 200)),
                          badgeColor:
                              stand.bikeCount > 0 ? Colors.green : Colors.red,
                          badgeContent: Text(
                              '${stand.bikeCount}/${stand.capacity}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.directions_bike,
                                color: Colors.blue,
                                size: 42,
                              ),
                              Text('Bicykle'),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        endIndent: 8,
                        indent: 8,
                      ),
                      Expanded(
                        child: ListView(
                          children: stand.bikes.map((bike) {
                            return RentBikeItem(
                              bike,
                              stand,
                              _unlockBike,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                });
          },
          icon: await _getMarkerBitmap(
            cluster.isMultiple ? 115 : 45,
            text: cluster.isMultiple ? cluster.count.toString() : '',
            color: cluster.isMultiple
                ? Colors.green
                : cluster.items.first.bikeCount > 0
                    ? Colors.green
                    : Colors.grey,
          ),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size,
      {String? text, required Color color}) async {
    if (kIsWeb) size = (size / 3).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = color;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            //size of number in cluster, over 1000 is need to resize
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
