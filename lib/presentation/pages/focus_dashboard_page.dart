import 'package:flutter/material.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/presentation/pages/edit_task_page.dart';
import 'package:mindease/presentation/pages/focus_session_page.dart';

class FocusDashboardPage extends StatefulWidget {
  final VoidCallback? onSeeAllTasks;

  const FocusDashboardPage({super.key, this.onSeeAllTasks});

  @override
  State<FocusDashboardPage> createState() => _FocusDashboardPageState();
}

class _FocusDashboardPageState extends State<FocusDashboardPage> {
  // Estado da tarefa em foco
  Task? currentFocusTask = const Task(
    id: 'focus-1',
    title: 'Preparar apresentação de vendas',
    durationMinutes: 45,
    energy: TaskEnergy.high,
  );

  // Lista de próximas tarefas
  List<Task> tasks = [
    const Task(
      id: '1',
      title: 'Revisar e-mails',
      durationMinutes: 15,
      energy: TaskEnergy.high,
    ),
    const Task(
      id: '2',
      title: 'Pausa para café',
      durationMinutes: 15,
      energy: TaskEnergy.low,
    ),
  ];

  void _promoteTaskToFocus(Task task) {
    setState(() {
      // Se já existe uma tarefa em foco, move ela de volta para o topo da lista
      if (currentFocusTask != null) {
        tasks.insert(0, currentFocusTask!);
      }

      // Remove a tarefa selecionada da lista
      tasks.removeWhere((t) => t.id == task.id);

      // Define a nova tarefa em foco
      currentFocusTask = task;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agora focando em: ${task.title}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEditFocusTask() async {
    if (currentFocusTask == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskPage(initialTitle: currentFocusTask!.title),
      ),
    );

    if (!mounted) return;

    if (result != null && result is Map) {
      setState(() {
        currentFocusTask = currentFocusTask!.copyWith(title: result['title']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa em foco atualizada!')),
      );
    }
  }

  void _onDeleteFocusTask() {
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
              setState(() {
                currentFocusTask = null;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarefa em foco excluída!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onAddNewFocusTask() {
    // Simplesmente cria uma nova tarefa genérica por enquanto
    // Idealmente abriria o AddTaskPage
    setState(() {
      currentFocusTask = const Task(
        id: 'new-focus',
        title: 'Nova Tarefa',
        durationMinutes: 30,
        energy: TaskEnergy.medium,
      );
    });
  }

  void _onEditTaskInList(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskPage(initialTitle: task.title)),
    );

    if (!mounted) return;

    if (result != null && result is Map) {
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = tasks[index].copyWith(title: result['title']);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
      );
    }
  }

  void _onDeleteTaskInList(Task task) {
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
              setState(() {
                tasks.removeWhere((t) => t.id == task.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarefa excluída com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onStartFocusSession() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FocusSessionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.background, // Light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const _Header(),
              const SizedBox(height: 24),

              // Focus Card - Adapted for Mobile
              _FocusCard(
                task: currentFocusTask,
                onEdit: _onEditFocusTask,
                onDelete: _onDeleteFocusTask,
                onStart: _onStartFocusSession,
                onAdd: _onAddNewFocusTask,
              ),
              const SizedBox(height: 32),

              // Next Tasks Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Próximas Tarefas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

              // Task List
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'Nenhuma tarefa pendente.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _TaskItem(
                      task: task,
                      onEdit: () => _onEditTaskInList(task),
                      onDelete: () => _onDeleteTaskInList(task),
                      // Ao clicar em iniciar foco na lista, promovemos para o card
                      onStartFocus: () => _promoteTaskToFocus(task),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Well-being Tip
              const _WellBeingTip(),
              const SizedBox(height: 80), // Bottom spacing for FAB or nav bar
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Olá, como você está hoje?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aqui está o seu foco para este momento.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _FocusCard extends StatelessWidget {
  final Task? task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStart;
  final VoidCallback onAdd;

  const _FocusCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStart,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Você não tem nenhuma tarefa em foco no momento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Brand.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Adicionar tarefa'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top purple area
          Container(
            color: Brand.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.adjust_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'EM FOCO AGORA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Content area
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
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'De acordo com o seu painel cognitivo, esta é a tarefa que mais merece sua atenção agora.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Brand.secondary,
                          foregroundColor: Colors.white,
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
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
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
                                  color: Colors.grey,
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
                                  color: Colors.red,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Excluir tarefa',
                                  style: TextStyle(color: Colors.red),
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

  const _TaskItem({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on energy
    final isHigh = task.energy == TaskEnergy.high;
    final energyColor = isHigh ? Brand.energyHighBg : Brand.energyLowBg;
    final energyTextColor = isHigh ? Brand.energyHighText : Brand.energyLowText;
    final energyLabel = isHigh ? 'Energia: Alta' : 'Energia: Baixa';
    final duration = '${task.durationMinutes ?? 0}m';

    return GestureDetector(
      onTap: onStartFocus,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Checkbox container
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
                            Icon(Icons.bolt, size: 14, color: energyTextColor),
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
              ),
            ),
            // Menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
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
                      Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
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
                        color: Colors.grey,
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
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Excluir tarefa',
                        style: TextStyle(color: Colors.red),
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
        color: Brand.tipBg, // Very light purple/grey
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
                    color: Colors.grey[600],
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
