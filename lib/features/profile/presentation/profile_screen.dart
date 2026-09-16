import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/core/widgets/group_card.dart';
import 'package:pinple/core/widgets/skeleton.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(String uid) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .uploadProfileImage(uid, File(image.path));
      ref.invalidate(userDataProvider(uid));
      if (mounted) {
        final l10n = ref.read(l10nProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
      }
    } catch (e) {
      if (mounted) {
        final l10n = ref.read(l10nProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.uploadFailed}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final userDataAsync = ref.watch(userDataProvider(user.uid));
    final myGroupsAsync = ref.watch(myGroupsProvider(user.uid));
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // User card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: userDataAsync.when(
                loading: () => const Skeleton(
                  width: double.infinity,
                  height: 100,
                  borderRadius: AppRadius.lg,
                ),
                error: (e, _) => Text(
                  l10n.infoLoadError,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                data: (data) {
                  final displayName = data?['displayName'] as String? ?? '';
                  final email = data?['email'] as String? ?? '';
                  final photoUrl = data?['photoUrl'] as String?;
                  final initial = displayName.isNotEmpty ? displayName[0] : '?';

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _isUploading
                                  ? null
                                  : () => _pickAndUploadImage(user.uid),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                backgroundImage: photoUrl != null
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl == null
                                    ? Text(
                                        initial,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      )
                                    : null,
                              ),
                            ),
                            if (_isUploading)
                              const Positioned.fill(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                email,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            SectionTitle(title: l10n.myGroups),

            // My groups list
            myGroupsAsync.when(
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: List.generate(
                    3,
                    (i) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: Skeleton(
                        width: double.infinity,
                        height: 80,
                        borderRadius: AppRadius.lg,
                      ),
                    ),
                  ),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  l10n.errorLoadingGroups,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              data: (groups) {
                if (groups.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_note_rounded,
                    title: l10n.noJoinedGroups,
                    description: l10n.joinHint,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groups.length,
                    separatorBuilder: (_, idx) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final g = groups[i];
                      return GroupCard(
                        group: g,
                        onTap: () => context.push('/group/${g.id}'),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.logout),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
