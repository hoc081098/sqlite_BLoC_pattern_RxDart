import 'package:built_collection/built_collection.dart';

import 'contact.dart';

abstract class ContactRepository {
  Stream<BuiltList<Contact>> search({required String by});

  Stream<Contact?> getContactById(int id);

  Future<bool> delete(Contact contact);

  Future<bool> update(Contact contact);

  Future<bool> insert(Contact contact);

  Future<void> deleteAll();
}
