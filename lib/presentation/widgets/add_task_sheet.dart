import 'package:flutter/material.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});
  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final titleCtrl = TextEditingController();
  final stepCtrls = List.generate(3, (_) => TextEditingController());
  int estimateMinutes = 15;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                const SizedBox(width: 8),
                const Text('Adicionar Nova Tarefa'),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Título da Tarefa'),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'Ex: Dobrar as roupas'),
            ),
            const SizedBox(height: 12),
            const Text('Lista de Itens (máx. 3)'),
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextField(
                  controller: stepCtrls[i],
                  decoration: InputDecoration(hintText: 'Passo ${i + 1}'),
                ),
              ),
            const SizedBox(height: 12),
            const Text('Tempo Estimado'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('5 MIN'), selected: estimateMinutes == 5, onSelected: (_) => setState(() => estimateMinutes = 5)),
                ChoiceChip(label: const Text('15 MIN'), selected: estimateMinutes == 15, onSelected: (_) => setState(() => estimateMinutes = 15)),
                ChoiceChip(label: const Text('30 MIN'), selected: estimateMinutes == 30, onSelected: (_) => setState(() => estimateMinutes = 30)),
                ChoiceChip(label: const Text('1 HORA'), selected: estimateMinutes == 60, onSelected: (_) => setState(() => estimateMinutes = 60)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'title': titleCtrl.text,
                  'steps': stepCtrls.map((c) => c.text).where((s) => s.isNotEmpty).toList(),
                  'estimate': estimateMinutes,
                });
              },
              child: const Text('Criar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}
