import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// AdMob is initialized via service after app start

import 'core/config/app_config.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_colors.dart';
import 'injection_container.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'services/ads/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (needed before DI/AuthBloc uses it)
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize dependencies
  await initializeDependencies();

  runApp(const SellyApp());
  // Firebase removed by request; no initialization here.
  // Initialize AdMob after app start (non-blocking)
  // ignore: discarded_futures
  AdMobService.instance.initialize().catchError((e) {
    debugPrint('AdMob init failed: $e');
  });
}

class SellyApp extends StatelessWidget {
  const SellyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
