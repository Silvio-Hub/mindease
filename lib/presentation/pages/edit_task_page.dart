import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final TextEditingController _titleCtrl;
  final _stepCtrls = List.generate(3, (_) => TextEditingController());

  late FocusDuration _focusDuration;
  late TaskEnergy _energy;

  late int _dateOption;
  DateTime? _selectedCustomDate;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t.title);

    // Inicializa checklist (até 3 itens)
    for (int i = 0; i < 3; i++) {
      if (i < t.subtasks.length) {
        _stepCtrls[i].text = t.subtasks[i];
      }
    }

    _focusDuration = t.focusDuration;
    _energy = t.energy;

    // Lógica de data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final d = DateTime(
      t.scheduledFor.year,
      t.scheduledFor.month,
      t.scheduledFor.day,
    );
    if (d == today) {
      _dateOption = 0;
      _selectedCustomDate = t.scheduledFor;
    } else if (d == tomorrow) {
      _dateOption = 1;
      _selectedCustomDate = t.scheduledFor;
    } else {
      _dateOption = 2;
      _selectedCustomDate = t.scheduledFor;
    }
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
      'subtasks': _stepCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'focusDuration': _focusDuration,
      'energy': _energy,
      'scheduledFor': dueDate,
    });
  }

  Future<void> _pickDate() async {
    final brand = Brand.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedCustomDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: brand.primary,
              onPrimary: brand.textWhite,
              onSurface: brand.textMain,
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
    final brand = Brand.of(context);
    return Scaffold(
      backgroundColor: brand.surface,
      appBar: AppBar(
        backgroundColor: brand.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: brand.textMain),
        ),
        title: Text(
          'Editar Tarefa',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: brand.textMain,
          ),
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

              _buildSectionLabel('O que você quer realizar?'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Ex: Estudar matemática',
                  hintStyle: TextStyle(color: brand.textLight),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: brand.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: brand.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: brand.surface,
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
                      color: brand.primary.withValues(alpha: 0.8),
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
                      hintStyle: TextStyle(color: brand.textLight),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: brand.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: brand.backgroundAlt,
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
                        borderSide: BorderSide(color: brand.primary, width: 1),
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
                style: TextStyle(fontSize: 12, color: brand.textSecondary),
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
                style: TextStyle(fontSize: 12, color: brand.textSecondary),
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
                      border: Border.all(color: brand.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: brand.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedCustomDate != null
                              ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_selectedCustomDate!)
                              : 'Selecione uma data',
                          style: TextStyle(fontSize: 14, color: brand.textMain),
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
                      isSelected: _focusDuration == FocusDuration.short,
                      onTap: () =>
                          setState(() => _focusDuration = FocusDuration.short),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: '30m',
                      isSelected: _focusDuration == FocusDuration.medium,
                      onTap: () =>
                          setState(() => _focusDuration = FocusDuration.medium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: '45m',
                      isSelected: _focusDuration == FocusDuration.long,
                      onTap: () =>
                          setState(() => _focusDuration = FocusDuration.long),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: '60m',
                      isSelected: _focusDuration == FocusDuration.extraLong,
                      onTap: () => setState(
                        () => _focusDuration = FocusDuration.extraLong,
                      ),
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
                    backgroundColor: brand.primary,
                    foregroundColor: brand.textWhite,
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
                    foregroundColor: brand.textSecondary,
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
    final brand = Brand.of(context);
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: brand.textMain,
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
    final brand = Brand.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? brand.selectedBg : brand.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? brand.primary : brand.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? brand.primary : brand.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? brand.primary : brand.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
