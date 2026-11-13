import 'dart:async';

import 'package:berseri/features/analysis/analysis_entry.dart';
import 'package:berseri/features/analysis/history_page.dart';
import 'package:berseri/features/auth/login_page.dart';
import 'package:berseri/features/auth/register_page.dart';
import 'package:berseri/features/camera/presentation/pages/camera_page.dart';
import 'package:berseri/features/clinics/clinics_page.dart';
import 'package:berseri/features/diagnosis/analysis_loading_page.dart';
import 'package:berseri/features/diagnosis/analysis_result_page.dart';
import 'package:berseri/features/diagnosis/diagnosis_page.dart';
import 'package:berseri/features/home/home_page.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:berseri/features/ingredients/ingredient_detail_page.dart';
import 'package:berseri/features/onboarding/presentation/onboarding_page.dart';
import 'package:berseri/features/profile/change_password_page.dart';
import 'package:berseri/features/profile/profile_page.dart';
import 'package:berseri/features/questionnaire/presentation/questionnaire_page.dart';
import 'package:berseri/features/routine/routine_page.dart';
import 'package:berseri/features/splash/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _AuthStateRefresh extends ChangeNotifier {
  _AuthStateRefresh(Stream<AuthState> changes) {
    _subscription = changes.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _authStateRefresh = _AuthStateRefresh(
  Supabase.instance.client.auth.onAuthStateChange,
);

const String splashPath = '/splash';
const String onboardingPath = '/onboarding';
const String loginPath = '/auth/login';

String? authRedirect(String path, {required bool signedIn}) {
  if (path == splashPath) return null;

  if (signedIn) {
    return (path == onboardingPath || path == loginPath) ? '/' : null;
  }

  if (path == onboardingPath || path.startsWith('/auth/')) return null;
  return loginPath;
}

final router = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _authStateRefresh,
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: '/auth',
      name: 'auth',
      redirect: (context, state) {
        if (state.uri.path == '/auth') {
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
      builder: (context, state) => const ProfilePage(),
    ),

    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),

    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),

    GoRoute(
      path: '/clinics',
      name: 'clinics',
      builder: (context, state) => const ClinicsPage(),
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

    GoRoute(
      path: '/questionnaire',
      name: 'questionnaire',
      builder: (context, state) => const QuestionnairePage(),
    ),

    GoRoute(
      path: '/analysis-loading',
      name: 'analysis-loading',
      builder: (context, state) => const AnalysisLoadingPage(),
    ),

    GoRoute(
      path: '/analysis-result',
      name: 'analysis-result',
      builder: (context, state) => AnalysisResultPage(
        entry: state.extra as AnalysisEntry?,
      ),
    ),

    GoRoute(
      path: '/ingredient-detail',
      name: 'ingredient-detail',
      builder: (context, state) {
        final ingredient =
            state.extra as Ingredient? ?? ingredientLibrary.first;
        return IngredientDetailPage(ingredient: ingredient);
      },
    ),
  ],

  redirect: (context, state) {
    return authRedirect(
      state.uri.path,
      signedIn: Supabase.instance.client.auth.currentSession != null,
    );
  },
);
