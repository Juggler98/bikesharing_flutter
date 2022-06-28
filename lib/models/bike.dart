import 'package:bikesharing/models/station.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Bike {
  final int id;
  final LatLng? location;
  final Station? stand;

  Bike({
    required this.id,
    this.location,
    this.stand,
  });

}


