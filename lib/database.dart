import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()();
}

class Notas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  TextColumn get contenido => text()();
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
  IntColumn get categoriaId => integer().references(Categorias, #id)();
}

@DriftAccessor(tables: [Notas, Categorias])
class NotasDao extends DatabaseAccessor<AppDatabase> with _$NotasDaoMixin {
  NotasDao(super.db);

  // Notas de una categoría, ordenadas por fecha descendente
  Stream<List<Nota>> notasPorCategoria(int categoriaId) {
    return (select(notas)
          ..where((n) => n.categoriaId.equals(categoriaId))
          ..orderBy([(n) => OrderingTerm.desc(n.fecha)]))
        .watch();
  }

  Future<int> insertarNota(NotasCompanion nota) => into(notas).insert(nota);
  Future<int> insertarCategoria(CategoriasCompanion c) =>
      into(categorias).insert(c);
  Future<bool> actualizarNota(Nota nota) => update(notas).replace(nota);
  Future<int> eliminarNota(int id) =>
      (delete(notas)..where((n) => n.id.equals(id))).go();
}

@DriftDatabase(tables: [Notas, Categorias], daos: [NotasDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'notas_db'));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}