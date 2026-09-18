import 'package:flutter/material.dart';
import 'package:pinple/core/constants/app_constants.dart';
import 'package:pinple/core/localization/app_localizations.dart';

Color categoryColor(String categoryId) =>
    GroupCategory.fromId(categoryId).color;

IconData categoryIcon(String categoryId) =>
    GroupCategory.fromId(categoryId).icon;

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
