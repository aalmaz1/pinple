import 'package:flutter/material.dart';
import 'package:pinple/core/theme/app_theme.dart';

enum GroupCategory {
  study('study', Icons.menu_book_rounded, AppColors.primary),
  exercise('exercise', Icons.sports_basketball_rounded, AppColors.success),
  meal('meal', Icons.restaurant_rounded, Color(0xFFFF9F1C)),
  hobby('hobby', Icons.palette_rounded, Color(0xFF8B5CF6)),
  other('other', Icons.tag_rounded, Color(0xFF8B95A1));

  final String id;
  final IconData icon;
  final Color color;

  const GroupCategory(this.id, this.icon, this.color);

  static GroupCategory fromId(String id) {
    return values.firstWhere((e) => e.id == id, orElse: () => other);
  }
}
