import 'package:bikesharing/models/vehicle_type.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ride {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final LatLng locationStart;
  final LatLng? locationEnd;
  final double? price;
  final VehicleType vehicleType;

  Ride({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.locationStart,
    this.locationEnd,
    this.price,
    required this.vehicleType,
  });
}
