import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PomodoroStatus { initial, running, paused, finishedWork, finishedRest }

enum PomodoroPhase { foco, intervaloCurto, intervaloFinal }

class PomodoroHistoryItem {
  final DateTime date;
  final Duration duration;
  final String status;

  const PomodoroHistoryItem({
    required this.date,
    required this.duration,
    required this.status,
  });
}

class PomodoroState {
  final Duration remaining;
  final Duration totalDuration;
  final PomodoroPhase phase;
  final bool running;
  final PomodoroStatus status;
  final int cycle;
  final int totalCycles;
  final int maxCycles;
  final List<PomodoroHistoryItem> history;

  const PomodoroState({
    required this.remaining,
    required this.totalDuration,
    required this.phase,
    required this.running,
    required this.status,
    required this.cycle,
    required this.totalCycles,
    required this.maxCycles,
    this.history = const [],
  });

  bool get isWorkPhase => phase == PomodoroPhase.foco;
}

class PomodoroCubit extends Cubit<PomodoroState> {
  final int focusMinutes;
  late final Duration _focusDuration;
  late final Duration _shortBreakDuration;
  late final Duration _longBreakDuration;
  late final int _maxCycles;
  Timer? _timer;

  PomodoroCubit({required this.focusMinutes, bool startInRestMode = false})
    : super(
        PomodoroState(
          remaining: Duration(minutes: focusMinutes),
          totalDuration: Duration(minutes: focusMinutes),
          phase: PomodoroPhase.foco,
          running: false,
          status: PomodoroStatus.initial,
          cycle: 1,
          totalCycles: 1,
          maxCycles: 4,
          history: const [],
        ),
      ) {
    final config = _getConfig(focusMinutes);
    _focusDuration = Duration(minutes: config['focus'] as int);
    _shortBreakDuration = Duration(minutes: config['short'] as int);
    _longBreakDuration = Duration(minutes: config['long'] as int);
    _maxCycles = config['cycles'] as int;

    if (startInRestMode) {
      emit(
        PomodoroState(
          remaining: _shortBreakDuration,
          totalDuration: _shortBreakDuration,
          phase: PomodoroPhase.intervaloCurto,
          running: false,
          status: PomodoroStatus.initial,
          cycle: 1,
          totalCycles: 1,
          maxCycles: _maxCycles,
          history: const [],
        ),
      );
    } else {
      emit(
        PomodoroState(
          remaining: _focusDuration,
          totalDuration: _focusDuration,
          phase: PomodoroPhase.foco,
          running: false,
          status: PomodoroStatus.initial,
          cycle: 1,
          totalCycles: 1,
          maxCycles: _maxCycles,
          history: const [],
        ),
      );
    }
  }

  Map<String, dynamic> _getConfig(int minutes) {
    if (minutes == 15) {
      return {'focus': 5, 'short': 3, 'long': 7, 'cycles': 3};
    }
    if (minutes == 30) {
      return {'focus': 10, 'short': 5, 'long': 10, 'cycles': 3};
    }
    if (minutes == 45) {
      return {'focus': 15, 'short': 10, 'long': 15, 'cycles': 3};
    }
    if (minutes <= 30) {
      return {'focus': minutes, 'short': 5, 'long': 10, 'cycles': 4};
    }
    if (minutes <= 45) {
      return {'focus': minutes, 'short': 10, 'long': 20, 'cycles': 4};
    }
    return {'focus': minutes, 'short': 15, 'long': 30, 'cycles': 4};
  }

  void start() {
    _timer?.cancel();
    emit(
      PomodoroState(
        remaining: state.remaining,
        totalDuration: state.totalDuration,
        phase: state.phase,
        running: true,
        status: PomodoroStatus.running,
        cycle: state.cycle,
        totalCycles: state.totalCycles,
        maxCycles: state.maxCycles,
        history: state.history,
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final r = state.remaining - const Duration(seconds: 1);
      if (r < Duration.zero) {
        _handlePhaseTransition();
      } else {
        emit(
          PomodoroState(
            remaining: r,
            totalDuration: state.totalDuration,
            phase: state.phase,
            running: true,
            status: PomodoroStatus.running,
            cycle: state.cycle,
            totalCycles: state.totalCycles,
            maxCycles: state.maxCycles,
            history: state.history,
          ),
        );
      }
    });
  }

  void _handlePhaseTransition() {
    if (state.phase == PomodoroPhase.foco) {
      // End of Focus - Add to history
      final newHistory = List<PomodoroHistoryItem>.from(state.history)
        ..add(
          PomodoroHistoryItem(
            date: DateTime.now(),
            duration: _focusDuration,
            status: 'Concluído',
          ),
        );

      // Standard behavior for all durations including 15 min
      if (state.cycle < _maxCycles) {
        // Go to Short Break
        emit(
          PomodoroState(
            remaining: _shortBreakDuration,
            totalDuration: _shortBreakDuration,
            phase: PomodoroPhase.intervaloCurto,
            running: true,
            status: PomodoroStatus.finishedWork,
            cycle: state.cycle,
            totalCycles: state.totalCycles,
            maxCycles: state.maxCycles,
            history: newHistory,
          ),
        );
      } else {
        // Go to Long Break
        emit(
          PomodoroState(
            remaining: _longBreakDuration,
            totalDuration: _longBreakDuration,
            phase: PomodoroPhase.intervaloFinal,
            running: true,
            status: PomodoroStatus.finishedWork,
            cycle: state.cycle,
            totalCycles: state.totalCycles,
            maxCycles: state.maxCycles,
            history: newHistory,
          ),
        );
      }
    } else if (state.phase == PomodoroPhase.intervaloCurto) {
      // End of Short Break -> Next Focus
      emit(
        PomodoroState(
          remaining: _focusDuration,
          totalDuration: _focusDuration,
          phase: PomodoroPhase.foco,
          running: true,
          status: PomodoroStatus.finishedRest,
          cycle: state.cycle + 1,
          totalCycles: state.totalCycles + 1,
          maxCycles: state.maxCycles,
          history: state.history,
        ),
      );
    } else if (state.phase == PomodoroPhase.intervaloFinal) {
      // End of Long Break -> Reset to Cycle 1 Focus
      emit(
        PomodoroState(
          remaining: _focusDuration,
          totalDuration: _focusDuration,
          phase: PomodoroPhase.foco,
          running: true,
          status: PomodoroStatus.finishedRest,
          cycle: 1,
          totalCycles: state.totalCycles + 1,
          maxCycles: state.maxCycles,
          history: state.history,
        ),
      );
    }
  }

  void pause() {
    _timer?.cancel();
    emit(
      PomodoroState(
        remaining: state.remaining,
        totalDuration: state.totalDuration,
        phase: state.phase,
        running: false,
        status: PomodoroStatus.paused,
        cycle: state.cycle,
        totalCycles: state.totalCycles,
        maxCycles: state.maxCycles,
        history: state.history,
      ),
    );
  }

  void reset() {
    _timer?.cancel();
    emit(
      PomodoroState(
        remaining: state.totalDuration,
        totalDuration: state.totalDuration,
        phase: state.phase,
        running: false,
        status: PomodoroStatus.initial,
        cycle: state.cycle,
        totalCycles: state.totalCycles,
        maxCycles: state.maxCycles,
        history: state.history,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
