import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';

class LocationBlockedScreen extends ConsumerWidget {
  const LocationBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.location_off_rounded,
          title: l10n.locationBlockedTitle,
          description: l10n.locationBlockedSubtitle,
          action: ElevatedButton.icon(
            onPressed: () => ref.invalidate(currentPositionProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retryButton),
          ),
        ),
      ),
    );
  }
}
