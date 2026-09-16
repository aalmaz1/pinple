import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';
import 'package:pinple/features/settings/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final l10n = ref.watch(l10nProvider);
    final settings = ref.watch(settingsProvider);

    final isNightMode =
        settings.themeMode == AppThemeMode.dark ||
        (settings.themeMode == AppThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return groupAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (e, _) => Center(child: Text('${l10n.error}: $e')),
      data: (group) {
        if (group == null) return Center(child: Text(l10n.infoLoadError));

        final isOwner = currentUid == group.ownerId;
        final isMember = group.memberIds.contains(currentUid);
        final color = categoryColor(group.category);
        final icon = categoryIcon(group.category);

        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xxl),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // 1. Mini Map Header
                    SliverLikeHeader(
                      group: group,
                      color: color,
                      isNightMode: isNightMode,
                      isOwner: isOwner,
                      l10n: l10n,
                      onDelete: () => _confirmDelete(context, ref, group, l10n),
                    ),

                    // 2. Info Content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconBadge(icon: icon, color: color, size: 56),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CategoryChip(
                                      label: localizedCategory(
                                        group.category,
                                        l10n,
                                      ),
                                      color: color,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      group.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _InfoRow(
                            icon: Icons.people_rounded,
                            label:
                                '${group.memberIds.length}/${group.maxMembers}${l10n.memberSuffix}',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _InfoRow(
                            icon: Icons.person_rounded,
                            label: '${l10n.createdBy}: ${group.ownerNickname}',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _InfoRow(
                            icon: Icons.location_on_rounded,
                            label: group.locationName,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.xxl,
                            ),
                            child: Divider(),
                          ),
                          _SectionHeader(
                            title: l10n.introduction,
                            icon: Icons.notes_rounded,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            group.description,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.6),
                          ),
                          if (isOwner) ...[
                            const SizedBox(height: AppSpacing.xxl),
                            _buildJoinRequests(context, ref, group.id, l10n),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          _buildActionButton(
                            context,
                            ref,
                            group,
                            isOwner,
                            isMember,
                            l10n,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
    L10n l10n,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.deleteConfirmTitle),
              content: Text(l10n.deleteConfirmMessage),
              actions: [
                if (!isDeleting)
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          try {
                            await ref
                                .read(groupRepositoryProvider)
                                .deleteGroup(group.id);
                            ref.invalidate(activeGroupsProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              setDialogState(() => isDeleting = false);
                            }
                          }
                        },
                  child: isDeleting
                      ? const AppLoader(size: 20, color: Colors.white)
                      : Text(l10n.deleteGroup),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
    bool isOwner,
    bool isMember,
    L10n l10n,
  ) {
    if (isOwner) return const SizedBox.shrink();
    if (!isMember && !group.isFull) {
      return ElevatedButton(
        onPressed: () => _showJoinDialog(context, ref, group, l10n),
        child: Text(l10n.joining),
      );
    }
    if (isMember) {
      return OutlinedButton.icon(
        onPressed: () => _confirmLeave(context, ref, group, l10n),
        icon: const Icon(Icons.exit_to_app_rounded, size: 20),
        label: Text(l10n.leaveGroup),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildJoinRequests(
    BuildContext context,
    WidgetRef ref,
    String groupId,
    L10n l10n,
  ) {
    final requestsAsync = ref.watch(joinRequestsProvider(groupId));
    return requestsAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (_, error) => const SizedBox.shrink(),
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: '${l10n.joining} (${requests.length})',
              icon: Icons.person_add_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            ...requests.map(
              (req) => _JoinRequestItem(req: req, groupId: groupId),
            ),
          ],
        );
      },
    );
  }

  void _showJoinDialog(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
    L10n l10n,
  ) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.joining),
        content: TextField(
          controller: messageController,
          decoration: InputDecoration(
            hintText: '${l10n.submit} (${l10n.optional})',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser!;
              final userData = await ref
                  .read(authRepositoryProvider)
                  .getUserData(user.uid);
              final nickname =
                  (userData?['displayName'] as String?) ?? user.email ?? '';
              final request = JoinRequestModel(
                id: '',
                groupId: group.id,
                requesterId: user.uid,
                requesterNickname: nickname,
                message: messageController.text.trim(),
                status: 'pending',
                createdAt: DateTime.now(),
              );
              await ref.read(groupRepositoryProvider).sendJoinRequest(request);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.joinRequestSent)));
              }
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
    L10n l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leaveConfirmTitle),
        content: Text(l10n.leaveConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser!;
              await ref
                  .read(groupRepositoryProvider)
                  .leaveGroup(group.id, user.uid);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class SliverLikeHeader extends StatelessWidget {
  final GroupModel group;
  final Color color;
  final bool isNightMode;
  final bool isOwner;
  final L10n l10n;
  final VoidCallback onDelete;

  const SliverLikeHeader({
    super.key,
    required this.group,
    required this.color,
    required this.isNightMode,
    required this.isOwner,
    required this.l10n,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(group.latitude, group.longitude),
                zoom: 15,
              ),
              scrollGesturesEnable: false,
              zoomGesturesEnable: false,
              tiltGesturesEnable: false,
              rotationGesturesEnable: false,
              stopGesturesEnable: true,
              nightModeEnable: isNightMode,
            ),
            onMapReady: (controller) async {
              final color = categoryColor(group.category);
              final icon = categoryIcon(group.category);

              final markerIcon = await NOverlayImage.fromWidget(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
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

              final marker = NMarker(
                id: 'detail_marker',
                position: NLatLng(group.latitude, group.longitude),
                icon: markerIcon,
              );
              controller.addOverlay(marker);
            },
          ),
        ),
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
        if (isOwner)
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                _GlassCircleIcon(
                  icon: Icons.edit_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/group/${group.id}/edit');
                  },
                ),
                const SizedBox(width: 12),
                _GlassCircleIcon(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.error,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        Positioned(
          top: 20,
          left: 20,
          child: _GlassCircleIcon(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

class _GlassCircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _GlassCircleIcon({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? (isDark ? Colors.black : Colors.white)).withValues(
              alpha: 0.4,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: color != null
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: AppColors.textSubtle),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: AppSpacing.sm),
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class _JoinRequestItem extends ConsumerWidget {
  final JoinRequestModel req;
  final String groupId;
  const _JoinRequestItem({required this.req, required this.groupId});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                req.requesterNickname,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (req.message.isNotEmpty)
                Text(
                  req.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textSubtle),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
          ),
          onPressed: () => ref
              .read(groupRepositoryProvider)
              .acceptJoinRequest(req.id, groupId, req.requesterId),
        ),
        IconButton(
          icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
          onPressed: () =>
              ref.read(groupRepositoryProvider).rejectJoinRequest(req.id),
        ),
      ],
    ),
  );
}
