import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/core/db/app_database.dart';

import 'db_snapshot.dart';
import 'secretary_harness_seed.dart';

void main() {
  late SecretaryHarnessSeed seed;

  setUp(() async {
    seed = SecretaryHarnessSeed();
    await seed.setUp();
  });

  tearDown(() => seed.tearDown());

  test('snapshot de una tabla sin cambios da el mismo resultado', () async {
    final before = await snapshotTable(seed.db, 'inventarios');
    final after = await snapshotTable(seed.db, 'inventarios');
    expect(before.differsFrom(after), isFalse);
  });

  test('un UPDATE que no cambia el conteo de filas SÍ se detecta', () async {
    final before = await snapshotTable(seed.db, 'clientes');

    await (seed.db.update(
      seed.db.clientes,
    )..where((t) => t.id.equals(SecretaryHarnessSeed.clienteAlDiaId))).write(
      const ClientesCompanion(saldoDeudorActual: Value(999)),
    );

    final after = await snapshotTable(seed.db, 'clientes');
    expect(before.differsFrom(after), isTrue);
  });

  test('un INSERT nuevo cambia el conteo de filas', () async {
    final before = await snapshotTable(seed.db, 'clientes');

    await seed.db.into(seed.db.clientes).insert(
          ClientesCompanion.insert(
            id: 'harness-cli-nuevo',
            empresaId: SecretaryHarnessSeed.empresaId,
            nombre: 'Cliente Nuevo',
          ),
        );

    final after = await snapshotTable(seed.db, 'clientes');
    expect(before.rowCount + 1, after.rowCount);
    expect(before.differsFrom(after), isTrue);
  });

  test('diffSnapshots reporta solo las tablas que cambiaron', () async {
    final before = await snapshotTables(seed.db, ['clientes', 'productos']);

    await seed.db.into(seed.db.clientes).insert(
          ClientesCompanion.insert(
            id: 'harness-cli-nuevo-2',
            empresaId: SecretaryHarnessSeed.empresaId,
            nombre: 'Otro Cliente',
          ),
        );

    final after = await snapshotTables(seed.db, ['clientes', 'productos']);
    final changed = diffSnapshots(before, after);
    expect(changed, ['clientes']);
  });

  test('tabla fuera de la lista permitida lanza ArgumentError', () {
    expect(
      () => snapshotTable(seed.db, 'usuarios'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
