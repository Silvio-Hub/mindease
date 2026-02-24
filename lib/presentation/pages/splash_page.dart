import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'home_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AccessibilityCubit>();
      final navigator = Navigator.of(context);
      cubit.init().then((_) {
        if (!mounted) return;
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
