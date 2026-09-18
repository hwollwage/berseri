import 'package:berseri/features/auth/login_page.dart';
import 'package:berseri/features/auth/register_page.dart';
import 'package:berseri/features/camera/camera_page.dart';
import 'package:berseri/features/home/home_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [

    // === HOME PAGE
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    // === AUTH PAGE
    GoRoute(
      path: '/auth',
      name: 'auth',
      redirect: (context, state) {
        if(state.matchedLocation == '/auth') {
          return '/auth/login';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: 'login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        GoRoute(
          path: 'register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    ),

    GoRoute(
      path: '/camera',
      name: 'cameras',
      builder: (context, state) => const CameraPage(),
    )

    // END AUTH PAGE ===



    // GoRoute(
    //   path: '/camera',
    //   name: 'camera',
    //   builder: (context, state) => const CameraPage(),
    // ),

    // GoRoute(
    //   path: '/diagnosis',
    //   name: 'diagnosis',
    //   builder: (context, state) => const DiagosisPage(),
    // ),


    // lanjutin routenya...
  ],

  

  // ini buat cek status login
  redirect: (context, state) {
    return null;
  },
);