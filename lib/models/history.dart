import 'package:bikesharing/models/vehicle_type.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class History {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final LatLng locationStart;
  final LatLng locationEnd;
  final double price;
  final VehicleType vehicleType;

  History({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.locationStart,
    required this.locationEnd,
    required this.price,
    required this.vehicleType
  });

}