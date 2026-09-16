import 'package:flutter/material.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/localization/app_localizations.dart';

Color categoryColor(String categoryId) {
  switch (categoryId) {
    case 'study':
      return AppColors.primary; // KNU Blue
    case 'exercise':
      return AppColors.success; // KNU Green #1CA546
    case 'meal':
      return const Color(0xFFFF9F1C); // Warm Orange
    case 'hobby':
      return const Color(0xFF8B5CF6); // Creative Purple
    default:
      return const Color(0xFF8B95A1); // Neutral Grey
  }
}

IconData categoryIcon(String categoryId) {
  switch (categoryId) {
    case 'study':
      return Icons.menu_book_rounded;
    case 'exercise':
      return Icons.sports_basketball_rounded;
    case 'meal':
      return Icons.restaurant_rounded;
    case 'hobby':
      return Icons.palette_rounded;
    default:
      return Icons.tag_rounded;
  }
}

String localizedCategory(String categoryId, L10n l10n) {
  switch (categoryId) {
    case 'study':
      return l10n.catStudy;
    case 'exercise':
      return l10n.catExercise;
    case 'meal':
      return l10n.catMeal;
    case 'hobby':
      return l10n.catHobby;
    default:
      return l10n.catOther;
  }
}
