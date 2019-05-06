import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';

abstract class ContactRepository {
  Observable<List<Contact>> search({String query: ''});

  Observable<Contact> getContactById(int id);

  Future<bool> delete(Contact contact);

  Future<bool> update(Contact contact);

  Future<bool> insert(Contact contact);

  Future<void> deleteAll();
}
