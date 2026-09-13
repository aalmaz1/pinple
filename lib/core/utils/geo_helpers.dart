import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:pinple/core/constants/campus_constants.dart';

/// Professional Border Logic: Accounts for the diagonal DMZ line.
/// Returns true if the location is strictly within South Korean territory.
bool isStrictlySouthKorea(NLatLng? latLng) {
  if (latLng == null) return false;
  final lat = latLng.latitude;
  final lng = latLng.longitude;

  // Basic South Korea bounding box
  if (lat < CampusConstants.minLat ||
      lat > CampusConstants.maxLat ||
      lng < CampusConstants.minLng ||
      lng > CampusConstants.maxLng) {
    return false;
  }

  // Specific North Korea blocks (Kaesong and Western DMZ area)
  // The border is lower in the West
  if (lng < CampusConstants.westLngLimit &&
      lat > CampusConstants.westLatLimit) {
    return false;
  }

  // Mid-area DMZ check
  if (lng >= CampusConstants.westLngLimit &&
      lng < CampusConstants.midLngLimit &&
      lat > CampusConstants.midLatLimit) {
    return false;
  }

  return true;
}
