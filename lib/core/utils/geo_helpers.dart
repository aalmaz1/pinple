import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:pinple/core/constants/app_constants.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';

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

/// Creates a reusable card-style marker image.
Future<NOverlayImage> createCardMarker(
  BuildContext context,
  String categoryId,
) async {
  final category = GroupCategory.fromId(categoryId);

  return await NOverlayImage.fromWidget(
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: category.color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(category.icon, color: Colors.white, size: 20),
        ),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Transform.rotate(
            angle: 0.785, // 45 degrees
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    size: const Size(44, 54),
    context: context,
  );
}

/// Shows the "Comrade Warning" dialog when user tries to pick North Korea.
void showComradeDialog(BuildContext context, L10n l10n) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('🇰🇷'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.outOfBoundsError,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.backToKorea),
          ),
        ),
      ],
    ),
  );
}
