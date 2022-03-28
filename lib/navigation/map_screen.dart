import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:bikesharing/models/stand.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
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
  var _areMarkersLoading = false;

  List<Stand> items = [
    for (int i = 0; i < 10; i++)
      Stand(
          id: 'Stand $i',
          location: LatLng(48.848200 + i * 0.001, 2.319124 + i * 0.001)),
    for (int i = 0; i < 10; i++)
      Stand(
          id: 'Stand $i',
          location: LatLng(48.858265 - i * 0.001, 2.350107 + i * 0.001)),
    for (int i = 0; i < 10; i++)
      Stand(
          id: 'Stand $i',
          location: LatLng(48.858265 + i * 0.01, 2.350107 - i * 0.01)),
    for (int i = 0; i < 10; i++)
      Stand(
          id: 'Stand $i',
          location: LatLng(48.858265 - i * 0.1, 2.350107 - i * 0.01)),
    for (int i = 0; i < 10; i++)
      Stand(
          id: 'Stand $i',
          location: LatLng(48.858265 + i * 0.1, 2.350107 + i * 0.1)),
    for (int i = 0; i < 10; i++)
      Stand(
          id: 'Stand $i',
          location: LatLng(48.858265 + i * 1, 2.350107 + i * 1)),
  ];

  @override
  void initState() {
    super.initState();
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
        stopClusteringZoom: 9.0);
  }

  void _updateMarkers(Set<Marker> markers) {
    if (mounted) {
      setState(() {
        this.markers = markers;
      });
    }
  }

  var firstLoad = false;

  void _moveCamera(double latitude, double longitude) {
    try {
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          (CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 14,
          )),
        ),
      );
      firstLoad = true;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

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

  void _askForLocation() async {
    try {
      Location location = Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
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
                            _loadStands();
                            if (mounted) _askForLocation();
                            _isMapLoading = false;
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
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Card(
                      elevation: 2,
                      color: Colors.grey.withOpacity(0.9),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          'Loading',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
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
          onTap: () {},
          icon: await _getMarkerBitmap(
            cluster.isMultiple ? 115 : 45,
            text: cluster.isMultiple ? cluster.count.toString() : '',
            color: Colors.green,
          ),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size,
      {String? text, required Color color}) async {
    if (kIsWeb) size = (size / 2).floor();

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
