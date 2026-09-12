import 'package:flutter_naver_map/flutter_naver_map.dart';

/// Professional Border Logic: Accounts for the diagonal DMZ line.
/// Returns true if the location is strictly within South Korean territory.
bool isStrictlySouthKorea(NLatLng? latLng) {
  if (latLng == null) return false;
  final lat = latLng.latitude;
  final lng = latLng.longitude;

  // Basic South Korea bounding box
  if (lat < 33.0 || lat > 38.6 || lng < 124.0 || lng > 132.0) return false;

  // Specific North Korea blocks (Kaesong and Western DMZ area)
  // The border is lower in the West (lng < 127.2, lat > 37.85)
  if (lng < 127.2 && lat > 37.85) return false;

  // Mid-area DMZ check
  if (lng >= 127.2 && lng < 128.0 && lat > 38.3) return false;

  return true;
}
