import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Stand extends ClusterItem {
  final String id;
  @override
  final LatLng location;

  Stand({
    required this.id,
    required this.location,
  });

}