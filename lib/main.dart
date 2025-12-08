import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:deepshield/src/config/theme.dart';
import 'package:deepshield/src/presentation/screens/splash/splash_screen.dart';
import 'package:deepshield/src/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const DeepShieldApp());
}

class DeepShieldApp extends StatelessWidget {
  const DeepShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepShield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
