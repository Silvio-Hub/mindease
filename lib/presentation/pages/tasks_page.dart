import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';
import 'package:mindease/presentation/pages/add_task_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedDateFilterIndex = 0; // 0: Hoje, 1: Amanhã, 2: Outro dia

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
      // Filtro de data mockado por enquanto, já que a maioria das tarefas não tem data
      // Se tiver data, respeita. Se não, mostra em "Hoje" ou "Outro dia" dependendo da lógica desejada.
      // Para simplificar e atender o layout visual primeiro:
      // Vamos assumir que todas aparecem, mas o filtro é visual.
      // Ou melhor: se o usuário filtrar, tentamos filtrar.
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => sl<TasksBloc>()..add(LoadTasks()),
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quadro kanban',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerencie suas tarefas de forma calma e organizada.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Procurar tarefa...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _DateFilterChip(
                              label: 'Hoje',
                              isSelected: _selectedDateFilterIndex == 0,
                              onTap: () =>
                                  setState(() => _selectedDateFilterIndex = 0),
                            ),
                            const SizedBox(width: 8),
                            _DateFilterChip(
                              label: 'Amanhã',
                              isSelected: _selectedDateFilterIndex == 1,
                              onTap: () =>
                                  setState(() => _selectedDateFilterIndex = 1),
                            ),
                            const SizedBox(width: 8),
                            _DateFilterChip(
                              label: 'Outro dia',
                              isSelected: _selectedDateFilterIndex == 2,
                              icon: Icons.calendar_today,
                              onTap: () =>
                                  setState(() => _selectedDateFilterIndex = 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'PENDENTE'),
                          Tab(text: 'EM PROGRESSO'),
                          Tab(text: 'CONCLUÍDO'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: BlocBuilder<TasksBloc, TasksState>(
              builder: (ctx, state) {
                final filtered = _filterTasks(state.tasks);
                final todo = filtered
                    .where((t) => !t.inProgress && !t.done)
                    .toList();
                final doing = filtered
                    .where((t) => t.inProgress && !t.done)
                    .toList();
                final done = filtered.where((t) => t.done).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _TaskListView(
                      items: todo,
                      emptyMessage: 'Nenhuma tarefa pendente.',
                      emptyIcon: Icons.playlist_add,
                      statusColor: Colors.grey,
                    ),
                    _TaskListView(
                      items: doing,
                      emptyMessage: 'Nenhuma tarefa em progresso.',
                      emptyIcon: Icons.self_improvement,
                      statusColor: Colors.orange,
                    ),
                    _TaskListView(
                      items: done,
                      emptyMessage: 'Nenhuma tarefa concluída.',
                      emptyIcon: Icons.check_circle_outline,
                      statusColor: Colors.green,
                      isDone: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AddTaskPage()))
                  .then((result) {
                    if (result is Map) {
                      final id = DateTime.now().millisecondsSinceEpoch
                          .toString();
                      final title =
                          (result['title'] as String?) ?? 'Nova tarefa';
                      final steps =
                          (result['steps'] as List?)?.cast<String>() ??
                          const [];
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
                  });
            },
            label: const Text('Nova Tarefa'),
            icon: const Icon(Icons.add_rounded),
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
          ),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            Icon(emptyIcon, size: 64, color: Colors.grey.withOpacity(0.5)),
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
