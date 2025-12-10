import 'package:flutter/material.dart';

import '../data/models/analysis_result.dart';
import '../data/models/report_summary.dart';
import '../data/models/deepfake_request.dart';
import '../presentation/screens/analysis/analysis_progress_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/auth/welcome_screen.dart';
import '../presentation/screens/home/home_shell.dart';
import '../presentation/screens/report/report_screen.dart';
import '../presentation/screens/result/result_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const analysisProgress = '/analysis-progress';
  static const result = '/result';
  static const report = '/report';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case AppRoutes.analysisProgress:
        final media = settings.arguments as DeepfakeRequest;
        return MaterialPageRoute(
          builder: (_) => AnalysisProgressScreen(request: media),
        );
      case AppRoutes.result:
        final result = settings.arguments as AnalysisResult;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        );
      case AppRoutes.report:
        final summary = settings.arguments as ReportSummary;
        return MaterialPageRoute(
          builder: (_) => ReportScreen(summary: summary),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
