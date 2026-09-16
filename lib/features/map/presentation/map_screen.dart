import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/presentation/group_detail_screen.dart';
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
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  bool _isExploring = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _exitExploring() {
    setState(() {
      _isExploring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final settings = ref.watch(settingsProvider);
    final groupsAsync = ref.watch(activeGroupsProvider);

    final isNightMode =
        settings.themeMode == AppThemeMode.dark ||
        (settings.themeMode == AppThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    ref.listen(activeGroupsProvider, (previous, next) {
      if (next.hasValue) {
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
                locationButtonEnable: !_isExploring,
                logoClickEnable: false,
                contentPadding: _isExploring
                    ? const EdgeInsets.only(bottom: 120)
                    : const EdgeInsets.only(bottom: 20),
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isExploring
                  ? _GlassIconButton(
                      key: const ValueKey('back'),
                      icon: Icons.arrow_back_rounded,
                      color: AppColors.primary,
                      iconColor: Colors.white,
                      onTap: _exitExploring,
                    )
                  : Builder(
                      key: const ValueKey('menu'),
                      builder: (context) => _GlassIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
            ),
          ),
          if (!_isExploring)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              right: AppSpacing.lg,
              child: _GlassIconButton(
                icon: Icons.list_rounded,
                onTap: () => context.push('/list'),
              ),
            ),
          if (_isExploring)
            groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 240,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: groups.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        HapticFeedback.selectionClick();
                        _animateCameraToGroup(groups[index]);
                      },
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return AnimatedOpacity(
                          opacity: _currentPage == index ? 1.0 : 0.6,
                          duration: const Duration(milliseconds: 300),
                          child: Transform.scale(
                            scale: _currentPage == index ? 1.0 : 0.95,
                            child: GroupBottomSheet(
                              group: group,
                              onDetailTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  showDragHandle: false,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) =>
                                      GroupDetailScreen(groupId: group.id),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
        ],
      ),
      floatingActionButton: _isExploring
          ? null
          : FloatingActionButton.extended(
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

    final markers = <NMarker>{};

    for (int i = 0; i < groups.length; i++) {
      if (!mounted) return;
      final group = groups[i];
      final color = categoryColor(group.category);
      final icon = categoryIcon(group.category);

      // Create a custom card-style marker
      final markerIcon = await NOverlayImage.fromWidget(
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10), // Card shape
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
            // Small beak/pointer
            Transform.translate(
              offset: const Offset(0, -6),
              child: Transform.rotate(
                angle: 0.785, // 45 degrees
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
        id: group.id,
        position: NLatLng(group.latitude, group.longitude),
        icon: markerIcon,
      );

      marker.setCaption(
        NOverlayCaption(
          text: group.title,
          color: color,
          textSize: 13,
          haloColor: Colors.white,
        ),
      );

      marker.setOnTapListener((_) {
        setState(() {
          _isExploring = true;
          _currentPage = i;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(i);
          }
          _animateCameraToGroup(group);
        });
      });
      markers.add(marker);
    }

    await controller.addOverlayAll(markers);
  }

  void _animateCameraToGroup(GroupModel group) {
    if (_mapController == null) return;
    _mapController!.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(group.latitude, group.longitude),
        zoom: 16.0,
      )..setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  const _GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color:
                color ??
                (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.1,
              ),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Icon(
                icon,
                size: 26,
                color: iconColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
