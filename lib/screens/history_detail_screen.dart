import 'package:bikesharing/helpers/location_helper.dart';
import 'package:bikesharing/models/ride.dart';
import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Ride history;

  const HistoryDetailScreen({Key? key, required this.history})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitudeStart: history.locationStart.latitude,
        longitudeStart: history.locationStart.longitude,
        latitudeEnd: history.locationEnd?.latitude,
        longitudeEnd: history.locationEnd?.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('História'),
      ),
      body: Image.network(staticMapImageUrl),
    );
  }
}
