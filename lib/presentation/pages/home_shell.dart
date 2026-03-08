import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/presentation/controllers/tasks_bloc.dart';
import 'focus_dashboard_page.dart';
import 'tasks_page.dart';
import 'focus_settings_page.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  List<Widget> get _pages => [
        FocusDashboardPage(onSeeAllTasks: () => setState(() => _index = 1)),
        const TasksPage(),
        FocusSettingsPage(onSaved: () => setState(() => _index = 0)),
      ];

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    return BlocProvider(
      create: (_) => sl<TasksBloc>()..add(LoadTasks()),
      child: BlocListener<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: ${state.error}'),
                backgroundColor: brand.error,
              ),
            );
          }
        },
        child: Scaffold(
          body: _pages[_index],
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: brand.primary.withValues(alpha: 0.15),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: brand.primary,
                  );
                }
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: brand.textSecondary,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: brand.primary);
                }
                return IconThemeData(color: brand.textSecondary);
              }),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: brand.surface,
              elevation: 2,
              shadowColor: brand.shadow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.center_focus_strong_outlined),
                  selectedIcon: Icon(Icons.center_focus_strong),
                  label: 'Foco',
                ),
                NavigationDestination(
                  icon: Icon(Icons.checklist_outlined),
                  selectedIcon: Icon(Icons.checklist),
                  label: 'Tarefas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
