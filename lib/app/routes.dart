import 'package:berseri/features/analysis/history_page.dart';
import 'package:berseri/features/analysis/result_page.dart';
import 'package:berseri/features/auth/login_page.dart';
import 'package:berseri/features/auth/register_page.dart';
import 'package:berseri/features/camera/camera_page.dart';
import 'package:berseri/features/diagnosis/analysis_loading_page.dart';
import 'package:berseri/features/diagnosis/analysis_result_model.dart';
import 'package:berseri/features/diagnosis/analysis_result_page.dart';
import 'package:berseri/features/diagnosis/diagnosis_page.dart';
import 'package:berseri/features/home/home_page.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:berseri/features/ingredients/ingredient_detail_page.dart';
import 'package:berseri/features/profile/profile_page.dart';
import 'package:berseri/features/questionnaire/presentation/questionnaire_page.dart';
import 'package:berseri/features/routine/routine_page.dart';
import 'package:berseri/features/splash/splash_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  // Buat ngetes halamanmu, ubah sementara jadi '/analysis-loading'
  // atau '/questionnaire'. Balikin ke '/splash' sebelum commit.
  initialLocation: '/splash',
  routes: [

    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
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
        if (state.matchedLocation == '/auth') {
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
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),

    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) => const ResultPage(),
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

    // ===== route punya wahyu =====
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
    // =============================

    GoRoute(
      path: '/ingredient-detail',
      name: 'ingredient-detail',
      builder: (context, state) {
        final ingredient = state.extra as Ingredient? ?? ingredientLibrary.first;
        return IngredientDetailPage(ingredient: ingredient);
      },
    ),

    // lanjutin routenya...
  ],

  // ini buat cek status login
  redirect: (context, state) {
    return null;
  },
);