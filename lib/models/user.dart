import 'package:bikesharing/models/ride.dart';

class User {
  final String id;
  final String email;
  Ride? actualRide;

  User({
    required this.id,
    required this.email,
    this.actualRide,
  });
}
