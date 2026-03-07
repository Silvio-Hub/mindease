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

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

enum TaskViewMode { list, kanban }

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedDateFilterIndex = 0;
  TaskViewMode _viewMode = TaskViewMode.list;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  List<Task> _filterTasks(List<Task> tasks, TaskEnergy? userEnergy) {
    final filtered = tasks.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      bool matchesDate = false;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      // taskDate is already stripped of time in previous logic, but let's be safe
      // and use _isSameDay with original t.dueDate if possible.

      if (_selectedDateFilterIndex == 0) {
        matchesDate = _isSameDay(t.scheduledFor, today);
      } else if (_selectedDateFilterIndex == 1) {
        matchesDate = _isSameDay(t.scheduledFor, tomorrow);
      } else {
        // Other days: not today AND not tomorrow
        matchesDate =
            !_isSameDay(t.scheduledFor, today) &&
            !_isSameDay(t.scheduledFor, tomorrow);
      }

      return matchesSearch && matchesDate;
    }).toList();

    filtered.sort((a, b) {
      if (userEnergy != null) {
        final scoreA = _getEnergyScore(a.energy, userEnergy);
        final scoreB = _getEnergyScore(b.energy, userEnergy);
        final energyComparison = scoreA.compareTo(scoreB);
        if (energyComparison != 0) return energyComparison;
      }

      return a.scheduledFor.compareTo(b.scheduledFor);
    });

    return filtered;
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
    final accessibilityState = context.watch<AccessibilityCubit>().state;
    final energyLevel = accessibilityState.energyLevel;
    final infoDensity =
        accessibilityState.infoDensity ?? InfoDensity.equilibrada;
    final theme = Theme.of(context);
    final title = _viewMode == TaskViewMode.kanban
        ? 'Quadro Kanban'
        : 'Lista de Tarefas';
    final subtitle = _viewMode == TaskViewMode.kanban
        ? 'Visualize o progresso das suas atividades.'
        : 'Sua lista organizada por prioridade.';

    return Scaffold(
      backgroundColor: Brand.backgroundAlt,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Brand.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Brand.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Brand.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _ViewToggleButton(
                          label: 'Lista',
                          isSelected: _viewMode == TaskViewMode.list,
                          onTap: () =>
                              setState(() => _viewMode = TaskViewMode.list),
                        ),
                        _ViewToggleButton(
                          label: 'Kanban',
                          isSelected: _viewMode == TaskViewMode.kanban,
                          onTap: () =>
                              setState(() => _viewMode = TaskViewMode.kanban),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Procurar tarefa...',
                  prefixIcon: Icon(Icons.search, color: Brand.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Brand.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Brand.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Brand.primary),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _DateFilterChip(
                    label: 'Hoje',
                    isSelected: _selectedDateFilterIndex == 0,
                    onTap: () => setState(() => _selectedDateFilterIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _DateFilterChip(
                    label: 'Amanhã',
                    isSelected: _selectedDateFilterIndex == 1,
                    onTap: () => setState(() => _selectedDateFilterIndex = 1),
                  ),
                  const SizedBox(width: 8),
                  _DateFilterChip(
                    label: 'Outro dia',
                    isSelected: _selectedDateFilterIndex == 2,
                    icon: Icons.calendar_today,
                    onTap: () => setState(() => _selectedDateFilterIndex = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: BlocBuilder<TasksBloc, TasksState>(
                builder: (ctx, state) {
                  final filtered = _filterTasks(state.tasks, energyLevel);

                  if (_viewMode == TaskViewMode.kanban) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: Brand.primary,
                          unselectedLabelColor: Brand.textSecondary,
                          indicatorColor: Brand.primary,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: Brand.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          tabs: const [
                            Tab(text: 'PENDENTE'),
                            Tab(text: 'EM PROGRESSO'),
                            Tab(text: 'CONCLUÍDO'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _TaskListView(
                                items: filtered
                                    .where((t) => !t.inProgress && !t.completed)
                                    .toList(),
                                emptyMessage: 'Nenhuma tarefa pendente.',
                                emptyIcon: Icons.playlist_add,
                                statusColor: Brand.textSecondary,
                                density: infoDensity,
                              ),
                              _TaskListView(
                                items: filtered
                                    .where((t) => t.inProgress && !t.completed)
                                    .toList(),
                                emptyMessage: 'Nenhuma tarefa em progresso.',
                                emptyIcon: Icons.self_improvement,
                                statusColor: Brand.warning,
                                density: infoDensity,
                              ),
                              _TaskListView(
                                items: filtered
                                    .where((t) => t.completed)
                                    .toList(),
                                emptyMessage: 'Nenhuma tarefa concluída.',
                                emptyIcon: Icons.check_circle_outline,
                                statusColor: Brand.success,
                                isDone: true,
                                density: infoDensity,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.spa,
                            size: 64,
                            color: Brand.primary.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sua lista está limpa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Brand.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Que tal aproveitar este momento para planejar algo novo?',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Brand.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filtered.length + 1, // +1 for spacing at bottom
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return const SizedBox(height: 80);
                      }
                      final task = filtered[index];
                      return _TaskCard(task: task, density: infoDensity);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddTaskPage(
                initialDateOption: _selectedDateFilterIndex > 1
                    ? 1
                    : _selectedDateFilterIndex,
              ),
            ),
          );

          if (!context.mounted) return;

          if (result is Map) {
            final id = FirebaseFirestore.instance.collection('tasks').doc().id;
            final title = (result['title'] as String?) ?? 'Nova tarefa';
            final steps =
                (result['subtasks'] as List?)?.cast<String>() ?? const [];
            final duration =
                result['focusDuration'] as FocusDuration? ??
                FocusDuration.medium;
            final energy = result['energy'] as TaskEnergy? ?? TaskEnergy.medium;
            final dueDate =
                result['scheduledFor'] as DateTime? ?? DateTime.now();

            context.read<TasksBloc>().add(
              AddTask(
                Task(
                  id: id,
                  userId: '', // ID será preenchido pelo Bloc
                  title: title,
                  subtasks: steps,
                  focusDuration: duration,
                  energy: energy,
                  scheduledFor: dueDate,
                  createdAt: DateTime.now(),
                ),
              ),
            );
          }
        },
        label: const Text('Nova Tarefa'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: Brand.primary,
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Brand.surface : Brand.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Brand.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Brand.primary : Brand.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final InfoDensity density;

  const _TaskCard({required this.task, required this.density});

  @override
  Widget build(BuildContext context) {
    Color energyColor;
    Color energyBgColor;
    String energyLabel;

    switch (task.energy) {
      case TaskEnergy.high:
        energyColor = Brand.energyHighText;
        energyBgColor = Brand.energyHighBg;
        energyLabel = 'Energia: Alta';
        break;
      case TaskEnergy.medium:
        energyColor = Brand.energyMediumText;
        energyBgColor = Brand.energyMediumBg;
        energyLabel = 'Energia: Média';
        break;
      case TaskEnergy.low:
        energyColor = Brand.energyLowText;
        energyBgColor = Brand.energyLowBg;
        energyLabel = 'Energia: Baixa';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Brand.border),
        boxShadow: [
          BoxShadow(
            color: Brand.textMain.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Brand.transparent,
        child: InkWell(
          onTap: () {
            context.read<TasksBloc>().add(
              UpdateTask(task.copyWith(completed: !task.completed)),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.completed ? Brand.primary : Brand.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.completed ? Brand.primary : Brand.textLight,
                      width: 2,
                    ),
                  ),
                  child: task.completed
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Brand.textWhite,
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.completed
                              ? Brand.textLight
                              : Brand.textMain,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (density != InfoDensity.simples)
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Brand.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.focusDuration.minutes}m',
                              style: TextStyle(
                                fontSize: 12,
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
                                color: energyBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    size: 12,
                                    color: energyColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    energyLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: energyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (density == InfoDensity.detalhada &&
                          task.subtasks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Brand.border, height: 1),
                        const SizedBox(height: 8),
                        ...task.subtasks
                            .take(3)
                            .map(
                              (step) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Brand.transparent,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Brand.textLight,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: TextStyle(
                                          color: Brand.textSecondary,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        if (task.subtasks.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+ ${task.subtasks.length - 3} itens',
                              style: const TextStyle(
                                color: Brand.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                _TaskOptionsButton(task: task, showMoveOptions: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _DateFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Brand.primary : Brand.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Brand.primary : Brand.border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Brand.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Brand.textWhite : Brand.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Brand.textWhite : Brand.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskListView extends StatelessWidget {
  final List<Task> items;
  final String emptyMessage;
  final IconData emptyIcon;
  final Color statusColor;
  final bool isDone;
  final InfoDensity density;

  const _TaskListView({
    required this.items,
    required this.emptyMessage,
    required this.emptyIcon,
    this.statusColor = Brand.textSecondary,
    this.isDone = false,
    required this.density,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Brand.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Brand.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = items[index];
        return _TaskCard(task: task, density: density);
      },
    );
  }
}

class _TaskOptionsButton extends StatelessWidget {
  final Task task;
  final bool showMoveOptions;

  const _TaskOptionsButton({required this.task, this.showMoveOptions = true});

  @override
  Widget build(BuildContext context) {
    String? moveAction;
    String? moveLabel;

    if (showMoveOptions) {
      if (!task.completed && !task.inProgress) {
        moveAction = 'move_progress';
        moveLabel = 'Mover para "Em progresso"';
      } else if (task.inProgress && !task.completed) {
        moveAction = 'move_done';
        moveLabel = 'Mover para "Concluído"';
      }
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Brand.textLight),
      onSelected: (value) async {
        if (value == 'start') {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => FocusSessionPage(task: task)),
          );
        } else if (value == 'edit') {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditTaskPage(task: task)),
          );

          if (result != null && context.mounted) {
            final updatedTask = task.copyWith(
              title: result['title'],
              subtasks: (result['subtasks'] as List?)?.cast<String>() ?? [],
              focusDuration: result['focusDuration'],
              energy: result['energy'],
              scheduledFor: result['scheduledFor'],
            );
            context.read<TasksBloc>().add(UpdateTask(updatedTask));
          }
        } else if (value == 'move_progress') {
          context.read<TasksBloc>().add(
            MoveTask(task.id, inProgress: true, completed: false),
          );
        } else if (value == 'move_done') {
          context.read<TasksBloc>().add(
            MoveTask(task.id, inProgress: false, completed: true),
          );
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Excluir tarefa?'),
              content: const Text('Essa ação não pode ser desfeita.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Brand.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Excluir',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            context.read<TasksBloc>().add(DeleteTask(task.id));
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: Brand.textSecondary),
              SizedBox(width: 12),
              Text('Editar detalhes'),
            ],
          ),
        ),
        if (moveAction != null)
          PopupMenuItem<String>(
            value: moveAction,
            child: Row(
              children: [
                Icon(Icons.arrow_forward, size: 20, color: Brand.textSecondary),
                SizedBox(width: 12),
                Text(moveLabel!),
              ],
            ),
          ),
        const PopupMenuItem<String>(
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
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Excluir tarefa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
