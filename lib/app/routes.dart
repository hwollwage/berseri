import 'package:berseri/features/auth/login_page.dart';
import 'package:berseri/features/auth/register_page.dart';
import 'package:berseri/features/camera/camera_page.dart';
import 'package:berseri/features/home/home_page.dart';
import 'package:berseri/features/diagnosis/diagnosis_page.dart';
import 'package:berseri/features/profile/profile_page.dart';
import 'package:berseri/features/routine/routine_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

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
      path: '/profile',
      name: 'profile',
      builder: (context, state) => ProfilePage(),
    ),

    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (context, state) => const CameraPage(),
    ),
    
    GoRoute(
      path: '/diagnosis',
      name: 'diagnosis',
      builder: (context, state) => const DiagnosisPage(),
    ),
    
    GoRoute(
      path: '/routine',
      name: 'routine',
      builder: (context, state) => const RoutinePage(),
    ),

    // lanjutin routenya...
  ],

  

  // ini buat cek status login
  redirect: (context, state) {
    return null;
  },
);