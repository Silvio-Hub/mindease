import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'tasks_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MindEase')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<AccessibilityCubit, AccessibilityState>(
          builder: (ctx, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => ctx.read<AccessibilityCubit>().setFocusMode(
                    !state.focusMode,
                  ),
                  child: Text(
                    state.focusMode ? 'Desativar Foco' : 'Ativar Foco',
                  ),
                ),
                SwitchListTile(
                  value: state.highContrast,
                  onChanged: (v) =>
                      ctx.read<AccessibilityCubit>().setHighContrast(v),
                  title: const Text('Alto Contraste'),
                ),
                const SizedBox(height: 12),
                Text(
                  state.summaryMode ? 'Modo Resumo' : 'Modo Detalhado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // [A11Y-Cog] UI simplificada e previsível para modo foco
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TasksPage()),
                    );
                  },
                  child: const Text('Organizador de Tarefas'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
