import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/data/contact_dao.dart';
import 'package:sqlite_bloc_rxdart/data/contact_entry.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';

import 'contact_entity.dart';

class ContactDaoImpl implements ContactDao {
  final Future<BriteDatabase> _briteDatabaseFuture;

  const ContactDaoImpl(this._briteDatabaseFuture);

  @override
  Observable<List<ContactEntity>> search(String query) {
    return Observable.fromFuture(_briteDatabaseFuture).flatMap((db) {
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
  Observable<ContactEntity> findById(int id) {
    return Observable.fromFuture(_briteDatabaseFuture).flatMap((db) {
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
}
