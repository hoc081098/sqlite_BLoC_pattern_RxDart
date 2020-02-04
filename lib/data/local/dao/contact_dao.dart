import 'contact_entity.dart';

abstract class ContactDao {
  Stream<List<ContactEntity>> search(String query);

  Stream<ContactEntity> findById(int id);

  Future<bool> deleteById(int id);

  Future<bool> insert(ContactEntity entity);

  Future<bool> update(ContactEntity entity);

  Future<void> deleteAll();
}
