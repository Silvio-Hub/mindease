import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class PomodoroState {
  final Duration remaining;
  final bool isWorkPhase;
  final bool running;
  const PomodoroState({
    required this.remaining,
    required this.isWorkPhase,
    required this.running,
  });
}

class PomodoroCubit extends Cubit<PomodoroState> {
  final Duration work;
  final Duration rest;
  Timer? _timer;

  PomodoroCubit({required this.work, required this.rest})
      : super(PomodoroState(remaining: work, isWorkPhase: true, running: false));

  void start() {
    _timer?.cancel();
    emit(PomodoroState(remaining: state.remaining, isWorkPhase: state.isWorkPhase, running: true));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final r = state.remaining - const Duration(seconds: 1);
      if (r <= Duration.zero) {
        if (state.isWorkPhase) {
          // [A11Y-Cog] Transição previsível entre fases, sem animações
          emit(PomodoroState(remaining: rest, isWorkPhase: false, running: true));
        } else {
          emit(PomodoroState(remaining: work, isWorkPhase: true, running: true));
        }
      } else {
        emit(PomodoroState(remaining: r, isWorkPhase: state.isWorkPhase, running: true));
      }
    });
  }

  void pause() {
    _timer?.cancel();
    emit(PomodoroState(remaining: state.remaining, isWorkPhase: state.isWorkPhase, running: false));
  }

  void reset() {
    _timer?.cancel();
    emit(PomodoroState(remaining: work, isWorkPhase: true, running: false));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
