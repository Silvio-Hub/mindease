// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindease/domain/repositories/auth_repository.dart';
import 'package:mindease/main.dart';
import 'package:mindease/presentation/controllers/accessibility_cubit.dart';

class MockAccessibilityCubit extends MockCubit<AccessibilityState>
    implements AccessibilityCubit {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAccessibilityCubit mockAccessibilityCubit;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAccessibilityCubit = MockAccessibilityCubit();
    mockAuthRepository = MockAuthRepository();

    when(() => mockAccessibilityCubit.state).thenReturn(
      const AccessibilityState(
        focusMode: false,
        highContrast: false,
        fontScale: 1.0,
        spacingScale: 1.0,
        summaryMode: true,
        animationsEnabled: true,
      ),
    );
    when(() => mockAccessibilityCubit.init()).thenAnswer((_) async {});

    when(
      () => mockAuthRepository.getCurrentUser(),
    ).thenAnswer((_) async => null);

    GetIt.instance.registerSingleton<AccessibilityCubit>(
      mockAccessibilityCubit,
    );
    GetIt.instance.registerSingleton<AuthRepository>(mockAuthRepository);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MindEaseApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
