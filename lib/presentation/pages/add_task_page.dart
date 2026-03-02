import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';

class AddTaskPage extends StatefulWidget {
  final int initialDateOption;

  const AddTaskPage({
    super.key,
    this.initialDateOption = 0,
  });

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleCtrl = TextEditingController();
  final _stepCtrls = List.generate(3, (_) => TextEditingController());

  int _estimateMinutes = 30;
  TaskEnergy _energy = TaskEnergy.medium;

  late int _dateOption;
  DateTime? _selectedCustomDate;

  @override
  void initState() {
    super.initState();
    _dateOption = widget.initialDateOption;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (var ctrl in _stepCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o título da tarefa.')),
      );
      return;
    }

    final now = DateTime.now();
    DateTime? dueDate;

    if (_dateOption == 0) {
      dueDate = now;
    } else if (_dateOption == 1) {
      dueDate = now.add(const Duration(days: 1));
    } else {
      dueDate = _selectedCustomDate;
    }

    Navigator.pop(context, {
      'title': _titleCtrl.text.trim(),
      'steps': _stepCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'estimate': _estimateMinutes,
      'energy': _energy,
      'dueDate': dueDate,
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedCustomDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Brand.primary,
              onPrimary: Brand.textWhite,
              onSurface: Brand.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedCustomDate = picked;
        _dateOption = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    color: Brand.textSecondary,
                  ),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Criar nova tarefa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Brand.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dê um passo de cada vez.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Brand.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionLabel('O que você quer realizar?'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Ex: Estudar matemática',
                  hintStyle: TextStyle(color: Brand.textLight),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Brand.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Brand.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionLabel('Sub-tarefas (máximo 3)'),
                  Text(
                    'OPCIONAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Brand.primary.withValues(alpha: 0.8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _stepCtrls[index],
                    decoration: InputDecoration(
                      hintText: index == 0
                          ? 'Primeiro passo...'
                          : index == 1
                          ? 'Segundo passo...'
                          : 'Terceiro passo...',
                      hintStyle: TextStyle(color: Brand.textLight),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: Brand.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Brand.backgroundAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Brand.primary,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              _buildSectionLabel('Nível de energia necessário'),
              const SizedBox(height: 4),
              Text(
                'Quanto de esforço essa tarefa pede de você agora?',
                style: TextStyle(fontSize: 12, color: Brand.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SelectableButton(
                      label: 'Baixa',
                      isSelected: _energy == TaskEnergy.low,
                      onTap: () => setState(() => _energy = TaskEnergy.low),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Média',
                      isSelected: _energy == TaskEnergy.medium,
                      onTap: () => setState(() => _energy = TaskEnergy.medium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Alta',
                      isSelected: _energy == TaskEnergy.high,
                      onTap: () => setState(() => _energy = TaskEnergy.high),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionLabel('Quando realizar?'),
              const SizedBox(height: 4),
              Text(
                'Defina uma data para manter o foco.',
                style: TextStyle(fontSize: 12, color: Brand.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SelectableButton(
                      label: 'Hoje',
                      isSelected: _dateOption == 0,
                      onTap: () => setState(() => _dateOption = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Amanhã',
                      isSelected: _dateOption == 1,
                      onTap: () => setState(() => _dateOption = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Outra data',
                      icon: Icons.calendar_today_outlined,
                      isSelected: _dateOption == 2,
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),

              if (_dateOption == 2) ...[
                const SizedBox(height: 16),
                _buildSectionLabel('Selecione o dia'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Brand.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: Brand.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedCustomDate != null
                              ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_selectedCustomDate!)
                              : 'Selecione uma data',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Brand.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              _buildSectionLabel('Quanto tempo você estima?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SelectableButton(
                      label: '15m',
                      isSelected: _estimateMinutes == 15,
                      onTap: () => setState(() => _estimateMinutes = 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: '30m',
                      isSelected: _estimateMinutes == 30,
                      onTap: () => setState(() => _estimateMinutes = 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: '45m',
                      isSelected: _estimateMinutes == 45,
                      onTap: () => setState(() => _estimateMinutes = 45),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: '60m',
                      isSelected: _estimateMinutes == 60,
                      onTap: () => setState(() => _estimateMinutes = 60),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.primary,
                    foregroundColor: Brand.textWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Salvar tarefa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Brand.textSecondary,
                  ),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Brand.textMain,
      ),
    );
  }
}

class _SelectableButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _SelectableButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Brand.selectedBg : Brand.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Brand.primary : Brand.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Brand.primary : Brand.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Brand.primary : Brand.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
