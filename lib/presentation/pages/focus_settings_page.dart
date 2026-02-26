import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/app/di/injector.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Painel de Controle')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ajuste o ambiente de acordo com o seu estado mental atual.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Nível de Energia Mental', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<EnergyLevel>(
              segments: const [
                ButtonSegment(value: EnergyLevel.baixa, label: Text('Baixa')),
                ButtonSegment(value: EnergyLevel.media, label: Text('Média')),
                ButtonSegment(value: EnergyLevel.alta, label: Text('Alta')),
              ],
              selected: {energy},
              onSelectionChanged: (s) => setState(() => energy = s.first),
            ),
            const SizedBox(height: 16),
            Text('Modo Foco', style: theme.textTheme.titleMedium),
            SwitchListTile(
              value: focusMode,
              onChanged: (v) => setState(() => focusMode = v),
              title: const Text(
                'Bloqueia distrações e silencia notificações não urgentes.',
              ),
            ),
            const SizedBox(height: 16),
            Text('Densidade de Informação', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<InfoDensity>(
              segments: const [
                ButtonSegment(
                  value: InfoDensity.simples,
                  label: Text('Simples'),
                ),
                ButtonSegment(
                  value: InfoDensity.equilibrada,
                  label: Text('Equilibrada'),
                ),
                ButtonSegment(
                  value: InfoDensity.detalhada,
                  label: Text('Detalhada'),
                ),
              ],
              selected: {density},
              onSelectionChanged: (s) => setState(() => density = s.first),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AccessibilityCubit>().setFocusMode(focusMode);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferências aplicadas')),
                );
              },
              child: const Text('Salvar e Aplicar Mudanças'),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                await sl<AuthRepository>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sair da Conta',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
