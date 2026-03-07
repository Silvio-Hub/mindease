import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/presentation/pages/login_page.dart';
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

      cubit.init().then((_) async {
        if (!mounted) return;

        try {
          final authRepo = sl<AuthRepository>();
          // Adicionamos um tratamento de erro aqui para não travar na splash
          final user = await authRepo
              .getCurrentUser()
              .timeout(const Duration(seconds: 10), onTimeout: () => null)
              .catchError((e) {
                debugPrint('Erro ao obter usuário atual na Splash: $e');
                return null;
              });

          if (!mounted) return;

          if (user != null) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeShell()),
            );
          } else {
            // Se der erro ou não tiver usuário, vai para login
            // Isso evita o loop infinito se o token estiver inválido ou sem permissão
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        } catch (e) {
          debugPrint('Erro fatal na SplashPage: $e');
          if (mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
