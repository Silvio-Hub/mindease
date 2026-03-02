import 'package:flutter/material.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/presentation/pages/focus_session_page.dart';
import 'package:mindease/presentation/pages/home_shell.dart';

class FocusSummaryPage extends StatelessWidget {
  final int completedMinutes;

  const FocusSummaryPage({super.key, required this.completedMinutes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Brand.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MindEase Focus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Brand.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Plant Illustration (Using Icon as placeholder)
              const Icon(
                Icons.spa_rounded,
                size: 120,
                color: Brand.secondary,
              ),

              const SizedBox(height: 40),

              const Text(
                'Bom trabalho! Que tal uma pausa agora?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Brand.textMain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Você se dedicou e merece um momento para respirar. Pequenas pausas ajudam a manter sua mente clara e focada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // Button: Fazer uma pausa
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to FocusSessionPage in Rest Mode
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const FocusSessionPage(startInRestMode: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timer_outlined, color: Colors.white),
                  label: const Text(
                    'Fazer uma pausa de 3 min', // Assuming fixed duration for now
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Button: Voltar para o início
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_outlined, color: Brand.textMain),
                  label: const Text(
                    'Voltar para o início',
                    style: TextStyle(
                      color: Brand.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.backgroundGrey, // Light grey bg
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Sessão de foco: $completedMinutes minutos concluídos',
                    style: const TextStyle(
                      color: Colors.grey,
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
