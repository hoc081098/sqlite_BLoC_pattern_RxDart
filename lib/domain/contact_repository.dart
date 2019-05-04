import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';

abstract class ContactRepository {
  Observable<List<Contact>> search({String query: ''});

  Observable<Contact> getContactById(int id);
}
