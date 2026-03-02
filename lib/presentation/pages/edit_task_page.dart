import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';

class EditTaskPage extends StatefulWidget {
  final String initialTitle;

  const EditTaskPage({super.key, required this.initialTitle});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final TextEditingController _titleCtrl;
  final _stepCtrls = List.generate(3, (_) => TextEditingController());

  int _estimateMinutes = 45; // Default for edit mockup: 45m
  TaskEnergy _energy = TaskEnergy.high; // Default for edit mockup: Alta

  // 0: Hoje, 1: Amanhã, 2: Outra data
  int _dateOption = 2; // Default for edit mockup: Outra data
  DateTime? _selectedCustomDate = DateTime(2024, 10, 27); // Default: 27/10/2024

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);

    // Pre-fill mock data for steps
    _stepCtrls[0].text = "Revisar anotações da aula";
    _stepCtrls[1].text = "Criar slides";
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

    // Calcular data final baseada na opção
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
              onPrimary: Colors.white,
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
        _dateOption = 2; // Forçar seleção de "Outra data"
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
        ),
        title: Column(
          children: [
            const Text(
              'Editar tarefa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Brand.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ajuste o que for necessário.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title Input
              _buildSectionLabel('O que você quer realizar?'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Ex: Estudar matemática',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
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

              // Subtasks
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
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
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

              // Energy Level
              _buildSectionLabel('Nível de energia necessário'),
              const SizedBox(height: 4),
              Text(
                'Quanto de esforço essa tarefa pede de você agora?',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

              // When to realize
              _buildSectionLabel('Quando realizar?'),
              const SizedBox(height: 4),
              Text(
                'Defina uma data para manter o foco.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

              // Custom Date Picker Display
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
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: Colors.grey[600],
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

              // Estimated Time
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

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Brand.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Salvar alterações',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
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
          color: isSelected ? Brand.selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Brand.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Brand.primary : Colors.grey[600],
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Brand.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
