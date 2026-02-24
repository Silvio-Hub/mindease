import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/core/theme/app_theme.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          return MaterialApp(
            title: 'MindEase',
            debugShowCheckedModeBanner: false,
            theme: lightTheme(
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
