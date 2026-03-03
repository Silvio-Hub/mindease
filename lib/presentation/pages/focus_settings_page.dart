import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/entities/task.dart';
import 'package:mindease/domain/entities/user_preferences.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/presentation/pages/login_page.dart';

class FocusSettingsPage extends StatefulWidget {
  final VoidCallback? onSaved;

  const FocusSettingsPage({super.key, this.onSaved});

  @override
  State<FocusSettingsPage> createState() => _FocusSettingsPageState();
}

class _FocusSettingsPageState extends State<FocusSettingsPage> {
  TaskEnergy energy = TaskEnergy.medium;
  InfoDensity density = InfoDensity.equilibrada;
  bool focusMode = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AccessibilityCubit>().state;
    focusMode = state.focusMode;
    energy = state.energyLevel ?? TaskEnergy.medium;
    density = state.infoDensity ?? InfoDensity.equilibrada;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildEnergySection(),
              const SizedBox(height: 24),
              _buildFocusModeSection(),
              const SizedBox(height: 24),
              _buildDensitySection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Brand.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.settings, color: Brand.primary, size: 28),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Brand.textMain,
              ),
            ),
            Text(
              'Personalize sua experiência',
              style: TextStyle(fontSize: 14, color: Brand.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Brand.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Brand.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Brand.textMain.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEnergySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Nível de Energia Mental',
          Icons.battery_charging_full,
        ),
        const SizedBox(height: 16),
        _buildCard(
          child: Column(
            children: [
              const Text(
                'Como você está se sentindo agora?',
                style: TextStyle(color: Brand.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SelectableButton(
                      label: 'Baixa',
                      icon: Icons.battery_1_bar,
                      isSelected: energy == TaskEnergy.low,
                      onTap: () => setState(() => energy = TaskEnergy.low),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Média',
                      icon: Icons.battery_4_bar,
                      isSelected: energy == TaskEnergy.medium,
                      onTap: () => setState(() => energy = TaskEnergy.medium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Alta',
                      icon: Icons.battery_full,
                      isSelected: energy == TaskEnergy.high,
                      onTap: () => setState(() => energy = TaskEnergy.high),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFocusModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Modo Foco', Icons.do_not_disturb_on),
        const SizedBox(height: 16),
        _buildCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: focusMode,
            activeTrackColor: Brand.primary,
            thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Brand.textWhite;
              }
              return null;
            }),
            onChanged: (v) => setState(() => focusMode = v),
            title: const Text(
              'Bloquear distrações',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: const Text(
              'Silencia notificações não urgentes.',
              style: TextStyle(color: Brand.textSecondary, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDensitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Interface', Icons.view_quilt),
        const SizedBox(height: 16),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Densidade de Informação',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajuste a quantidade de detalhes exibidos na tela.',
                style: TextStyle(color: Brand.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SelectableButton(
                      label: 'Simples',
                      isSelected: density == InfoDensity.simples,
                      onTap: () =>
                          setState(() => density = InfoDensity.simples),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Padrão',
                      isSelected: density == InfoDensity.equilibrada,
                      onTap: () =>
                          setState(() => density = InfoDensity.equilibrada),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Detalhada',
                      isSelected: density == InfoDensity.detalhada,
                      onTap: () =>
                          setState(() => density = InfoDensity.detalhada),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.read<AccessibilityCubit>().updateSettings(
            focusMode: focusMode,
            energyLevel: energy,
            infoDensity: density,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferências salvas com sucesso!'),
              backgroundColor: Brand.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onSaved?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Brand.primary,
          foregroundColor: Brand.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Salvar Alterações',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sair da conta?'),
              content: const Text(
                'Você precisará fazer login novamente para acessar seus dados.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Brand.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Sair',
                    style: TextStyle(color: Brand.error),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await sl<AuthRepository>().logout();

            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout, color: Brand.error),
        label: const Text(
          'Sair da Conta',
          style: TextStyle(color: Brand.error, fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
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
