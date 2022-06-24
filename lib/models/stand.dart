import 'package:bikesharing/models/bike.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Stand extends ClusterItem {
  final String id;
  @override
  final LatLng location;
  final List<Bike> bikes = <Bike>[];
  final int capacity;

  Stand({
    required this.id,
    required this.location,
    required this.capacity
  });

  void addBike(Bike bike) {
    bikes.add(bike);
  }

  int get bikeCount {
    return bikes.length;
  }

}
