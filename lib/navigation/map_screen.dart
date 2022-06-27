import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:bikesharing/models/bike.dart';
import 'package:bikesharing/models/ride.dart';
import 'package:bikesharing/models/stand.dart';
import 'package:bikesharing/models/user.dart';
import 'package:bikesharing/models/vehicle_type.dart';
import 'package:bikesharing/widgets/code_button.dart';
import 'package:bikesharing/widgets/scanner_button.dart';
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

  final _user = User(
    id: '0',
    email: 'test',
  );

  List<Stand> items = [
    for (int i = 1; i < 10; i++)
      Stand(
          id: '$i',
          location: LatLng(49.2 + i * 0.001, 18.7 + i * 0.001),
          capacity: 10),
  ];

  void _loadStandsFromServer() async {
    //TODO: Change address if necessary
    final url = Uri.parse('http://172.20.10.2:3001/api/v1/stations');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final stands = jsonResponse['bikes'];
        var count = 0;
        for (var stand in stands) {
          items.add(Stand(
            id: '${count++}',
            location: LatLng(
              stand[4],
              stand[5],
            ),
            capacity: 10,
          ));
        }
        _loadStands();
        if (kDebugMode) {
          print('Response body: ${response.body}');
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
        _areMarkersLoading = false;
      });
    }
  }

  void _addTempBikes() {
    final random = Random();
    for (int i = 1; i < 8; i++) {
      Bike bike = Bike(id: '${random.nextInt(1000)}');
      items[0].addBike(bike);
    }
    for (int i = 1; i < 4; i++) {
      Bike bike = Bike(id: '${random.nextInt(1000)}');
      items[1].addBike(bike);
    }
    for (int i = 1; i < 10; i++) {
      Bike bike = Bike(id: '${random.nextInt(1000)}');
      items[3].addBike(bike);
    }
    for (int i = 1; i < 3; i++) {
      Bike bike = Bike(id: '${random.nextInt(1000)}');
      items[6].addBike(bike);
    }
    for (int i = 1; i < 2; i++) {
      Bike bike = Bike(id: '${random.nextInt(1000)}');
      items[7].addBike(bike);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStandsFromServer();
    _addTempBikes();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Stand>(items, _updateMarkers,
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

  void _changeLastLocation() async {
    try {
      //final locationData = await Location().getLocation();
      //final latitude = locationData.latitude;
      //final longitude = locationData.longitude;
      //if (mounted) _moveCamera(latitude!, longitude!);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  // void _showBottomShet() {
  //
  // }

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

    _manager?.setItems(items.toList());

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
        if (_user.actualRide != null)
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            color: Colors.green,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Jazda prebieha',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                StopTimer(_user.actualRide!.startDate),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.QUESTION,
                            animType: AnimType.BOTTOMSLIDE,
                            headerAnimationLoop: false,
                            body: const Text('Ukončiť jazdu?'),
                            btnOkText: 'Áno',
                            btnOkOnPress: () {
                              setState(() {
                                _user.actualRide = null;
                              });
                              Fluttertoast.showToast(
                                msg: 'Jazda ukončená',
                                toastLength: Toast.LENGTH_LONG,
                                backgroundColor: Colors.black54,
                              );
                            },
                          ).show();
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 8.0)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.redAccent),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Stop',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.stop,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<Marker> Function(Cluster<Stand>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            Stand stand = cluster.items.first;
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
                            return InkWell(
                              onTap: () async {
                                if (kDebugMode && !kIsWeb) {
                                  final parameters = DynamicLinkParameters(
                                    // The Dynamic Link URI domain. You can view created URIs on your Firebase console
                                    uriPrefix:
                                        'https://bikesharingf3e11.page.link',
                                    // The deep Link passed to your application which you can use to affect change
                                    link: Uri.parse(
                                        'https://bikesharingf3e11.page.link/?id=${bike.id}'),
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
                                    final shortDynamicLink =
                                        await FirebaseDynamicLinks.instance
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

                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.QUESTION,
                                  animType: AnimType.BOTTOMSLIDE,
                                  headerAnimationLoop: false,
                                  body: Text('Odomknúť bicykel ${bike.id}?'),
                                  btnOkText: 'Áno',
                                  btnOkOnPress: () {
                                    if (_user.actualRide == null) {
                                      Ride ride = Ride(
                                          id: Random().nextInt(100).toString(),
                                          startDate: DateTime.now(),
                                          locationStart: stand.location,
                                          vehicleType: VehicleType.bike);
                                      setState(() {
                                        _user.actualRide = ride;
                                      });
                                      Fluttertoast.showToast(
                                        msg: 'Bicykel bol odomknutý',
                                        toastLength: Toast.LENGTH_LONG,
                                        backgroundColor: Colors.black54,
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg:
                                            'Môžeš si požičať len jeden bicykel',
                                        toastLength: Toast.LENGTH_LONG,
                                        backgroundColor: Colors.black54,
                                      );
                                    }
                                    Navigator.of(buildContext).pop();
                                  },
                                ).show();
                              },
                              child: Card(
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 1, horizontal: 4),
                                child: ListTile(
                                    leading: const FittedBox(
                                      child: Icon(
                                        Icons.directions_bike,
                                        color: Colors.blue,
                                        size: 54,
                                      ),
                                    ),
                                    title: Text(bike.id,
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold))),
                              ),
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
