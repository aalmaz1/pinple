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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.md),
          _SectionHeader(title: l10n.themeSettings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SegmentedButton<AppThemeMode>(
              segments: [
                ButtonSegment(
                  value: AppThemeMode.light,
                  icon: const Icon(Icons.light_mode_rounded),
                  label: Text(l10n.light),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_rounded),
                  label: Text(l10n.dark),
                ),
                ButtonSegment(
                  value: AppThemeMode.system,
                  icon: const Icon(Icons.settings_suggest_rounded),
                  label: Text(l10n.system),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (value) => notifier.setThemeMode(value.first),
              showSelectedIcon: false,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          _SectionHeader(title: l10n.languageSettings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ko', label: Text('한국어')),
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ru', label: Text('Русский')),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (value) {
                notifier.setLocale(Locale(value.first));
              },
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.success : AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
