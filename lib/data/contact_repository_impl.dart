import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/data/contact_dao.dart';
import 'package:sqlite_bloc_rxdart/data/contact_entity.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';
import 'package:sqlite_bloc_rxdart/domain/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactDao _contactDao;

  const ContactRepositoryImpl(this._contactDao);

  @override
  Observable<List<Contact>> search({String query = ''}) {
    return _contactDao.search(query).map((entites) {
      return entites.map(_toContact).toList(growable: false);
    });
  }

  @override
  Observable<Contact> getContactById(int id) {
    return _contactDao.findById(id).map(_toContact);
  }

  @override
  Future<bool> delete(Contact contact) {
    return _contactDao.deleteById(contact.id);
  }

  @override
  Future<bool> insert(Contact contact) {
    return _contactDao.insert(_toEntity(contact));
  }

  @override
  Future<bool> update(Contact contact) {
    return _contactDao.update(_toEntity(contact));
  }

  @override
  Future<void> deleteAll() {
    return _contactDao.deleteAll();
  }
}

Contact _toContact(ContactEntity entity) {
  return Contact((b) => b
    ..id = entity.id
    ..name = entity.name
    ..phone = entity.phone
    ..address = entity.address
    ..gender = entity.male ? Gender.male : Gender.female
    ..createdAt = entity.createdAt
    ..updatedAt = entity.updatedAt);
}

ContactEntity _toEntity(Contact contact) {
  return ContactEntity(
    address: contact.address,
    createdAt: contact.createdAt,
    id: contact.id,
    male: contact.gender == Gender.male,
    name: contact.name,
    phone: contact.phone,
    updatedAt: contact.updatedAt,
  );
}
