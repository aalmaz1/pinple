import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final l10n = ref.watch(l10nProvider);

    return groupAsync.when(
      loading: () => const Scaffold(body: Center(child: AppLoader())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.map)),
        body: Center(child: Text('${l10n.error}: $e')),
      ),
      data: (group) {
        if (group == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.map)),
            body: Center(child: Text(l10n.infoLoadError)),
          );
        }

        final isOwner = currentUid == group.ownerId;
        final isMember = group.memberIds.contains(currentUid);
        final color = categoryColor(group.category);
        final icon = categoryIcon(group.category);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.map),
            actions: isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => context.push('/group/${group.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () =>
                          _confirmDelete(context, ref, group, l10n),
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero section
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(icon: icon, color: color, size: 56),
                          const Spacer(),
                          Icon(
                            Icons.people_rounded,
                            size: 16,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${group.memberIds.length}/${group.maxMembers}명',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        group.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '만든 사람: ${group.ownerNickname}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            group.locationName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.borderSubtle),

                // Description block
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        title: '소개',
                        padding: const EdgeInsets.only(
                          top: AppSpacing.lg,
                          bottom: AppSpacing.md,
                        ),
                      ),
                      Text(
                        group.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),

                // Join requests (owner only)
                if (isOwner)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: _buildJoinRequests(context, ref, l10n),
                  ),

                // Bottom action area
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxxl,
                  ),
                  child: _buildActionButton(
                    context,
                    ref,
                    group,
                    isOwner,
                    isMember,
                    l10n,
                  ),
                ),
              ],
            ),
          ),
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
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showJoinDialog(context, ref, group, l10n),
          child: Text(l10n.joining),
        ),
      );
    }

    if (isMember) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.joined,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => _confirmLeave(context, ref, group, l10n),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.leaveGroup),
          ),
        ],
      );
    }

    if (group.isFull) {
      return Center(
        child: Text(
          l10n.fullMembers,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSubtle),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildJoinRequests(BuildContext context, WidgetRef ref, L10n l10n) {
    final requestsAsync = ref.watch(joinRequestsProvider(groupId));

    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: '${l10n.joining} (${requests.length})',
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
            ),
            ...requests.map(
              (req) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.requesterNickname,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (req.message.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                req.message,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSubtle),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AcceptButton(
                            onPressed: () {
                              ref
                                  .read(groupRepositoryProvider)
                                  .acceptJoinRequest(
                                    req.id,
                                    groupId,
                                    req.requesterId,
                                  );
                            },
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _RejectButton(
                            onPressed: () {
                              ref
                                  .read(groupRepositoryProvider)
                                  .rejectJoinRequest(req.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
    final currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.joining),
        content: TextField(
          controller: messageController,
          decoration: InputDecoration(hintText: '${l10n.submit} (선택)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final userData = await ref
                  .read(authRepositoryProvider)
                  .getUserData(currentUser!.uid);
              final nickname =
                  (userData?['displayName'] as String?) ??
                  currentUser.email ??
                  '';
              final request = JoinRequestModel(
                id: '',
                groupId: group.id,
                requesterId: currentUser.uid,
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

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
              await ref
                  .read(groupRepositoryProvider)
                  .leaveGroup(group.id, currentUser.uid);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.leaveConfirmTitle)));
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
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
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(groupRepositoryProvider).deleteGroup(group.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.go('/map');
            },
            child: Text(l10n.deleteGroup),
          ),
        ],
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AcceptButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RejectButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}
