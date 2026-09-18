import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/localization/app_localizations.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/utils/geo_helpers.dart';
import 'package:pinple/core/utils/weather_service.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
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

  // Cache for marker images to improve performance
  final Map<String, NOverlayImage> _markerCache = {};

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ref.read(authRepositoryProvider).updateFcmToken(user.uid);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _markerCache.clear();
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
        _checkPendingLink(next.value!);
      }
    });

    ref.listen(pendingDeepLinkProvider, (prev, next) {
      if (next != null) {
        final groups = ref.read(activeGroupsProvider).value;
        if (groups != null) {
          _checkPendingLink(groups);
        }
      }
    });

    return Scaffold(
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Naver Map
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

          // 2. Top Dynamic Weather Island
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: 0,
            right: 0,
            child: const Center(child: _WeatherIsland()),
          ),

          // 3. Top UI Controls
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

          // 4. Bottom Slider
          if (_isExploring)
            groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 5,
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
                                _showDetailSheet(group);
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
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/group/create');
              },
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

  void _checkPendingLink(List<GroupModel> groups) {
    final pendingId = ref.read(pendingDeepLinkProvider);
    if (pendingId == null) return;

    final index = groups.indexWhere((g) => g.id == pendingId);
    if (index != -1) {
      setState(() {
        _isExploring = true;
        _currentPage = index;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(index);
        }

        int retry = 0;
        while (_mapController == null && retry < 10) {
          await Future.delayed(const Duration(milliseconds: 200));
          retry++;
        }

        if (_mapController != null) {
          _animateCameraToGroup(groups[index]);
        }

        if (mounted) {
          _showDetailSheet(groups[index]);
        }

        ref.read(pendingDeepLinkProvider.notifier).clear();
      });
    }
  }

  void _showDetailSheet(GroupModel group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupDetailScreen(groupId: group.id),
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

      // Performance Optimization: Cache marker images by category
      NOverlayImage markerIcon;
      if (_markerCache.containsKey(group.category)) {
        markerIcon = _markerCache[group.category]!;
      } else {
        markerIcon = await createCardMarker(context, group.category);
        _markerCache[group.category] = markerIcon;
      }

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

class _WeatherIsland extends ConsumerWidget {
  const _WeatherIsland();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return weatherAsync.when(
      data: (weather) => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.1,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/${weather.iconCode}.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.wb_sunny_rounded, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Cheonan ${weather.temp.round()}°C',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(), // Hide while loading
      error: (error, stack) => const SizedBox.shrink(), // Hide on error
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
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
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
