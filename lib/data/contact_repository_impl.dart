import '../domain/contact.dart';
import '../domain/contact_repository.dart';
import 'local/dao/contact_dao.dart';
import 'local/dao/contact_entity.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactDao _contactDao;

  const ContactRepositoryImpl(this._contactDao);

  @override
  Stream<List<Contact>> search({String query = ''}) {
    return _contactDao.search(query).map((entities) {
      return entities.map(_toContact).toList(growable: false);
    });
  }

  @override
  Stream<Contact> getContactById(int id) {
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
  return Contact(
    (b) => b
      ..id = entity.id
      ..name = entity.name
      ..phone = entity.phone
      ..address = entity.address
      ..gender = entity.male ? Gender.male : Gender.female
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt,
  );
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
