import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/location_gate/presentation/location_blocked_screen.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';

class LocationGate extends ConsumerWidget {
  final Widget child;

  const LocationGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationCheck = ref.watch(locationCheckProvider);
    final l10n = ref.watch(l10nProvider);

    return locationCheck.when(
      loading: () => const Scaffold(body: Center(child: AppLoader())),
      error: (error, _) => Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: l10n.locationErrorTitle,
            description: error.toString().replaceFirst('Exception: ', ''),
            action: ElevatedButton(
              onPressed: () => ref.invalidate(currentPositionProvider),
              child: Text(l10n.retry),
            ),
          ),
        ),
      ),
      data: (isWithin) {
        if (!isWithin) return const LocationBlockedScreen();
        return child;
      },
    );
  }
}
