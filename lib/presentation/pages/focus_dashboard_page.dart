import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/entities/user_preferences.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';
import 'package:mindease/presentation/pages/add_task_page.dart';
import 'package:mindease/presentation/pages/edit_task_page.dart';
import 'package:mindease/presentation/pages/focus_session_page.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/domain/entities/user.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';

class FocusDashboardPage extends StatefulWidget {
  final VoidCallback? onSeeAllTasks;

  const FocusDashboardPage({super.key, this.onSeeAllTasks});

  @override
  State<FocusDashboardPage> createState() => _FocusDashboardPageState();
}

class _FocusDashboardPageState extends State<FocusDashboardPage> {
  String? _focusTaskId;

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(LoadTasks());
  }

  Task? _getTask(List<Task> tasks) {
    if (tasks.isEmpty) return null;

    // First try to find the explicitly selected focus task
    if (_focusTaskId != null) {
      try {
        final task = tasks.firstWhere((t) => t.id == _focusTaskId);
        // If the task is done, we might want to clear focus or keep it?
        // Let's keep it for now, or clear it if we want to auto-switch.
        return task;
      } catch (_) {
        // Task not found (maybe deleted), reset focus
        // Don't call setState here during build
      }
    }

    // Default to first pending or in-progress task
    try {
      // Prioritize in-progress
      try {
        return tasks.firstWhere((t) => t.inProgress && !t.completed);
      } catch (_) {
        // Then pending
        return tasks.firstWhere((t) => !t.completed);
      }
    } catch (_) {
      return null; // All done or empty
    }
  }

  void _promoteTaskToFocus(Task task) {
    setState(() {
      _focusTaskId = task.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agora focando em: ${task.title}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEditFocusTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskPage(task: task)),
    );

    if (!mounted) return;

    if (result != null && result is Map) {
      final updated = task.copyWith(
        title: result['title'],
        subtasks: (result['subtasks'] as List?)?.cast<String>() ?? [],
        focusDuration: result['focusDuration'],
        energy: result['energy'],
        scheduledFor: result['scheduledFor'],
      );

      context.read<TasksBloc>().add(UpdateTask(updated));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa em foco atualizada!')),
      );
    }
  }

  void _onDeleteFocusTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa em foco'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TasksBloc>().add(DeleteTask(task.id));

              if (_focusTaskId == task.id) {
                setState(() => _focusTaskId = null);
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarefa em foco excluída!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Brand.error)),
          ),
        ],
      ),
    );
  }

  void _onAddNewFocusTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskPage()),
    );

    if (result != null && result is Map && mounted) {
      final newTask = Task(
        id: FirebaseFirestore.instance.collection('tasks').doc().id,
        userId: '', // Bloc will fill this
        title: result['title'],
        subtasks: (result['subtasks'] as List?)?.cast<String>() ?? [],
        focusDuration: result['focusDuration'],
        energy: result['energy'],
        scheduledFor: result['scheduledFor'],
        createdAt: DateTime.now(),
      );

      context.read<TasksBloc>().add(AddTask(newTask));

      // Auto-focus on new task
      setState(() {
        _focusTaskId = newTask.id;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nova tarefa em foco!')));
    }
  }

  void _onEditTaskInList(Task task) async {
    _onEditFocusTask(task);
  }

  void _onDeleteTaskInList(Task task) {
    // Use generic delete but handle UI feedback appropriately
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TasksBloc>().add(DeleteTask(task.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarefa excluída com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Brand.error)),
          ),
        ],
      ),
    );
  }

  void _onStartFocusSession(Task task) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FocusSessionPage(task: task)));
  }

  int _getEnergyScore(TaskEnergy? taskEnergy, TaskEnergy userEnergy) {
    if (taskEnergy == null) return 3;

    if (taskEnergy == userEnergy) return 0;

    if (userEnergy == TaskEnergy.low) {
      if (taskEnergy == TaskEnergy.medium) return 1;
      if (taskEnergy == TaskEnergy.high) return 2;
    }

    if (userEnergy == TaskEnergy.medium) {
      if (taskEnergy == TaskEnergy.low) return 1;
      if (taskEnergy == TaskEnergy.high) return 2;
    }

    if (userEnergy == TaskEnergy.high) {
      if (taskEnergy == TaskEnergy.medium) return 1;
      if (taskEnergy == TaskEnergy.low) return 2;
    }

    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        final accessibilityState = context.watch<AccessibilityCubit>().state;
        final energyLevel = accessibilityState.energyLevel;
        final infoDensity =
            accessibilityState.infoDensity ?? InfoDensity.equilibrada;
        var allTasks = List<Task>.from(state.tasks);

        allTasks.sort((a, b) {
          if (energyLevel != null) {
            final scoreA = _getEnergyScore(a.energy, energyLevel);
            final scoreB = _getEnergyScore(b.energy, energyLevel);
            final energyComparison = scoreA.compareTo(scoreB);
            if (energyComparison != 0) return energyComparison;
          }

          // Task.scheduledFor is required, so no null check needed
          return a.scheduledFor.compareTo(b.scheduledFor);
        });

        final currentFocusTask = _getTask(allTasks);

        // Filter out the focus task from the list below and only show pending/in-progress
        final otherTasks = allTasks
            .where((t) => t.id != currentFocusTask?.id && !t.completed)
            .take(2)
            .toList();

        return Scaffold(
          backgroundColor: Brand.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 24),

                  _FocusCard(
                    task: currentFocusTask,
                    onEdit: () => _onEditFocusTask(currentFocusTask!),
                    onDelete: () => _onDeleteFocusTask(currentFocusTask!),
                    onStart: () => _onStartFocusSession(currentFocusTask!),
                    onAdd: _onAddNewFocusTask,
                    density: infoDensity,
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Próximas Tarefas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Brand.textMain,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onSeeAllTasks,
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            color: Brand.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (otherTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'Nenhuma tarefa pendente.',
                          style: TextStyle(color: Brand.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...otherTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _TaskItem(
                          task: task,
                          onEdit: () => _onEditTaskInList(task),
                          onDelete: () => _onDeleteTaskInList(task),
                          onStartFocus: () => _promoteTaskToFocus(task),
                          density: infoDensity,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  const _WellBeingTip(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: sl<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        final userName = snapshot.data?.fullName ?? '';
        final firstName = userName.trim().isNotEmpty
            ? userName.trim().split(' ').first
            : 'Visitante';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá $firstName, como você está hoje?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Brand.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aqui está o seu foco para este momento.',
              style: TextStyle(fontSize: 16, color: Brand.textSecondary),
            ),
          ],
        );
      },
    );
  }
}

