import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inventario_v2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    bool timerDone = false;
    final timer = Timer(timeout, () => timerDone = true);
    while (tester.any(finder) == false) {
      if (timerDone) {
        throw Exception('Timeout waiting for $finder');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    timer.cancel();
  }

  Future<Finder> pumpUntilAnyFound(
    WidgetTester tester,
    List<Finder> finders, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    bool timerDone = false;
    final timer = Timer(timeout, () => timerDone = true);
    while (true) {
      for (final finder in finders) {
        if (tester.any(finder)) {
          timer.cancel();
          return finder;
        }
      }
      if (timerDone) {
        throw Exception('Timeout waiting for one of $finders');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<Finder> pumpUntilIndexedField(
    WidgetTester tester,
    int index, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final fieldsFinder = find.byType(TextFormField);
    await pumpUntilFound(tester, fieldsFinder, timeout: timeout);
    expect(fieldsFinder, findsAtLeastNWidgets(index + 1));
    return fieldsFinder.at(index);
  }

  testWidgets('Test Opening Cash Register', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 1. Perform Login only when the app does not already have a session.
    final fieldsFinder = find.byType(TextFormField);
    final initialState = await pumpUntilAnyFound(tester, [
      fieldsFinder,
      find.text('Abrir caja'),
      find.text('Cerrar caja'),
    ]);

    if (initialState == fieldsFinder) {
      final emailFieldFinder = await pumpUntilIndexedField(tester, 0);
      final passwordFieldFinder = await pumpUntilIndexedField(tester, 1);
      final loginButtonFinder = find.byType(ElevatedButton);

      await tester.enterText(emailFieldFinder, 'cpespinoza044@gmail.com');
      await tester.pump();
      await tester.enterText(passwordFieldFinder, 'Car20Esp20');
      await tester.pump();
      await tester.tap(loginButtonFinder);

      // Wait for navigation to dashboard.
      await tester.pumpAndSettle(const Duration(seconds: 10));
    }

    // 2. Navigate to Cash Register
    final cashButton = await pumpUntilAnyFound(tester, [
      find.text('Abrir caja'),
      find.text('Cerrar caja'),
    ]);
    await tester.tap(cashButton);
    await tester.pumpAndSettle();

    // 3. Open cash register when it is closed, or accept an already-open state.
    final abrirAhora = find.text('ABRIR CAJA AHORA');
    final openRegisterMarker = find.text('REALIZAR CORTE');
    await pumpUntilAnyFound(tester, [abrirAhora, openRegisterMarker]);
    if (tester.any(abrirAhora)) {
      await tester.tap(abrirAhora);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // 4. Verify the monitor is open.
    await pumpUntilFound(tester, openRegisterMarker);
    expect(openRegisterMarker, findsOneWidget);
  });
}
