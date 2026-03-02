import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';
import 'package:mindease/presentation/pages/login_page.dart';

enum EnergyLevel { baixa, media, alta }

enum InfoDensity { simples, equilibrada, detalhada }

class FocusSettingsPage extends StatefulWidget {
  const FocusSettingsPage({super.key});
  @override
  State<FocusSettingsPage> createState() => _FocusSettingsPageState();
}

class _FocusSettingsPageState extends State<FocusSettingsPage> {
  EnergyLevel energy = EnergyLevel.media;
  InfoDensity density = InfoDensity.equilibrada;
  bool focusMode = false;

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
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              SegmentedButton<EnergyLevel>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Brand.primary.withValues(alpha: 0.2);
                    }
                    return null;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Brand.primary;
                    }
                    return Colors.grey[700];
                  }),
                ),
                segments: const [
                  ButtonSegment(
                    value: EnergyLevel.baixa,
                    label: Text('Baixa'),
                    icon: Icon(Icons.battery_1_bar),
                  ),
                  ButtonSegment(
                    value: EnergyLevel.media,
                    label: Text('Média'),
                    icon: Icon(Icons.battery_4_bar),
                  ),
                  ButtonSegment(
                    value: EnergyLevel.alta,
                    label: Text('Alta'),
                    icon: Icon(Icons.battery_full),
                  ),
                ],
                selected: {energy},
                onSelectionChanged: (s) => setState(() => energy = s.first),
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
                return Colors.white;
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
              style: TextStyle(color: Colors.grey, fontSize: 13),
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
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SegmentedButton<InfoDensity>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Brand.primary.withValues(alpha: 0.2);
                    }
                    return null;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Brand.primary;
                    }
                    return Colors.grey[700];
                  }),
                ),
                segments: const [
                  ButtonSegment(
                    value: InfoDensity.simples,
                    label: Text('Simples'),
                  ),
                  ButtonSegment(
                    value: InfoDensity.equilibrada,
                    label: Text('Padrão'),
                  ),
                  ButtonSegment(
                    value: InfoDensity.detalhada,
                    label: Text('Detalhada'),
                  ),
                ],
                selected: {density},
                onSelectionChanged: (s) => setState(() => density = s.first),
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
          context.read<AccessibilityCubit>().setFocusMode(focusMode);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferências salvas com sucesso!'),
              backgroundColor: Brand.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Brand.primary,
          foregroundColor: Colors.white,
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
          // Mostrar diálogo de confirmação
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
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
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
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Sair da Conta',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
