import 'package:bikesharing/models/bike.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Station extends ClusterItem {
  final int id;
  final String? name;
  @override
  final LatLng location;
  final List<Bike> bikes = <Bike>[];
  final int capacity;

  Station({required this.id, required this.name, required this.location, required this.capacity});

  void addBike(Bike bike) {
    bikes.add(bike);
  }

  int get bikeCount {
    return bikes.length;
  }

  @override
  String toString() {
    return '$id $location $capacity';
  }
}
