import 'contact.dart';

abstract class ContactRepository {
  Stream<List<Contact>> search({String query = ''});

  Stream<Contact> getContactById(int id);

  Future<bool> delete(Contact contact);

  Future<bool> update(Contact contact);

  Future<bool> insert(Contact contact);

  Future<void> deleteAll();
}
