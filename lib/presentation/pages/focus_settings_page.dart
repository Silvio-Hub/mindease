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
  AppThemeMode themeMode = AppThemeMode.system;

  @override
  void initState() {
    super.initState();
    final state = context.read<AccessibilityCubit>().state;
    focusMode = state.focusMode;
    energy = state.energyLevel ?? TaskEnergy.medium;
    density = state.infoDensity ?? InfoDensity.equilibrada;
    themeMode = state.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    return Scaffold(
      backgroundColor: brand.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(brand),
              const SizedBox(height: 32),
              _buildEnergySection(brand),
              const SizedBox(height: 24),
              _buildFocusModeSection(brand),
              const SizedBox(height: 24),
              _buildDensitySection(brand),
              const SizedBox(height: 24),
              _buildThemeSection(brand),
              const SizedBox(height: 32),
              _buildSaveButton(brand),
              const SizedBox(height: 32),
              _buildLogoutButton(brand),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BrandColors brand) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: brand.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.settings, color: brand.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: brand.textMain,
              ),
            ),
            Text(
              'Personalize sua experiência',
              style: TextStyle(fontSize: 14, color: brand.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BrandColors brand) {
    return Row(
      children: [
        Icon(icon, size: 20, color: brand.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: brand.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child, required BrandColors brand}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: brand.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEnergySection(BrandColors brand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Nível de Energia Mental',
          Icons.battery_charging_full,
          brand,
        ),
        const SizedBox(height: 16),
        _buildCard(
          brand: brand,
          child: Column(
            children: [
              Text(
                'Como você está se sentindo agora?',
                style: TextStyle(color: brand.textSecondary, fontSize: 14),
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
                      brand: brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Média',
                      icon: Icons.battery_4_bar,
                      isSelected: energy == TaskEnergy.medium,
                      onTap: () => setState(() => energy = TaskEnergy.medium),
                      brand: brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Alta',
                      icon: Icons.battery_full,
                      isSelected: energy == TaskEnergy.high,
                      onTap: () => setState(() => energy = TaskEnergy.high),
                      brand: brand,
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

  Widget _buildFocusModeSection(BrandColors brand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Modo Foco', Icons.do_not_disturb_on, brand),
        const SizedBox(height: 16),
        _buildCard(
          brand: brand,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: focusMode,
            activeTrackColor: brand.primary,
            thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return brand.textWhite;
              }
              return null;
            }),
            onChanged: (v) => setState(() => focusMode = v),
            title: const Text(
              'Bloquear distrações',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              'Silencia notificações não urgentes.',
              style: TextStyle(color: brand.textSecondary, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDensitySection(BrandColors brand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Interface', Icons.view_quilt, brand),
        const SizedBox(height: 16),
        _buildCard(
          brand: brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Densidade de Informação',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajuste a quantidade de detalhes exibidos na tela.',
                style: TextStyle(color: brand.textSecondary, fontSize: 13),
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
                      brand: brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Padrão',
                      isSelected: density == InfoDensity.equilibrada,
                      onTap: () =>
                          setState(() => density = InfoDensity.equilibrada),
                      brand: brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Detalhada',
                      isSelected: density == InfoDensity.detalhada,
                      onTap: () =>
                          setState(() => density = InfoDensity.detalhada),
                      brand: brand,
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

  Widget _buildThemeSection(BrandColors brand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Aparência', Icons.brightness_6, brand),
        const SizedBox(height: 16),
        _buildCard(
          brand: brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tema do Aplicativo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha o modo que melhor se adapta a você.',
                style: TextStyle(color: brand.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SelectableButton(
                      label: 'Auto',
                      icon: Icons.brightness_auto,
                      isSelected: themeMode == AppThemeMode.system,
                      onTap: () =>
                          setState(() => themeMode = AppThemeMode.system),
                      brand: brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Claro',
                      icon: Icons.brightness_5,
                      isSelected: themeMode == AppThemeMode.light,
                      onTap: () =>
                          setState(() => themeMode = AppThemeMode.light),
                      brand: brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SelectableButton(
                      label: 'Escuro',
                      icon: Icons.brightness_2,
                      isSelected: themeMode == AppThemeMode.dark,
                      onTap: () =>
                          setState(() => themeMode = AppThemeMode.dark),
                      brand: brand,
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

  Widget _buildSaveButton(BrandColors brand) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.read<AccessibilityCubit>().updateSettings(
            focusMode: focusMode,
            energyLevel: energy,
            infoDensity: density,
            themeMode: themeMode,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Preferências salvas com sucesso!'),
              backgroundColor: brand.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onSaved?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.primary,
          foregroundColor: brand.textWhite,
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

  Widget _buildLogoutButton(BrandColors brand) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: brand.surface,
              title: Text(
                'Sair da conta?',
                style: TextStyle(color: brand.textMain),
              ),
              content: Text(
                'Você precisará fazer login novamente para acessar seus dados.',
                style: TextStyle(color: brand.textMain),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: brand.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Sair',
                    style: TextStyle(color: brand.error),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await sl<AuthRepository>().signOut();

            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          }
        },
        icon: Icon(Icons.logout, color: brand.error),
        label: Text(
          'Sair da Conta',
          style: TextStyle(color: brand.error, fontWeight: FontWeight.w600),
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
  final BrandColors brand;

  const _SelectableButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
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
                color: isSelected ? brand.primary : brand.textMain,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
