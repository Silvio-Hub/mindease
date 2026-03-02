import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/presentation/controllers/pomodoro_cubit.dart';
import 'package:mindease/presentation/pages/focus_summary_page.dart';

class FocusSessionPage extends StatefulWidget {
  final bool startInRestMode;
  final Task? task;

  const FocusSessionPage({super.key, this.startInRestMode = false, this.task});

  @override
  State<FocusSessionPage> createState() => _FocusSessionPageState();
}

class _FocusSessionPageState extends State<FocusSessionPage> {
  late List<Map<String, dynamic>> _checklist;

  @override
  void initState() {
    super.initState();
    _checklist =
        widget.task?.checklist
            .map((item) => {'title': item, 'done': false})
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final duration = widget.task?.durationMinutes ?? 45;
        return PomodoroCubit(
          work: Duration(minutes: duration),
          rest: const Duration(minutes: 5),
          startInRestMode: widget.startInRestMode,
        );
      },
      child: BlocListener<PomodoroCubit, PomodoroState>(
        listener: (context, state) {
          if (state.status == PomodoroStatus.finishedWork) {
            final duration = widget.task?.durationMinutes ?? 45;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => FocusSummaryPage(completedMinutes: duration),
              ),
            );
          } else if (state.status == PomodoroStatus.finishedRest) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Intervalo finalizado. Vamos focar!'),
                backgroundColor: Brand.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<PomodoroCubit, PomodoroState>(
          builder: (context, state) {
            final isWork = state.isWorkPhase;
            final primaryColor = isWork ? Brand.primary : Brand.restPrimary;
            final backgroundColor = isWork
                ? Brand.background
                : Brand.restBackground;

            return Scaffold(
              backgroundColor: backgroundColor,
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
                          Icon(
                            isWork ? Icons.psychology : Icons.coffee_rounded,
                            color: primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isWork ? 'MindEase Focus' : 'MindEase Intervalo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Stack(
                        children: [
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Brand.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Container(
                            height: 4,
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isWork ? 'CICLO 1 DE 1' : 'INTERVALO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Brand.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 40),

                      BlocBuilder<PomodoroCubit, PomodoroState>(
                        builder: (context, state) {
                          final minutes = state.remaining.inMinutes
                              .toString()
                              .padLeft(2, '0');
                          final seconds = state.remaining.inSeconds
                              .remainder(60)
                              .toString()
                              .padLeft(2, '0');

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _TimerCard(
                                value: minutes,
                                label: 'MINUTOS',
                                color: primaryColor,
                              ),
                              const SizedBox(width: 16),
                              _TimerCard(
                                value: seconds,
                                label: 'SEGUNDOS',
                                color: primaryColor,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      Text(
                        widget.task?.title ?? 'Sessão de Foco',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Brand.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mantenha o foco. Você está indo bem.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Brand.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      if (_checklist.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Brand.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: _checklist.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Brand.backgroundAlt,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CheckboxListTile(
                                  value: item['done'] as bool,
                                  onChanged: (value) {
                                    setState(() {
                                      _checklist[index]['done'] = value!;
                                    });
                                  },
                                  title: Text(
                                    item['title'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Brand.textMain,
                                      decoration: (item['done'] as bool)
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  activeColor: primaryColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  checkboxShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const Spacer(),

                      BlocBuilder<PomodoroCubit, PomodoroState>(
                        builder: (context, state) {
                          final isRunning = state.running;
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (isRunning) {
                                      context.read<PomodoroCubit>().pause();
                                    } else {
                                      context.read<PomodoroCubit>().start();
                                    }
                                  },
                                  icon: Icon(
                                    isRunning
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Brand.textSecondary,
                                  ),
                                  label: Text(
                                    isRunning ? 'Pausar' : 'Retomar',
                                    style: TextStyle(
                                      color: Brand.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Brand.backgroundAlt,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const FocusSummaryPage(
                                          completedMinutes: 15,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Brand.surface,
                                  ),
                                  label: const Text(
                                    'Finalizar',
                                    style: TextStyle(
                                      color: Brand.surface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      TextButton.icon(
                        onPressed: () =>
                            _showExitConfirmationDialog(context, primaryColor),
                        icon: Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Brand.textSecondary,
                        ),
                        label: Text(
                          'Sair do foco',
                          style: TextStyle(
                            color: Brand.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showExitConfirmationDialog(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, size: 48, color: primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Deseja sair do foco?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Brand.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Se você sair agora, o progresso deste ciclo de foco não será salvo.',
                style: TextStyle(fontSize: 14, color: Brand.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continuar no foco',
                    style: TextStyle(
                      color: Brand.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Sim, sair agora',
                  style: TextStyle(
                    color: Brand.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const _TimerCard({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Brand.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Brand.shadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color ?? Brand.textMain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Brand.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
