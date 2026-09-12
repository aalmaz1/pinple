import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/presentation/widgets/group_bottom_sheet.dart';
import 'package:pinple/features/map/providers/group_provider.dart';
import 'package:pinple/features/settings/providers/settings_provider.dart';
import 'package:pinple/features/shell/presentation/app_drawer.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  NaverMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final settings = ref.watch(settingsProvider);
    final isNightMode =
        settings.themeMode == AppThemeMode.dark ||
        (settings.themeMode == AppThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Optimization: Listen only to data changes, not the whole state
    ref.listen(activeGroupsProvider, (previous, next) {
      if (next.hasValue && next.value != previous?.value) {
        _setMarkers(next.value!);
      }
    });

    return Scaffold(
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          RepaintBoundary(
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: const NCameraPosition(
                  target: NLatLng(
                    CampusConstants.latitude,
                    CampusConstants.longitude,
                  ),
                  zoom: 15.5,
                ),
                mapType: NMapType.basic,
                nightModeEnable: isNightMode,
                locationButtonEnable: true,
                logoClickEnable: false,
                extent: const NLatLngBounds(
                  southWest: NLatLng(
                    CampusConstants.minLat,
                    CampusConstants.minLng,
                  ),
                  northEast: NLatLng(
                    CampusConstants.maxLat,
                    CampusConstants.maxLng,
                  ),
                ),
              ),
              onMapReady: (controller) {
                _mapController = controller;
                final groups = ref.read(activeGroupsProvider).value;
                if (groups != null) _setMarkers(groups);
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.lg,
            child: Builder(
              builder: (context) => _CircleIconButton(
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.lg,
            child: _CircleIconButton(
              icon: Icons.list_rounded,
              onTap: () => context.push('/list'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/group/create'),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.createGroup,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _setMarkers(List<GroupModel> groups) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.clearOverlays();

    for (final group in groups) {
      final color = categoryColor(group.category);
      final marker = NMarker(
        id: group.id,
        position: NLatLng(group.latitude, group.longitude),
        caption: NOverlayCaption(
          text: group.title,
          color: color,
          textSize: 13,
          haloColor: Colors.white,
        ),
      );
      marker.setOnTapListener((_) {
        _showGroupBottomSheet(group);
      });
      await controller.addOverlay(marker);
    }
  }

  void _showGroupBottomSheet(GroupModel group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => GroupBottomSheet(
        group: group,
        onDetailTap: () {
          Navigator.pop(context);
          context.push('/group/${group.id}');
        },
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
