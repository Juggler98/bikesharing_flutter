import 'package:bikesharing/helpers/location_helper.dart';
import 'package:bikesharing/models/history.dart';
import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  final History history;

  HistoryDetailScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitudeStart: history.locationStart.latitude,
        longitudeStart: history.locationStart.longitude,
        latitudeEnd: history.locationEnd.latitude,
        longitudeEnd: history.locationEnd.longitude);

    return Scaffold(
      appBar: AppBar(title: Text('História'),),
      body: Container(
        child: Image.network(staticMapImageUrl),
      ),
    );
  }
}
