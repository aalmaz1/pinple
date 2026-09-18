import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/features/auth/presentation/login_screen.dart';
import 'package:pinple/features/auth/presentation/signup_screen.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/presentation/group_create_screen.dart';
import 'package:pinple/features/map/presentation/group_detail_screen.dart';
import 'package:pinple/features/map/presentation/group_list_screen.dart';
import 'package:pinple/features/map/presentation/map_screen.dart';
import 'package:pinple/features/map/providers/group_provider.dart';
import 'package:pinple/features/profile/presentation/profile_screen.dart';
import 'package:pinple/features/settings/presentation/settings_screen.dart';
import 'package:pinple/features/settings/providers/settings_provider.dart';
import 'package:pinple/features/shell/presentation/location_gate.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = authState.value;
      final isLoggedIn = user != null;
      final currentPath = state.matchedLocation;

      final authPaths = ['/login', '/signup'];
      final isOnAuthPage = authPaths.contains(currentPath);

      if (!isLoggedIn) {
        return isOnAuthPage ? null : '/login';
      }

      if (isOnAuthPage) {
        return '/map';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
      ShellRoute(
        builder: (_, _, child) => LocationGate(child: child),
        routes: [
          GoRoute(path: '/map', builder: (_, _) => const MapScreen()),
          GoRoute(path: '/list', builder: (_, _) => const GroupListScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: '/group/create',
        builder: (_, _) => const GroupCreateScreen(),
      ),
      GoRoute(
        path: '/group/:id',
        builder: (_, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/group/:id/edit',
        builder: (_, state) =>
            GroupCreateScreen(groupId: state.pathParameters['id']),
      ),
    ],
  );
});

class PinpleApp extends ConsumerStatefulWidget {
  const PinpleApp({super.key});

  @override
  ConsumerState<PinpleApp> createState() => _PinpleAppState();
}

class _PinpleAppState extends ConsumerState<PinpleApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Listen to incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Check for initial link when app starts
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Processing Incoming Link: $uri');
    String? id;

    // 1. Handle Verified App Link: https://pinple-5e23e.web.app/group/ID
    if (uri.host == 'pinple-5e23e.web.app' && uri.path.startsWith('/group/')) {
      id = uri.path.split('/').last;
    }
    // 2. Handle Custom Scheme: pinple://group/ID
    else if (uri.scheme == 'pinple' && uri.host == 'group') {
      id = uri.path.replaceAll('/', '');
    }
    // 3. Fallback path check
    else if (uri.path.startsWith('/group/')) {
      id = uri.path.split('/').last;
    }

    if (id != null && id.isNotEmpty) {
      ref.read(pendingDeepLinkProvider.notifier).set(id);
      // ALWAYS navigate to map to provide context
      ref.read(routerProvider).go('/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Pinple',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _mapThemeMode(settings.themeMode),
      locale: settings.locale,
      supportedLocales: const [Locale('ko'), Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }

  ThemeMode _mapThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
