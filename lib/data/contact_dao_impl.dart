import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_bloc_rxdart/data/contact_dao.dart';
import 'package:sqlite_bloc_rxdart/data/contact_entry.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:sqlite_bloc_rxdart/data/contact_entity.dart';

class ContactDaoImpl implements ContactDao {
  final Future<BriteDatabase> _briteDatabaseFuture;

  const ContactDaoImpl(this._briteDatabaseFuture);

  @override
  Stream<List<ContactEntity>> search(String query) {
    return Stream.fromFuture(_briteDatabaseFuture).flatMap((db) {
      return db
          .createQuery(
            tableContacts,
            where:
                '$columnName LIKE ? OR $columnAddress LIKE ? OR $columnPhone LIKE ?',
            whereArgs: [
              '%$query%',
              '%$query%',
              '%$query%',
            ],
            orderBy: '$columnName ASC',
          )
          .mapToList((row) => ContactEntity.fromJson(row));
    });
  }

  @override
  Stream<ContactEntity> findById(int id) {
    return Stream.fromFuture(_briteDatabaseFuture).flatMap((db) {
      return db
          .createQuery(
            tableContacts,
            where: '$columnId = ?',
            whereArgs: [id],
            limit: 1,
          )
          .mapToOne((row) => ContactEntity.fromJson(row));
    });
  }

  @override
  Future<bool> deleteById(int id) async {
    final db = await _briteDatabaseFuture;
    final rows = await db.delete(
      tableContacts,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return rows > 0;
  }

  @override
  Future<bool> update(ContactEntity entity) async {
    final db = await _briteDatabaseFuture;
    final rows = await db.update(
      tableContacts,
      entity.toJson(),
      where: '$columnId = ?',
      whereArgs: [entity.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return rows > 0;
  }

  @override
  Future<bool> insert(ContactEntity entity) async {
    final db = await _briteDatabaseFuture;
    final id = await db.insert(
      tableContacts,
      entity.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id != -1;
  }

  @override
  Future<void> deleteAll() async {
    final db = await _briteDatabaseFuture;
    await db.delete(
      tableContacts,
      where: null,
    );
  }
}
