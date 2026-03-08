import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/presentation/controllers/pomodoro_cubit.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';

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
    _checklist = (widget.task?.subtasks ?? [])
        .map((item) => {'title': item, 'done': false})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    return BlocProvider(
      create: (_) {
        final duration = widget.task?.focusDuration.minutes ?? 45;
        return PomodoroCubit(
          focusMinutes: duration,
          startInRestMode: widget.startInRestMode,
        );
      },
      child: BlocListener<PomodoroCubit, PomodoroState>(
        listener: (context, state) {
          if (state.status == PomodoroStatus.finishedWork) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Foco finalizado! Iniciando intervalo...'),
                backgroundColor: brand.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.status == PomodoroStatus.finishedRest) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Intervalo finalizado. Vamos focar!'),
                backgroundColor: brand.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<PomodoroCubit, PomodoroState>(
          builder: (context, state) {
            final isWork = state.isWorkPhase;
            final primaryColor = isWork ? brand.primary : brand.success;

            return Scaffold(
              backgroundColor: isWork ? brand.background : brand.restBackground,
              body: isWork
                  ? _buildFocusView(context, state, primaryColor)
                  : _buildBreakView(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFocusView(
    BuildContext context,
    PomodoroState state,
    Color primaryColor,
  ) {
    final brand = Brand.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // Header
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.psychology, color: primaryColor, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'MindEase Focus',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildCycleIndicator(context, state, primaryColor),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SESSÃO DE ${widget.task?.focusDuration.minutes ?? 45} MINUTOS',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Builder(
                      builder: (context) {
                        final isSpecialMode = state.maxCycles == 3;
                        Duration displayTime = state.remaining;

                        if (isSpecialMode &&
                            state.phase == PomodoroPhase.foco) {
                          final futureCycles = state.maxCycles - state.cycle;
                          if (futureCycles >= 0) {
                            int cycleDurationMinutes = 5;
                            if (state.totalDuration.inMinutes >= 15) {
                              cycleDurationMinutes = 15;
                            } else if (state.totalDuration.inMinutes >= 10) {
                              cycleDurationMinutes = 10;
                            }

                            displayTime =
                                state.remaining +
                                Duration(
                                  minutes: futureCycles * cycleDurationMinutes,
                                );
                          }
                        }

                        final minutes = displayTime.inMinutes
                            .toString()
                            .padLeft(2, '0');
                        final seconds = displayTime.inSeconds
                            .remainder(60)
                            .toString()
                            .padLeft(2, '0');

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _TimerCard(
                              value: minutes,
                              label: 'MINUTOS',
                              color: brand.textMain,
                            ),
                            const SizedBox(width: 16),
                            _TimerCard(
                              value: seconds,
                              label: 'SEGUNDOS',
                              color: brand.textMain,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Text(
                      widget.task?.title ?? 'Sessão de Foco',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brand.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mantenha o foco. Você está indo bem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: brand.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    if (_checklist.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: BoxDecoration(
                          color: brand.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: brand.shadow,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: _checklist.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: brand.backgroundAlt,
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
                                    color: brand.textMain,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (state.running) {
                        context.read<PomodoroCubit>().pause();
                      } else {
                        context.read<PomodoroCubit>().start();
                      }
                    },
                    icon: Icon(
                      state.running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: brand.textMain,
                    ),
                    label: Text(
                      state.running ? 'Pausar' : 'Começar',
                      style: TextStyle(
                        color: brand.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand.border,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<PomodoroCubit>().reset();
                      if (widget.task != null) {
                        context.read<TasksBloc>().add(
                          MoveTask(
                            widget.task!.id,
                            inProgress: false,
                            completed: true,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Tarefa concluída!'),
                            backgroundColor: brand.success,
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.check_circle_outline_rounded,
                      color: brand.textWhite,
                    ),
                    label: Text(
                      'Finalizar',
                      style: TextStyle(
                        color: brand.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  _showExitConfirmationDialog(context, primaryColor),
              icon: Icon(Icons.logout, color: brand.textSecondary),
              label: Text(
                'Sair do foco',
                style: TextStyle(
                  color: brand.textSecondary,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakView(BuildContext context, PomodoroState state) {
    final brand = Brand.of(context);
    final minutes = state.remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = state.remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    // Reuse primary color for the session badge as per mockup
    final sessionBadgeColor = brand.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Header
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.psychology, color: brand.restPrimary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'MindEase Focus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: brand.restPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cycle Indicator
            _buildCycleIndicator(context, state, brand.restPrimary),

            const SizedBox(height: 16),

            // Session Badge (Purple)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sessionBadgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: sessionBadgeColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SESSÃO DE ${widget.task?.focusDuration.minutes ?? 45} MINUTOS',
                    style: TextStyle(
                      color: sessionBadgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Timer Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimerCard(
                  value: minutes,
                  label: 'MINUTOS',
                  color: brand.restPrimary,
                ),
                const SizedBox(width: 16),
                _TimerCard(
                  value: seconds,
                  label: 'SEGUNDOS',
                  color: brand.restPrimary,
                ),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              'Hora de respirar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: brand.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aproveite para se alongar ou beber água.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: brand.restPrimary),
            ),

            const Spacer(),

            // Actions
            TextButton.icon(
              onPressed: () {
                context.read<PomodoroCubit>().skipBreak();
              },
              icon: Icon(Icons.skip_next_rounded, color: brand.textSecondary),
              label: Text(
                'Pular intervalo',
                style: TextStyle(color: brand.textSecondary, fontSize: 16),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
              ),
            ),

            const Spacer(),

            TextButton.icon(
              onPressed: () =>
                  _showExitConfirmationDialog(context, brand.restPrimary),
              icon: Icon(Icons.logout, color: brand.textSecondary),
              label: Text(
                'Sair do foco',
                style: TextStyle(
                  color: brand.textSecondary,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleIndicator(
    BuildContext context,
    PomodoroState state,
    Color primaryColor,
  ) {
    final brand = Brand.of(context);
    // 15 min logic removed from Cubit, so maxCycles will be 4
    final totalItems = state.maxCycles * 2;

    return Column(
      children: [
        Row(
          children: List.generate(totalItems, (index) {
            final isLastItem = index == totalItems - 1;

            bool isFocusBar = false;
            bool isLongBreak = false;
            bool isShortBreak = false;

            if (isLastItem) {
              isLongBreak = true;
            } else {
              isFocusBar = index % 2 == 0;
              isShortBreak = !isFocusBar;
            }

            int itemCycle = (index ~/ 2) + 1;

            // Define colors
            final Color focusColor = brand.primary; // Purple for Focus
            final Color breakColor = brand.success; // Green for Breaks

            if (isFocusBar) {
              bool isCompleted =
                  state.cycle > itemCycle ||
                  (state.cycle == itemCycle &&
                      state.phase != PomodoroPhase.foco);
              bool isCurrent =
                  state.cycle == itemCycle && state.phase == PomodoroPhase.foco;

              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCompleted ? focusColor : brand.backgroundAlt,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: isCurrent
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final double remainingPct =
                                state.totalDuration.inSeconds == 0
                                ? 0
                                : state.remaining.inSeconds /
                                      state.totalDuration.inSeconds;
                            final double elapsedPct = 1.0 - remainingPct;

                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: constraints.maxWidth * elapsedPct,
                                decoration: BoxDecoration(
                                  color: focusColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          },
                        )
                      : null,
                ),
              );
            } else {
              // Break Dot
              bool isCompleted = state.cycle > itemCycle;

              if (!isCompleted && state.cycle == itemCycle) {
                if (isShortBreak &&
                    state.phase == PomodoroPhase.intervaloFinal) {
                  isCompleted = true;
                }
              }

              bool isCurrent = false;
              if (isLongBreak) {
                isCurrent =
                    state.cycle == itemCycle &&
                    state.phase == PomodoroPhase.intervaloFinal;
              } else {
                isCurrent =
                    state.cycle == itemCycle &&
                    state.phase == PomodoroPhase.intervaloCurto;
              }

              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isCompleted || isCurrent)
                      ? breakColor
                      : brand.backgroundAlt,
                ),
                child: isCurrent
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final double remainingPct =
                              state.totalDuration.inSeconds == 0
                              ? 0
                              : state.remaining.inSeconds /
                                    state.totalDuration.inSeconds;
                          final double elapsedPct = 1.0 - remainingPct;

                          return Center(
                            child: Container(
                              width: constraints.maxWidth * elapsedPct,
                              height: constraints.maxHeight * elapsedPct,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: breakColor,
                              ),
                            ),
                          );
                        },
                      )
                    : null,
              );
            }
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: state.totalCycles > state.maxCycles
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            Text(
              state.phase == PomodoroPhase.foco
                  ? 'CICLO ${state.cycle} DE ${state.maxCycles}'
                  : (state.phase == PomodoroPhase.intervaloFinal
                        ? 'INTERVALO LONGO'
                        : 'INTERVALO CURTO'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: brand.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            if (state.totalCycles > state.maxCycles)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brand.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 12,
                      color: brand.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.totalCycles}º CICLO DE FOCO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showExitConfirmationDialog(BuildContext context, Color primaryColor) {
    final brand = Brand.of(context);
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
              Text(
                'Deseja sair do foco?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: brand.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Se você sair agora, o progresso deste ciclo de foco não será salvo.',
                style: TextStyle(fontSize: 14, color: brand.textSecondary),
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
                  child: Text(
                    'Continuar no foco',
                    style: TextStyle(
                      color: brand.surface,
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
                    color: brand.textSecondary,
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
    final brand = Brand.of(context);
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: brand.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: brand.shadow,
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
              color: color ?? brand.textMain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: brand.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
