// lib/core/constants.dart
import 'package:geolocator/geolocator.dart';

class AppConstants {
  static const double maxDistance = 1000.0; // Toleransi 1000 meter
  static const double officeLat = -6.142763; // Ganti dengan Lat Kantor
  static const double officeLng = 106.743728; // Ganti dengan Lng Kantor
}

// lib/core/location_service.dart

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('GPS belum aktif');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(double startLat, double startLng) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      AppConstants.officeLat,
      AppConstants.officeLng,
    );
  }
}
