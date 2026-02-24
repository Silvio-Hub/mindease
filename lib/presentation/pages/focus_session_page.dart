import 'package:flutter/material.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/presentation/controllers/pomodoro_cubit.dart';
import 'success_page.dart';

class FocusSessionPage extends StatefulWidget {
  const FocusSessionPage({super.key});
  @override
  State<FocusSessionPage> createState() => _FocusSessionPageState();
}

class _FocusSessionPageState extends State<FocusSessionPage> {
  final tasks = [
    {'title': 'Esboçar seções', 'done': true},
    {'title': 'Escrever resumo executivo', 'done': false},
    {'title': 'Adicionar gráficos', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF6F7FB), Color(0xFFF9FAFF)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocProvider(
              create: (_) => PomodoroCubit(work: const Duration(minutes: 25), rest: const Duration(minutes: 5)),
              child: BlocBuilder<PomodoroCubit, PomodoroState>(
                builder: (ctx, pomodoro) {
                  final minutes = pomodoro.remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
                  final seconds = pomodoro.remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
                  return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FOCO ATUAL',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.5,
                          color: Brand.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Finalizar Proposta do Projeto', style: theme.textTheme.titleLarge),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 220,
                    width: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Brand.primary.withValues(alpha: 0.25), width: 10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x14000000), blurRadius: 12, spreadRadius: 2),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$minutes:$seconds', style: theme.textTheme.displaySmall?.copyWith(color: Brand.primary)),
                            const SizedBox(height: 6),
                            Text('RESTANTES', style: theme.textTheme.labelMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < tasks.length; i++)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: CheckboxListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      checkboxShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                      activeColor: Brand.primary,
                      value: tasks[i]['done'] as bool,
                      onChanged: (v) => setState(() => tasks[i]['done'] = v ?? false),
                      title: Text(tasks[i]['title'] as String),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: pomodoro.running
                          ? OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () => ctx.read<PomodoroCubit>().pause(),
                              icon: const Icon(Icons.pause),
                              label: const Text('Pausar'),
                            )
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: const StadiumBorder(),
                                backgroundColor: Brand.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => ctx.read<PomodoroCubit>().start(),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Começar'),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: const StadiumBorder(),
                          elevation: 3,
                          backgroundColor: Brand.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const SuccessPage()),
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Concluir'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: Brand.primary.withValues(alpha: 0.6)),
                    child: const Text('Encerrar Sessão Cedo'),
                  ),
                ),
              ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
