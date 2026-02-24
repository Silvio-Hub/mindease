import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';
import 'package:mindease/presentation/pages/add_task_page.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TasksBloc>()..add(LoadTasks()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tarefas')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return SafeArea(
              child: BlocBuilder<TasksBloc, TasksState>(
              builder: (ctx, state) {
                final todo = state.tasks.where((t) => !t.inProgress && !t.done).toList();
                final doing = state.tasks.where((t) => t.inProgress && !t.done).toList();
                final done = state.tasks.where((t) => t.done).toList();

                if (isMobile) {
                    // Lista vertical por seção, cartões padronizados ocupando largura total
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      children: [
                        TaskSection(
                          header: 'Fazer',
                          items: todo,
                          buildCard: (t) => TaskCard(
                            title: t.title,
                            onPrimaryAction: () => ctx
                                .read<TasksBloc>()
                                .add(MoveTask(t.id, inProgress: true, done: false)),
                          ),
                        ),
                        TaskSection(
                          header: 'Em Progresso',
                          items: doing,
                          buildCard: (t) => TaskCard(
                            title: t.title,
                            primaryIcon: Icons.check,
                            onPrimaryAction: () => ctx
                                .read<TasksBloc>()
                                .add(MoveTask(t.id, inProgress: false, done: true)),
                          ),
                        ),
                        TaskSection(
                          header: 'Feito',
                          items: done,
                          buildCard: (t) => const TaskCard(title: 'Concluída', enabled: false),
                        ),
                      ],
                    );
                } else {
                  // Layout de colunas para telas largas, cada coluna rolável
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                            child: TaskSection(
                              header: 'Fazer',
                              items: todo,
                              buildCard: (t) => TaskCard(
                                title: t.title,
                                onPrimaryAction: () => ctx
                                    .read<TasksBloc>()
                                    .add(MoveTask(t.id, inProgress: true, done: false)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                            child: TaskSection(
                              header: 'Em Progresso',
                              items: doing,
                              buildCard: (t) => TaskCard(
                                title: t.title,
                                primaryIcon: Icons.check,
                                onPrimaryAction: () => ctx
                                    .read<TasksBloc>()
                                    .add(MoveTask(t.id, inProgress: false, done: true)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                            child: TaskSection(
                              header: 'Feito',
                              items: done,
                              buildCard: (t) => const TaskCard(title: 'Concluída', enabled: false),
                            ),
                          ),
                        ),
                      ],
                    );
                }
              },
              ),
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => const AddTaskPage()),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final bloc = ctx.read<TasksBloc>();
                if (result is Map) {
                  final id = DateTime.now().millisecondsSinceEpoch.toString();
                  final title = (result['title'] as String?) ?? 'Nova tarefa';
                  final steps = (result['steps'] as List?)?.cast<String>() ?? const [];
                  bloc.add(AddTask(Task(id: id, title: title, checklist: steps)));
                }
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class TaskSection extends StatelessWidget {
  final String header;
  final List<Task> items;
  final Widget Function(Task t) buildCard;
  const TaskSection({super.key, required this.header, required this.items, required this.buildCard});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(header),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Sem itens', style: Theme.of(context).textTheme.bodySmall),
          )
        else
          ...items.map(buildCard),
        const SizedBox(height: 12),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final bool enabled;
  final IconData primaryIcon;
  final VoidCallback? onPrimaryAction;

  const TaskCard({
    super.key,
    required this.title,
    this.enabled = true,
    this.primaryIcon = Icons.play_arrow,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(enabled ? Icons.check_box_outline_blank : Icons.check_box, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.bodyLarge),
        trailing: IconButton(
          icon: Icon(primaryIcon),
          onPressed: enabled ? onPrimaryAction : null,
        ),
      ),
    );
  }
}
