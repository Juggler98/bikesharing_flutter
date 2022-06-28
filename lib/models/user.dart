import 'package:bikesharing/models/rent.dart';

class User {
  final String id;
  final String email;
  List<Rent> actualRides = [];

  User({
    required this.id,
    required this.email,
  });
}
