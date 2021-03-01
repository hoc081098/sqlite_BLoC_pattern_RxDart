// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const Gender _$male = const Gender._('male');
const Gender _$female = const Gender._('female');

Gender _$valueOf(String name) {
  switch (name) {
    case 'male':
      return _$male;
    case 'female':
      return _$female;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<Gender> _$values = new BuiltSet<Gender>(const <Gender>[
  _$male,
  _$female,
]);

class _$Contact extends Contact {
  @override
  final int id;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String address;
  @override
  final Gender gender;
  @override
  final DateTime updatedAt;
  @override
  final DateTime createdAt;

  factory _$Contact([void Function(ContactBuilder) updates]) =>
      (new ContactBuilder()..update(updates)).build();

  _$Contact._(
      {this.id,
      this.name,
      this.phone,
      this.address,
      this.gender,
      this.updatedAt,
      this.createdAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, 'Contact', 'name');
    BuiltValueNullFieldError.checkNotNull(phone, 'Contact', 'phone');
    BuiltValueNullFieldError.checkNotNull(address, 'Contact', 'address');
    BuiltValueNullFieldError.checkNotNull(gender, 'Contact', 'gender');
    BuiltValueNullFieldError.checkNotNull(updatedAt, 'Contact', 'updatedAt');
  }

  @override
  Contact rebuild(void Function(ContactBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContactBuilder toBuilder() => new ContactBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Contact &&
        id == other.id &&
        name == other.name &&
        phone == other.phone &&
        address == other.address &&
        gender == other.gender &&
        updatedAt == other.updatedAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc($jc(0, id.hashCode), name.hashCode),
                        phone.hashCode),
                    address.hashCode),
                gender.hashCode),
            updatedAt.hashCode),
        createdAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Contact')
          ..add('id', id)
          ..add('name', name)
          ..add('phone', phone)
          ..add('address', address)
          ..add('gender', gender)
          ..add('updatedAt', updatedAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ContactBuilder implements Builder<Contact, ContactBuilder> {
  _$Contact _$v;

  int _id;
  int get id => _$this._id;
  set id(int id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _phone;
  String get phone => _$this._phone;
  set phone(String phone) => _$this._phone = phone;

  String _address;
  String get address => _$this._address;
  set address(String address) => _$this._address = address;

  Gender _gender;
  Gender get gender => _$this._gender;
  set gender(Gender gender) => _$this._gender = gender;

  DateTime _updatedAt;
  DateTime get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime updatedAt) => _$this._updatedAt = updatedAt;

  DateTime _createdAt;
  DateTime get createdAt => _$this._createdAt;
  set createdAt(DateTime createdAt) => _$this._createdAt = createdAt;

  ContactBuilder();

  ContactBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _phone = $v.phone;
      _address = $v.address;
      _gender = $v.gender;
      _updatedAt = $v.updatedAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Contact other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Contact;
  }

  @override
  void update(void Function(ContactBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Contact build() {
    final _$result = _$v ??
        new _$Contact._(
            id: id,
            name:
                BuiltValueNullFieldError.checkNotNull(name, 'Contact', 'name'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, 'Contact', 'phone'),
            address: BuiltValueNullFieldError.checkNotNull(
                address, 'Contact', 'address'),
            gender: BuiltValueNullFieldError.checkNotNull(
                gender, 'Contact', 'gender'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, 'Contact', 'updatedAt'),
            createdAt: createdAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
