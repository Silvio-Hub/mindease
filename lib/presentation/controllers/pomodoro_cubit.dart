import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PomodoroStatus { initial, running, paused, finishedWork, finishedRest }

class PomodoroState {
  final Duration remaining;
  final bool isWorkPhase;
  final bool running;
  final PomodoroStatus status;

  const PomodoroState({
    required this.remaining,
    required this.isWorkPhase,
    required this.running,
    required this.status,
  });
}

class PomodoroCubit extends Cubit<PomodoroState> {
  final Duration work;
  final Duration rest;
  Timer? _timer;

  PomodoroCubit({
    required this.work,
    required this.rest,
    bool startInRestMode = false,
  }) : super(
         PomodoroState(
           remaining: startInRestMode ? rest : work,
           isWorkPhase: !startInRestMode,
           running: false,
           status: PomodoroStatus.initial,
         ),
       );

  void start() {
    _timer?.cancel();
    emit(
      PomodoroState(
        remaining: state.remaining,
        isWorkPhase: state.isWorkPhase,
        running: true,
        status: PomodoroStatus.running,
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final r = state.remaining - const Duration(seconds: 1);
      if (r < Duration.zero) {
        if (state.isWorkPhase) {
          emit(
            PomodoroState(
              remaining: rest,
              isWorkPhase: false,
              running: true,
              status: PomodoroStatus.finishedWork,
            ),
          );
        } else {
          emit(
            PomodoroState(
              remaining: work,
              isWorkPhase: true,
              running: true,
              status: PomodoroStatus.finishedRest,
            ),
          );
        }
      } else {
        emit(
          PomodoroState(
            remaining: r,
            isWorkPhase: state.isWorkPhase,
            running: true,
            status: PomodoroStatus.running,
          ),
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    emit(
      PomodoroState(
        remaining: state.remaining,
        isWorkPhase: state.isWorkPhase,
        running: false,
        status: PomodoroStatus.paused,
      ),
    );
  }

  void reset() {
    _timer?.cancel();
    emit(
      PomodoroState(
        remaining: work,
        isWorkPhase: true,
        running: false,
        status: PomodoroStatus.initial,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
