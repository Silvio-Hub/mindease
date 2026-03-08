import 'package:flutter/material.dart';
import 'package:mindease/core/constants/brand.dart';
import 'home_shell.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = Brand.of(context);
    return Scaffold(
      backgroundColor: brand.neutralBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: brand.success,
                  child: Icon(Icons.check, color: brand.textWhite, size: 40),
                ),
                const SizedBox(height: 16),
                Text('Ótimo trabalho.', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Que tal uma pausa agora?',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Fazer uma pausa'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeShell(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Próxima tarefa'),
                ),
                const SizedBox(height: 8),
                Text('Encerrar por hoje', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
