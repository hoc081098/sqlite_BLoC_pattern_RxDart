import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlbrite/sqlbrite.dart';

import 'dao/contact_dao.dart';
import 'dao/contact_dao_impl.dart';
import 'dao/contact_entity.dart';
import 'dao/contact_entry.dart';

const dbName = 'flutter_sqlite_bloc_rxdart.db';

class AppDatabase {
  final ContactDao contactDao;

  AppDatabase._(this.contactDao);

  factory AppDatabase() {
    final _dbFuture = _open().then((db) => BriteDatabase(db));
    return AppDatabase._(ContactDaoImpl(_dbFuture));
  }

  static Future<Database> _open() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $tableContacts( 
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
          $columnName TEXT NOT NULL,
          $columnPhone TEXT NOT NULL,
          $columnAddress TEXT NOT NULL,
          $columnMale INTEGER NOT NULL DEFAULT 0,
          $columnCreatedAt TEXT NOT NULL,
          $columnUpdatedAt TEXT NOT NULL
        )''');

        final batch = db.batch();
        for (var i = 0; i < 200; i++) {
          batch.insert(
            tableContacts,
            ContactEntity(
              address: 'Address $i',
              createdAt: DateTime.now(),
              id: null,
              male: i % 2 == 0,
              name: 'Name $i',
              phone: 'Phone $i',
              updatedAt: DateTime.now(),
            ).toJson(),
          );
        }
        await batch.commit(
          continueOnError: true,
          noResult: true,
        );
      },
    );
  }
}
