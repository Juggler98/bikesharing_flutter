import 'package:bikesharing/models/station.dart';
import 'package:bikesharing/models/vehicle_type.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bike.dart';

class Rent {
  final int id;
  final Bike bike;
  final DateTime startDate;
  final DateTime? endDate;
  final LatLng? locationStart;
  final LatLng? locationEnd;
  final Station? standStart;
  final Station? standEnd;
  final double? price;
  final VehicleType vehicleType;

  Rent({
    required this.id,
    required this.startDate,
    required this.bike,
    this.endDate,
    required this.locationStart,
    this.locationEnd,
    this.price,
    this.standStart,
    this.standEnd,
    required this.vehicleType,
  });
}
