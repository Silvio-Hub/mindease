import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindease/core/constants/brand.dart';
import 'package:mindease/presentation/controllers/pomodoro_cubit.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.backgroundFocus,
      appBar: AppBar(title: const Text('Foco')),
      body: SafeArea(
        child: Center(
          child: BlocProvider(
            create: (_) => PomodoroCubit(
              work: const Duration(minutes: 25),
              rest: const Duration(minutes: 5),
            ),
            child: BlocBuilder<PomodoroCubit, PomodoroState>(
              builder: (ctx, state) {
                final minutes = state.remaining.inMinutes
                    .remainder(60)
                    .toString()
                    .padLeft(2, '0');
                final seconds = state.remaining.inSeconds
                    .remainder(60)
                    .toString()
                    .padLeft(2, '0');
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '$minutes:$seconds',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => ctx.read<PomodoroCubit>().start(),
                          child: const Text('Iniciar'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => ctx.read<PomodoroCubit>().pause(),
                          child: const Text('Pausar'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => ctx.read<PomodoroCubit>().reset(),
                          child: const Text('Resetar'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Brand.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Brand.textWhite),
      ),
    );
  }
}
