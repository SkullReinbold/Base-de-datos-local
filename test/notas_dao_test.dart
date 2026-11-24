import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notas_app/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('notasPorCategoria devuelve notas por fecha descendente', () async {
    final trabajo = await db.notasDao.insertarCategoria(
      CategoriasCompanion.insert(nombre: 'Trabajo', color: 0xFF2196F3),
    );
    final personal = await db.notasDao.insertarCategoria(
      CategoriasCompanion.insert(nombre: 'Personal', color: 0xFF4CAF50),
    );

    await db.notasDao.insertarNota(NotasCompanion.insert(
      titulo: 'Vieja', contenido: 'a', categoriaId: trabajo,
      fecha: Value(DateTime(2026, 1, 1)),
    ));
    await db.notasDao.insertarNota(NotasCompanion.insert(
      titulo: 'Reciente', contenido: 'b', categoriaId: trabajo,
      fecha: Value(DateTime(2026, 11, 1)),
    ));
    await db.notasDao.insertarNota(NotasCompanion.insert(
      titulo: 'Otra categoría', contenido: 'c', categoriaId: personal,
    ));

    final notas = await db.notasDao.notasPorCategoria(trabajo).first;

    expect(notas.length, 2);
    expect(notas.first.titulo, 'Reciente');
    expect(notas.last.titulo, 'Vieja');
  });
}