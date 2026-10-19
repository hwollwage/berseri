import 'package:berseri/features/analysis/history_page.dart';
import 'package:berseri/features/auth/login_page.dart';
import 'package:berseri/features/auth/register_page.dart';
import 'package:berseri/features/camera/presentation/pages/camera_page.dart';
import 'package:berseri/features/diagnosis/analysis_loading_page.dart';
import 'package:berseri/features/diagnosis/analysis_result_model.dart';
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
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/splash',
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
      builder: (context, state) =>
          AnalysisLoadingPage(imagePath: state.extra as String?),
    ),

    GoRoute(
      path: '/analysis-result',
      name: 'analysis-result',
      builder: (context, state) => AnalysisResultPage(
        result: (state.extra as AnalysisResult?) ?? AnalysisResult.demo(),
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

  // ini buat cek status login
  redirect: (context, state) {
    return null;
  },
);