class _FocusCard extends StatelessWidget {
  final Task? task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStart;
  final VoidCallback onAdd;
  final InfoDensity density;

  const _FocusCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStart,
    required this.onAdd,
    required this.density,
  });

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Brand.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Brand.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Brand.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Você não tem nenhuma tarefa em foco no momento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Brand.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Brand.primary,
                foregroundColor: Brand.textWhite,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Adicionar tarefa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Brand.textMain.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (density != InfoDensity.simples)
            Container(
              color: Brand.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Brand.surface.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.adjust_rounded,
                      color: Brand.textWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'EM FOCO AGORA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Brand.textWhite,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task!.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Brand.textMain,
                    height: 1.2,
                  ),
                ),
                if (density != InfoDensity.simples) ...[
                  const SizedBox(height: 12),
                  Text(
                    'De acordo com o seu painel cognitivo, esta é a tarefa que mais merece sua atenção agora.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Brand.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                if (density == InfoDensity.detalhada &&
                    task!.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...task!.subtasks
                      .take(3)
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Brand.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step,
                                  style: const TextStyle(
                                    color: Brand.textSecondary,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (task!.subtasks.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${task!.subtasks.length - 3} itens',
                        style: const TextStyle(
                          color: Brand.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Brand.secondary,
                          foregroundColor: Brand.textWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text(
                          'Iniciar foco',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Brand.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Brand.textSecondary,
                        ),
                        tooltip: 'Mais opções',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Brand.textSecondary,
                                ),
                                SizedBox(width: 12),
                                Text('Editar detalhes'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Brand.error,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Excluir tarefa',
                                  style: TextStyle(color: Brand.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStartFocus;
  final InfoDensity density;

  const _TaskItem({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStartFocus,
    required this.density,
  });

  @override
  Widget build(BuildContext context) {
    Color energyColor;
    Color energyTextColor;
    String energyLabel;

    switch (task.energy) {
      case TaskEnergy.high:
        energyColor = Brand.energyHighBg;
        energyTextColor = Brand.energyHighText;
        energyLabel = 'Energia: Alta';
        break;
      case TaskEnergy.medium:
        energyColor = Brand.energyMediumBg;
        energyTextColor = Brand.energyMediumText;
        energyLabel = 'Energia: Média';
        break;
      case TaskEnergy.low:
        energyColor = Brand.energyLowBg;
        energyTextColor = Brand.energyLowText;
        energyLabel = 'Energia: Baixa';
        break;
    }
    final duration = '${task.focusDuration.minutes}m';

    return GestureDetector(
      onTap: onStartFocus,
      child: Container(
        decoration: BoxDecoration(
          color: Brand.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Brand.textMain.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: Brand.textLight, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Brand.textMain,
                    ),
                  ),
                  if (density != InfoDensity.simples) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Brand.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 14,
                            color: Brand.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: energyColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt,
                                size: 14,
                                color: energyTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                energyLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: energyTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward, size: 20),
              color: Brand.primary,
              tooltip: 'Promover para Foco',
              onPressed: onStartFocus,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Brand.textLight),
              tooltip: 'Mais opções',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'start') {
                  onStartFocus();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Brand.textSecondary,
                      ),
                      SizedBox(width: 12),
                      Text('Editar detalhes'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'start',
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_outlined,
                        size: 20,
                        color: Brand.textSecondary,
                      ),
                      SizedBox(width: 12),
                      Text('Iniciar foco'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Brand.error),
                      SizedBox(width: 12),
                      Text(
                        'Excluir tarefa',
                        style: TextStyle(color: Brand.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WellBeingTip extends StatelessWidget {
  const _WellBeingTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Brand.tipBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Brand.tipBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Brand.secondary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dica de Bem-estar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Brand.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lembre-se de beber água entre os blocos de foco. Pequenas pausas ajudam seu cérebro a processar informações e evitam o esgotamento.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Brand.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
