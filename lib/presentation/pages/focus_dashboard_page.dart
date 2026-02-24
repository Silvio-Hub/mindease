import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'focus_session_page.dart';

class FocusDashboardPage extends StatelessWidget {
  const FocusDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Brand.neutralBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Painel de Controle',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bom dia, Alex. Vamos focar?',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FocusCard(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Próximas Tarefas', style: theme.textTheme.titleMedium),
                  TextButton(onPressed: () {}, child: const Text('Ver tudo')),
                ],
              ),
              const SizedBox(height: 8),
              _TaskPreview(
                title: 'Revisar feedbacks',
                subtitle: '10:30 • 10 min',
              ),
              _TaskPreview(
                title: 'Sincronização semanal',
                subtitle: '11:00 • 30 min',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AccessibilityCubit, AccessibilityState>(
      builder: (ctx, state) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tarefa em Foco',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Brand.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Concluir Relatório do Projeto',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Estimativa: 25 min',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FocusSessionPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Foco'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskPreview extends StatelessWidget {
  final String title;
  final String subtitle;
  const _TaskPreview({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.check_box_outline_blank),
        title: Text(title, style: theme.textTheme.bodyLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
