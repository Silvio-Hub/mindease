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

      if (_selectedDateFilterIndex == 0) {
        if (_viewMode == TaskViewMode.kanban) {
          matchesDate = _isSameDay(t.scheduledFor, today);
        } else {
          matchesDate = !t.completed && !t.scheduledFor.isBefore(today);
        }
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
    final brand = Brand.of(context);
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
      backgroundColor: brand.backgroundAlt,
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
                            color: brand.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: brand.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: brand.border,
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
                style: TextStyle(color: brand.textMain),
                decoration: InputDecoration(
                  hintText: 'Procurar tarefa...',
                  hintStyle: TextStyle(color: brand.textLight),
                  prefixIcon: Icon(Icons.search, color: brand.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: brand.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: brand.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: brand.primary),
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
                          labelColor: brand.primary,
                          unselectedLabelColor: brand.textSecondary,
                          indicatorColor: brand.primary,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: brand.transparent,
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
                                statusColor: brand.textSecondary,
                                density: infoDensity,
                                onTaskTap: (task) {
                                  context.read<TasksBloc>().add(
                                    UpdateTask(task.copyWith(inProgress: true)),
                                  );
                                },
                              ),
                              _TaskListView(
                                items: filtered
                                    .where((t) => t.inProgress && !t.completed)
                                    .toList(),
                                emptyMessage: 'Nenhuma tarefa em progresso.',
                                emptyIcon: Icons.self_improvement,
                                statusColor: brand.warning,
                                density: infoDensity,
                              ),
                              _TaskListView(
                                items: filtered
                                    .where((t) => t.completed)
                                    .toList(),
                                emptyMessage: 'Nenhuma tarefa concluída.',
                                emptyIcon: Icons.check_circle_outline,
                                statusColor: brand.success,
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
                            color: brand.primary.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sua lista está limpa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: brand.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Que tal aproveitar este momento para planejar algo novo?',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: brand.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  // Split tasks for "Today" view
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  List<Task> pendingTasks = [];
                  List<Task> mainTasks = [];
                  List<Task> futureTasks = [];

                  if (_selectedDateFilterIndex == 0) {
                    pendingTasks = filtered
                        .where((t) => t.scheduledFor.isBefore(today))
                        .toList();
                    mainTasks = filtered
                        .where((t) => _isSameDay(t.scheduledFor, today))
                        .toList();
                    futureTasks = filtered
                        .where(
                          (t) =>
                              !t.scheduledFor.isBefore(today) &&
                              !_isSameDay(t.scheduledFor, today),
                        )
                        .toList();
                  } else {
                    mainTasks = filtered;
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      if (pendingTasks.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                size: 20,
                                color: brand.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TAREFAS PENDENTES',
                                style: TextStyle(
                                  color: brand.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  for (final task in pendingTasks) {
                                    context.read<TasksBloc>().add(
                                      UpdateTask(
                                        task.copyWith(scheduledFor: today),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.restore, size: 16),
                                label: const Text('Trazer todas para hoje'),
                                style: TextButton.styleFrom(
                                  backgroundColor: brand.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  foregroundColor: brand.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...pendingTasks.map(
                          (t) => _TaskCard(task: t, density: infoDensity),
                        ),
                      ],
                      if (futureTasks.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                size: 20,
                                color: brand.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PENDENTES',
                                style: TextStyle(
                                  color: brand.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  final now = DateTime.now();
                                  final today = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  for (final task in futureTasks) {
                                    context.read<TasksBloc>().add(
                                      UpdateTask(
                                        task.copyWith(scheduledFor: today),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: brand.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 16,
                                        color: brand.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Trazer todas para hoje',
                                        style: TextStyle(
                                          color: brand.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...futureTasks.map(
                          (t) => _TaskCard(
                            task: t,
                            density: infoDensity,
                            showPendingIcon: true,
                          ),
                        ),
                      ],
                      if (_selectedDateFilterIndex == 0 &&
                          (pendingTasks.isNotEmpty ||
                              mainTasks.isNotEmpty)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: brand.textMain,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PARA HOJE',
                                style: TextStyle(
                                  color: brand.textMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ...mainTasks.map(
                        (t) => _TaskCard(task: t, density: infoDensity),
                      ),
                      const SizedBox(height: 80),
                    ],
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
        backgroundColor: brand.primary,
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
    final brand = Brand.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? brand.surface : brand.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: brand.shadow,
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
            color: isSelected ? brand.primary : brand.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final InfoDensity density;
  final bool showPendingIcon;
  final VoidCallback? onTap;

  const _TaskCard({
    required this.task,
    required this.density,
    this.showPendingIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    Color energyColor;
    Color energyBgColor;
    String energyLabel;

    switch (task.energy) {
      case TaskEnergy.high:
        energyColor = brand.energyHighText;
        energyBgColor = brand.energyHighBg;
        energyLabel = 'Energia: Alta';
        break;
      case TaskEnergy.medium:
        energyColor = brand.energyMediumText;
        energyBgColor = brand.energyMediumBg;
        energyLabel = 'Energia: Média';
        break;
      case TaskEnergy.low:
        energyColor = brand.energyLowText;
        energyBgColor = brand.energyLowBg;
        energyLabel = 'Energia: Baixa';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.border),
        boxShadow: [
          BoxShadow(
            color: brand.textMain.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: brand.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    context.read<TasksBloc>().add(
                      UpdateTask(task.copyWith(completed: !task.completed)),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.completed ? brand.primary : brand.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.completed ? brand.primary : brand.textLight,
                        width: 2,
                      ),
                    ),
                    child: task.completed
                        ? Icon(Icons.check, size: 16, color: brand.textWhite)
                        : null,
                  ),
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
                              ? brand.textLight
                              : brand.textMain,
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
                              color: brand.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.focusDuration.minutes}m',
                              style: TextStyle(
                                fontSize: 12,
                                color: brand.textSecondary,
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
                          task.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: brand.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (density == InfoDensity.detalhada &&
                          task.subtasks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Divider(color: brand.border, height: 1),
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
                                          color: brand.transparent,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: brand.textLight,
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
                                          color: brand.textSecondary,
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
                              style: TextStyle(
                                color: brand.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                if (showPendingIcon)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        context.read<TasksBloc>().add(
                          UpdateTask(task.copyWith(scheduledFor: today)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.keyboard_double_arrow_down,
                          size: 20,
                          color: brand.textSecondary,
                        ),
                      ),
                    ),
                  ),
                _TaskOptionsButton(task: task),
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
    final brand = Brand.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? brand.primary : brand.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? brand.primary : brand.border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: brand.primary.withValues(alpha: 0.3),
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
                color: isSelected ? brand.textWhite : brand.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? brand.textWhite : brand.textSecondary,
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
  final Color? statusColor;
  final bool isDone;
  final InfoDensity density;
  final void Function(Task)? onTaskTap;

  const _TaskListView({
    required this.items,
    required this.emptyMessage,
    required this.emptyIcon,
    this.statusColor,
    this.isDone = false,
    required this.density,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: brand.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: brand.textSecondary),
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
        return _TaskCard(
          task: task,
          density: density,
          onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
        );
      },
    );
  }
}

class _TaskOptionsButton extends StatelessWidget {
  final Task task;
  const _TaskOptionsButton({required this.task});

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    final List<Map<String, dynamic>> moveOptions = [];

    if (!task.completed && !task.inProgress) {
      moveOptions.add({
        'value': 'move_progress',
        'label': 'Mover para "Em progresso"',
        'icon': Icons.arrow_forward,
      });
    } else if (task.inProgress && !task.completed) {
      moveOptions.add({
        'value': 'move_pending',
        'label': 'Mover para "Pendente"',
        'icon': Icons.arrow_back,
      });
      moveOptions.add({
        'value': 'move_done',
        'label': 'Mover para "Concluído"',
        'icon': Icons.check,
      });
    } else if (task.completed) {
      moveOptions.add({
        'value': 'move_pending',
        'label': 'Mover para "Pendente"',
        'icon': Icons.restore,
      });
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: brand.textLight),
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
        } else if (value == 'move_pending') {
          context.read<TasksBloc>().add(
            MoveTask(task.id, inProgress: false, completed: false),
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
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: brand.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Excluir', style: TextStyle(color: brand.error)),
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
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: brand.textSecondary),
              const SizedBox(width: 12),
              const Text('Editar detalhes'),
            ],
          ),
        ),
        ...moveOptions.map(
          (option) => PopupMenuItem<String>(
            value: option['value'] as String,
            child: Row(
              children: [
                Icon(
                  option['icon'] as IconData,
                  size: 20,
                  color: brand.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(option['label'] as String),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'start',
          child: Row(
            children: [
              Icon(
                Icons.play_arrow_outlined,
                size: 20,
                color: brand.textSecondary,
              ),
              const SizedBox(width: 12),
              const Text('Iniciar foco'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: brand.error),
              const SizedBox(width: 12),
              Text('Excluir tarefa', style: TextStyle(color: brand.error)),
            ],
          ),
        ),
      ],
    );
  }
}
