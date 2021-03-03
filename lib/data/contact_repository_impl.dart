import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';

import '../domain/contact.dart';
import '../domain/contact_repository.dart';
import 'local/dao/contact_dao.dart';
import 'local/dao/contact_entity.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactDao _contactDao;

  const ContactRepositoryImpl(this._contactDao);

  @override
  Stream<BuiltList<Contact>> search({required String by}) {
    return _contactDao.search(by).map(
        (entities) => entities.map(_toContact).whereNotNull().toBuiltList());
  }

  @override
  Stream<Contact?> getContactById(int id) =>
      _contactDao.findById(id).map(_toContact);

  @override
  Future<bool> delete(Contact contact) => _contactDao
      .deleteById(ArgumentError.checkNotNull(contact.id, 'Contact id'));

  @override
  Future<bool> insert(Contact contact) =>
      _contactDao.insert(_toEntity(contact));

  @override
  Future<bool> update(Contact contact) =>
      _contactDao.update(_toEntity(contact));

  @override
  Future<void> deleteAll() => _contactDao.deleteAll();
}

Contact? _toContact(ContactEntity? entity) {
  if (entity == null) {
    return null;
  }

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
