import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/distance.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/core/widgets/group_card.dart';
import 'package:pinple/core/widgets/skeleton.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(activeGroupsProvider);
    final positionAsync = ref.watch(currentPositionProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupList)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Text(
              l10n.distanceSortHint,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: groupsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: 5,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, __) => const Skeleton(
                  width: double.infinity,
                  height: 120,
                  borderRadius: AppRadius.lg,
                ),
              ),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: l10n.errorLoadingGroups,
                description: e.toString(),
              ),
              data: (groups) {
                if (groups.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_note_rounded,
                    title: l10n.noGroupsYet,
                    description: l10n.createGroup,
                  );
                }

                final myLat = positionAsync.value?.latitude;
                final myLng = positionAsync.value?.longitude;
                final sorted = _sortByDistance(groups, myLat, myLng);

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(activeGroupsProvider);
                    ref.invalidate(currentPositionProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.xxl,
                    ),
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final entry = sorted[i];
                      return GroupCard(
                        group: entry.group,
                        distanceMeters: entry.distance,
                        onTap: () => context.push('/group/${entry.group.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_GroupWithDistance> _sortByDistance(
    List<GroupModel> groups,
    double? myLat,
    double? myLng,
  ) {
    final entries = groups.map((g) {
      final d = (myLat != null && myLng != null)
          ? distanceMeters(
              fromLat: myLat,
              fromLng: myLng,
              toLat: g.latitude,
              toLng: g.longitude,
            )
          : null;
      return _GroupWithDistance(group: g, distance: d);
    }).toList();

    entries.sort((a, b) {
      if (a.distance == null && b.distance == null) return 0;
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });

    return entries;
  }
}

class _GroupWithDistance {
  final GroupModel group;
  final double? distance;

  _GroupWithDistance({required this.group, this.distance});
}
