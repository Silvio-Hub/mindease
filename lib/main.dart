import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/core/theme/app_theme.dart';
import 'package:mindease/domain/entities/user_preferences.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await setupDependencies();
  runApp(const MindEaseApp());
}

class MindEaseApp extends StatelessWidget {
  const MindEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccessibilityCubit>(),
      child: BlocBuilder<AccessibilityCubit, AccessibilityState>(
        builder: (ctx, state) {
          ThemeMode themeMode;
          switch (state.themeMode) {
            case AppThemeMode.light:
              themeMode = ThemeMode.light;
              break;
            case AppThemeMode.dark:
              themeMode = ThemeMode.dark;
              break;
            case AppThemeMode.system:
              themeMode = ThemeMode.system;
              break;
          }

          return MaterialApp(
            title: 'MindEase',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: lightTheme(
              fontScale: state.fontScale,
              spacingScale: state.spacingScale,
              highContrast: state.highContrast,
              animationsEnabled: state.animationsEnabled,
            ),
            darkTheme: darkTheme(
              fontScale: state.fontScale,
              spacingScale: state.spacingScale,
              highContrast: state.highContrast,
              animationsEnabled: state.animationsEnabled,
            ),
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
