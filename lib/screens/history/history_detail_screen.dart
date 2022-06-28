import 'package:bikesharing/helpers/location_helper.dart';
import 'package:bikesharing/models/rent.dart';
import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Rent history;

  const HistoryDetailScreen({Key? key, required this.history})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitudeStart: history.standStart == null
          ? history.locationStart?.latitude
          : history.standStart?.location.latitude,
      longitudeStart: history.standStart == null
          ? history.locationStart?.longitude
          : history.standStart?.location.longitude,
      latitudeEnd: history.standEnd == null
          ? history.locationEnd?.latitude
          : history.standEnd?.location.latitude,
      longitudeEnd: history.standEnd == null
          ? history.locationEnd?.longitude
          : history.standEnd?.location.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('História'),
      ),
      body: Image.network(staticMapImageUrl),
    );
  }
}
