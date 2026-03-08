import 'package:flutter/material.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/presentation/pages/focus_session_page.dart';
import 'package:mindease/presentation/pages/home_shell.dart';

class FocusSummaryPage extends StatelessWidget {
  final int completedMinutes;

  const FocusSummaryPage({super.key, required this.completedMinutes});

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    return Scaffold(
      backgroundColor: brand.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, color: brand.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'MindEase Focus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: brand.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              Icon(Icons.spa_rounded, size: 120, color: brand.secondary),

              const SizedBox(height: 40),

              Text(
                'Bom trabalho! Que tal uma pausa agora?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: brand.textMain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Você se dedicou e merece um momento para respirar. Pequenas pausas ajudam a manter sua mente clara e focada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: brand.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            const FocusSessionPage(startInRestMode: true),
                      ),
                    );
                  },
                  icon: Icon(Icons.timer_outlined, color: brand.surface),
                  label: Text(
                    'Fazer uma pausa de 3 min',
                    style: TextStyle(
                      color: brand.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.home_outlined, color: brand.textMain),
                  label: Text(
                    'Voltar para o início',
                    style: TextStyle(
                      color: brand.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand.backgroundAlt,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: brand.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sessão de foco: $completedMinutes minutos concluídos',
                    style: TextStyle(
                      color: brand.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
