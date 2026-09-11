import 'package:flutter/material.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/localization/app_localizations.dart';

Color categoryColor(String categoryId) {
  switch (categoryId) {
    case 'study':
      return AppColors.categoryStudy;
    case 'exercise':
      return AppColors.categoryExercise;
    case 'meal':
      return AppColors.categoryMeal;
    case 'hobby':
      return AppColors.categoryHobby;
    default:
      return AppColors.categoryOther;
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
