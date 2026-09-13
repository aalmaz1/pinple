import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/app_constants.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/utils/geo_helpers.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';
import 'package:pinple/features/settings/providers/settings_provider.dart';

// Final version of Comrade Dialog
void showComradeDialog(BuildContext context, L10n l10n) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('🇰🇷'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.outOfBoundsError,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('대한민국으로 돌아가기'),
          ),
        ),
      ],
    ),
  );
}

class GroupCreateScreen extends ConsumerStatefulWidget {
  final String? groupId;

  const GroupCreateScreen({super.key, this.groupId});

  @override
  ConsumerState<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends ConsumerState<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationNameController = TextEditingController();
  String _selectedCategory = GroupCategory.study.id;
  int _maxMembers = 4;
  NLatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _isEditMode = true;
      _loadGroupData();
    }
  }

  Future<void> _loadGroupData() async {
    final group = await ref
        .read(groupRepositoryProvider)
        .getGroupById(widget.groupId!);
    if (group != null && mounted) {
      setState(() {
        _titleController.text = group.title;
        _descriptionController.text = group.description;
        _locationNameController.text = group.locationName;
        _selectedCategory = group.category;
        _maxMembers = group.maxMembers;
        _selectedLocation = NLatLng(group.latitude, group.longitude);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(l10nProvider).selectLocation)),
      );
      return;
    }

    final l10n = ref.read(l10nProvider);
    if (!isStrictlySouthKorea(_selectedLocation)) {
      showComradeDialog(context, l10n);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await ref
          .read(authRepositoryProvider)
          .getUserData(user.uid);

      if (_isEditMode) {
        await ref.read(groupRepositoryProvider).updateGroup(widget.groupId!, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _selectedCategory,
          'maxMembers': _maxMembers,
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'locationName': _locationNameController.text.trim(),
        });
      } else {
        final group = GroupModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          maxMembers: _maxMembers,
          memberIds: [user.uid],
          ownerId: user.uid,
          ownerNickname: userData?['displayName'] ?? '',
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          locationName: _locationNameController.text.trim(),
          createdAt: DateTime.now(),
        );
        await ref.read(groupRepositoryProvider).createGroup(group);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    final picked = await Navigator.push<NLatLng>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _LocationPickerPage(initialLocation: _selectedLocation),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedLocation = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? l10n.editGroup : l10n.createGroup),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.groupTitle,
                  hintText: 'ex: Flutter Study',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.groupTitle : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.category, style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: GroupCategory.values.map((c) {
                  return _CategoryOption(
                    categoryId: c.id,
                    isSelected: _selectedCategory == c.id,
                    onTap: () => setState(() => _selectedCategory = c.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.maxMembers, style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onPressed: _maxMembers > 2
                        ? () => setState(() => _maxMembers--)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      '$_maxMembers${l10n.memberSuffix}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onPressed: _maxMembers < 20
                        ? () => setState(() => _maxMembers++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.groupDescription,
                  hintText: 'Tell us about the group',
                ),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.groupDescription : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: Icon(
                  _selectedLocation != null
                      ? Icons.check_rounded
                      : Icons.map_rounded,
                ),
                label: Text(
                  _selectedLocation != null
                      ? l10n.selectLocation
                      : l10n.pickLocationOnMap,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _locationNameController,
                decoration: InputDecoration(
                  labelText: l10n.locationName,
                  hintText: 'ex: Engineering Building',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.locationName : null,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const AppLoader(color: Colors.white)
                    : Text(_isEditMode ? l10n.update : l10n.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryOption extends ConsumerWidget {
  final String categoryId;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.categoryId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = categoryColor(categoryId);
    final icon = categoryIcon(categoryId);
    final l10n = ref.watch(l10nProvider);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              localizedCategory(categoryId, l10n),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _StepperButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: isEnabled
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          foregroundColor: isEnabled
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _LocationPickerPage extends ConsumerStatefulWidget {
  final NLatLng? initialLocation;
  const _LocationPickerPage({this.initialLocation});

  @override
  ConsumerState<_LocationPickerPage> createState() =>
      _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<_LocationPickerPage> {
  NaverMapController? _mapController;
  final ValueNotifier<NLatLng?> _selectedNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _selectedNotifier.value = widget.initialLocation;
  }

  @override
  void dispose() {
    _selectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final settings = ref.watch(settingsProvider);
    final isNightMode =
        settings.themeMode == AppThemeMode.dark ||
        (settings.themeMode == AppThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLocationTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ValueListenableBuilder<NLatLng?>(
            valueListenable: _selectedNotifier,
            builder: (context, selected, _) {
              final isValid = isStrictlySouthKorea(selected);
              return TextButton(
                onPressed: selected != null
                    ? () {
                        if (isValid) {
                          Navigator.pop(context, selected);
                        } else {
                          showComradeDialog(context, l10n);
                        }
                      }
                    : null,
                child: Text(
                  l10n.done,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: selected != null
                        ? (isValid
                              ? (isNightMode
                                    ? AppColors.success
                                    : AppColors.primary)
                              : Colors.red)
                        : Colors.grey,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target:
                    widget.initialLocation ??
                    const NLatLng(
                      CampusConstants.latitude,
                      CampusConstants.longitude,
                    ),
                zoom: 16,
              ),
              mapType: NMapType.basic,
              nightModeEnable: isNightMode,
              locationButtonEnable: true,
              logoClickEnable: false,
            ),
            onMapReady: (controller) => _mapController = controller,
            onCameraIdle: () async {
              if (_mapController != null) {
                final pos = await _mapController!.getCameraPosition();
                _selectedNotifier.value = pos.target;
              }
            },
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: ValueListenableBuilder<NLatLng?>(
                  valueListenable: _selectedNotifier,
                  builder: (context, pos, _) {
                    final isValid = isStrictlySouthKorea(pos);
                    return Icon(
                      Icons.location_pin,
                      size: 54,
                      color: isValid
                          ? (isNightMode
                                ? AppColors.success
                                : AppColors.primary)
                          : Colors.red,
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: IgnorePointer(
              child: ValueListenableBuilder<NLatLng?>(
                valueListenable: _selectedNotifier,
                builder: (context, pos, _) {
                  final isValid = isStrictlySouthKorea(pos);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: (isValid ? Colors.black : Colors.red).withValues(
                        alpha: 0.8,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Text(
                      isValid ? l10n.dragMapHint : l10n.outOfBoundsError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
