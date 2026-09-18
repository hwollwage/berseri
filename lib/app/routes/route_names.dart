import 'package:berseri/app/routes/app_router.dart';
import 'package:berseri/features/auth/auth_page.dart';
import 'package:berseri/features/home/home_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  initialLocation: RouteNames.homePath,
  routes: [

    // === HOME PAGE
    GoRoute(
      path: RouteNames.homePath,
      name: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),

    // === AUTH PAGE
    GoRoute(
      path: RouteNames.authPath,
      name: RouteNames.auth,
      builder: (context, state) => const AuthPage(),
    ),

    // lanjutin routenya...
  ],

  

  // ini buat cek status login
  redirect: (context, state) {
    return null;
  },
);