import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/data/contact_entity.dart';

abstract class ContactDao {
  Observable<List<ContactEntity>> search(String query);

  Observable<ContactEntity> findById(int id);

  Future<bool> deleteById(int id);

  Future<bool> insert(ContactEntity entity);

  Future<bool> update(ContactEntity entity);

  Future<void> deleteAll();
}
