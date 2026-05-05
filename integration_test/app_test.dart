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
        throw Exception('Timeout waiting for ${finder.description}');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    timer.cancel();
  }

  testWidgets('Test Opening Cash Register', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 1. Perform Login
    final emailFieldFinder = find.byType(TextFormField).at(0);
    await pumpUntilFound(tester, emailFieldFinder);

    final passwordFieldFinder = find.byType(TextFormField).at(1);
    final loginButtonFinder = find.byType(ElevatedButton);

    await tester.enterText(emailFieldFinder, 'cpespinoza044@gmail.com');
    await tester.pump();
    await tester.enterText(passwordFieldFinder, 'Car20Esp20');
    await tester.pump();
    await tester.tap(loginButtonFinder);
    
    // Wait for navigation to dashboard
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // 2. Navigate to Cash Register
    final openBoxButton = find.text('Abrir caja');
    await pumpUntilFound(tester, openBoxButton);
    await tester.tap(openBoxButton);
    await tester.pumpAndSettle();

    // 3. Click "ABRIR CAJA AHORA"
    final abrirAhora = find.text('ABRIR CAJA AHORA');
    await pumpUntilFound(tester, abrirAhora);
    await tester.tap(abrirAhora);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 4. Verify success
    expect(find.text('Turno abierto correctamente'), findsOneWidget);
  });
}
