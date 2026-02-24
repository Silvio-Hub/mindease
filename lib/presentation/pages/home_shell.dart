import 'package:flutter/material.dart';
import 'focus_dashboard_page.dart';
import 'tasks_page.dart';
import 'progress_page.dart';
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

  final _pages = const [
    FocusDashboardPage(),
    TasksPage(),
    ProgressPage(),
    FocusSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.center_focus_strong), label: 'Foco'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tarefas'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Dados'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
