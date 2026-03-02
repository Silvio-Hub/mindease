import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';
import 'package:mindease/presentation/pages/add_task_page.dart';

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
  int _selectedDateFilterIndex = 0; // 0: Hoje, 1: Amanhã, 2: Outro dia
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

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _viewMode == TaskViewMode.kanban
        ? 'Quadro Kanban'
        : 'Lista de Tarefas';
    final subtitle = _viewMode == TaskViewMode.kanban
        ? 'Visualize o progresso das suas atividades.'
        : 'Sua lista organizada por prioridade.';

    return BlocProvider(
      create: (_) => sl<TasksBloc>()..add(LoadTasks()),
      child: Scaffold(
        backgroundColor: Brand.backgroundAlt,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Toggle View
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
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

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Procurar tarefa...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Brand.primary),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date Filters
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

              // Content
              Expanded(
                child: BlocBuilder<TasksBloc, TasksState>(
                  builder: (ctx, state) {
                    final filtered = _filterTasks(state.tasks);

                    if (_viewMode == TaskViewMode.kanban) {
                      return Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelColor: Brand.primary,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Brand.primary,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: Colors.transparent,
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
                                      .where((t) => !t.inProgress && !t.done)
                                      .toList(),
                                  emptyMessage: 'Nenhuma tarefa pendente.',
                                  emptyIcon: Icons.playlist_add,
                                  statusColor: Colors.grey,
                                ),
                                _TaskListView(
                                  items: filtered
                                      .where((t) => t.inProgress && !t.done)
                                      .toList(),
                                  emptyMessage: 'Nenhuma tarefa em progresso.',
                                  emptyIcon: Icons.self_improvement,
                                  statusColor: Colors.orange,
                                ),
                                _TaskListView(
                                  items: filtered.where((t) => t.done).toList(),
                                  emptyMessage: 'Nenhuma tarefa concluída.',
                                  emptyIcon: Icons.check_circle_outline,
                                  statusColor: Colors.green,
                                  isDone: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    // List View
                    final pendingTasks = filtered
                        .where((t) => !t.inProgress && !t.done)
                        .toList();
                    final inProgressTasks = filtered
                        .where((t) => t.inProgress && !t.done)
                        .toList();
                    final doneTasks = filtered.where((t) => t.done).toList();

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
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        if (inProgressTasks.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.self_improvement,
                                size: 20,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'EM PROGRESSO',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  letterSpacing: 1.2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...inProgressTasks.map(
                            (task) => _TaskCard(task: task),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (pendingTasks.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.history_toggle_off,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TAREFAS PENDENTES',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  letterSpacing: 1.2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...pendingTasks.map((task) => _TaskCard(task: task)),
                        ],

                        if (doneTasks.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 20,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CONCLUÍDAS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  letterSpacing: 1.2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...doneTasks.map((task) => _TaskCard(task: task)),
                        ],

                        // Info Banner
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Brand.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Brand.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Brand.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'As tarefas seguem a ordem de execução definida. Use os indicadores de energia para escolher a melhor tarefa.',
                                  style: TextStyle(
                                    color: Brand.primary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80), // Space for FAB
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
            final result = await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddTaskPage()));

            if (!context.mounted) return;

            if (result is Map) {
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final title = (result['title'] as String?) ?? 'Nova tarefa';
              final steps =
                  (result['steps'] as List?)?.cast<String>() ?? const [];
              final duration = result['estimate'] as int?;
              final energy = result['energy'] as TaskEnergy?;

              context.read<TasksBloc>().add(
                AddTask(
                  Task(
                    id: id,
                    title: title,
                    checklist: steps,
                    durationMinutes: duration,
                    energy: energy,
                  ),
                ),
              );
            }
          },
          label: const Text('Nova Tarefa'),
          icon: const Icon(Icons.add_rounded),
          backgroundColor: Brand.primary,
        ),
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
            color: isSelected ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

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
      default:
        energyColor = Colors.grey;
        energyBgColor = Colors.grey[100]!;
        energyLabel = 'Energia: -';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Toggle done status
            context.read<TasksBloc>().add(
              UpdateTask(task.copyWith(done: !task.done)),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.done ? Brand.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.done ? Brand.primary : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: task.done
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.done ? Colors.grey[400] : Brand.textMain,
                          decoration: task.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (task.durationMinutes != null) ...[
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.durationMinutes}m',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          if (task.energy != null)
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
                    ],
                  ),
                ),

                // Options
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.grey[400],
                  onPressed: () {
                    // Show options menu
                  },
                ),
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
          color: isSelected ? Brand.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Brand.primary : Colors.grey.shade200,
          ),
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
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey.shade600,
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

  const _TaskListView({
    required this.items,
    required this.emptyMessage,
    required this.emptyIcon,
    this.statusColor = Colors.grey,
    this.isDone = false,
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
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
        return TaskCard(task: task, statusColor: statusColor);
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final Color statusColor;

  const TaskCard({super.key, required this.task, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mocks visuais para adaptar ao design solicitado caso não tenha dados
    final duration = task.durationMinutes ?? 60;
    final energy = task.energy ?? TaskEnergy.medium;

    Color energyColor;
    String energyLabel;

    switch (energy) {
      case TaskEnergy.high:
        energyColor = Colors.red.shade100;
        energyLabel = 'Energia: Alta';
        break;
      case TaskEnergy.medium:
        energyColor = Colors.orange.shade100;
        energyLabel = 'Energia: Média';
        break;
      case TaskEnergy.low:
        energyColor = Colors.blue.shade100;
        energyLabel = 'Energia: Baixa';
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox customizado
            InkWell(
              onTap: () {
                final bloc = context.read<TasksBloc>();
                if (task.done) {
                  // Volta para inProgress (ou todo)
                  bloc.add(MoveTask(task.id, inProgress: true, done: false));
                } else if (task.inProgress) {
                  // Vai para done
                  bloc.add(MoveTask(task.id, inProgress: false, done: true));
                } else {
                  // Vai para inProgress
                  bloc.add(MoveTask(task.id, inProgress: true, done: false));
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: task.done
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: task.done
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
                child: task.done
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: task.done ? TextDecoration.lineThrough : null,
                      color: task.done ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${duration}m',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: energyColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          energyLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
              color: Colors.grey.shade400,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
