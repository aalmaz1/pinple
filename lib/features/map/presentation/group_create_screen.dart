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
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class GroupCreateScreen extends ConsumerStatefulWidget {
  final String? groupId; // null for create, non-null for edit

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
      final l10n = ref.read(l10nProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectLocation)));
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
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

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
              // Group Name
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

              // Category
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

              // Max Members
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
                      '$_maxMembers${l10n.language == 'ko' ? '명' : ''}',
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

              // Description
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

              // Location Picker
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

              // Location Name
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

              // Submit Button
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

class _LocationPickerPage extends StatefulWidget {
  final NLatLng? initialLocation;

  const _LocationPickerPage({this.initialLocation});

  @override
  State<_LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<_LocationPickerPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите место'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ValueListenableBuilder<NLatLng?>(
            valueListenable: _selectedNotifier,
            builder: (context, selected, _) {
              return TextButton(
                onPressed: selected != null
                    ? () => Navigator.pop(context, selected)
                    : null,
                child: const Text(
                  'Готово',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          // Фиксированный прицел (всегда в центре)
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Icon(
                  Icons.location_pin,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // Подсказка снизу
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: const Text(
                  'Передвиньте карту, чтобы выбрать место',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
