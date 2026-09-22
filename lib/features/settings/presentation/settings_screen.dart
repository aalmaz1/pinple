import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/features/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : AppColors.textStrong,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textStrong),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 24),

          // --- THEME SECTION ---
          _KnuSection(
            title: l10n.theme,
            child: _KnuSelector<AppThemeMode>(
              currentValue: settings.themeMode,
              onChanged: notifier.setThemeMode,
              items: [
                _SelectorItem(
                  value: AppThemeMode.light,
                  label: l10n.light,
                  icon: Icons.wb_sunny_rounded,
                ),
                _SelectorItem(
                  value: AppThemeMode.dark,
                  label: l10n.dark,
                  icon: Icons.nightlight_round,
                ),
                _SelectorItem(
                  value: AppThemeMode.system,
                  label: l10n.system,
                  icon: Icons.settings_suggest_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --- LANGUAGE SECTION ---
          _KnuSection(
            title: l10n.language,
            child: _KnuSelector<String>(
              currentValue: settings.locale.languageCode,
              onChanged: (val) => notifier.setLocale(Locale(val)),
              items: const [
                _SelectorItem(
                  value: 'ko',
                  label: 'KOR',
                  icon: Icons.language,
                ),
                _SelectorItem(
                  value: 'en',
                  label: 'ENG',
                  icon: Icons.language,
                ),
                _SelectorItem(
                  value: 'ru',
                  label: 'RUS',
                  icon: Icons.language,
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          Center(
            child: Opacity(
              opacity: 0.6,
              child: Column(
                children: [
                  Text(
                    'PINPLE',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textStrong,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Campus Social Network v1.0.5',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white : AppColors.textStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KnuSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _KnuSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.success, // KNU Green
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _KnuSelector<T> extends StatelessWidget {
  final T currentValue;
  final List<_SelectorItem<T>> items;
  final ValueChanged<T> onChanged;

  const _KnuSelector({
    required this.currentValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / items.length;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.fill,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Animated Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                left: items.indexWhere((i) => i.value == currentValue) * itemWidth,
                child: Container(
                  width: itemWidth,
                  height: 64,
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Items
              Row(
                children: items.map((item) {
                  final isSelected = item.value == currentValue;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(item.value),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected 
                                ? AppColors.primary 
                                : (isDark ? Colors.white70 : AppColors.textSubtle),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected 
                                  ? AppColors.primary 
                                  : (isDark ? Colors.white70 : AppColors.textSubtle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectorItem<T> {
  final T value;
  final String label;
  final IconData icon;

  const _SelectorItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}
