import 'package:flutter/material.dart';
import 'package:mindease/core/constants/brand.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});
  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleCtrl = TextEditingController();
  final stepCtrls = List.generate(3, (_) => TextEditingController());
  int estimateMinutes = 15;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Nova Tarefa'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFF9FAFF)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Título da Tarefa', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Ex: Dobrar as roupas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lista de Itens (máx. 3)',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                'Divida em até 3 passos simples para manter o foco',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < 3; i++)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: false,
                      onChanged: null,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    title: TextField(
                      controller: stepCtrls[i],
                      decoration: InputDecoration(
                        hintText: 'Passo ${i + 1}',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Text('Tempo Estimado', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _EstimateChip(
                    label: '5 MIN',
                    selected: estimateMinutes == 5,
                    onSelected: () => setState(() => estimateMinutes = 5),
                  ),
                  _EstimateChip(
                    label: '15 MIN',
                    selected: estimateMinutes == 15,
                    onSelected: () => setState(() => estimateMinutes = 15),
                  ),
                  _EstimateChip(
                    label: '30 MIN',
                    selected: estimateMinutes == 30,
                    onSelected: () => setState(() => estimateMinutes = 30),
                  ),
                  _EstimateChip(
                    label: '1 HORA',
                    selected: estimateMinutes == 60,
                    onSelected: () => setState(() => estimateMinutes = 60),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.success,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      'title': titleCtrl.text,
                      'steps': stepCtrls
                          .map((c) => c.text)
                          .where((s) => s.isNotEmpty)
                          .toList(),
                      'estimate': estimateMinutes,
                    });
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Criar Tarefa'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'MindEase Focus • Um passo de cada vez.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstimateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  const _EstimateChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedColor: Brand.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: selected ? Brand.primary : null),
    );
  }
}
