import 'package:bikesharing/models/rent.dart';

class User {
  String id;
  final String email;
  List<Rent> actualRides = [];
  List<Rent> reservations = [];
  List<Rent> allRides = [];

  User({
    required this.id,
    required this.email,
  });
}
