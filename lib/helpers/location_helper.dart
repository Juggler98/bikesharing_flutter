import 'keys.dart';

class LocationHelper {
  static String generateLocationPreviewImage(
      {double? latitudeStart,
      double? longitudeStart,
      double? latitudeEnd,
      double? longitudeEnd}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitudeStart,$longitudeStart&zoom=9&size=600x300&maptype=roadmap&markers=color:green%7Clabel:S%7C$latitudeStart,$longitudeStart&markers=color:red%7Clabel:E%7C$latitudeEnd,$longitudeEnd&key=${Keys.googleApiKey}';
  }
}
