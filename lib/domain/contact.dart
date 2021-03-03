import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'contact.g.dart';

abstract class Contact implements Built<Contact, ContactBuilder> {
  int? get id;

  String get name;

  String get phone;

  String get address;

  Gender get gender;

  DateTime get updatedAt;

  DateTime? get createdAt;

  Contact._();

  factory Contact([Function(ContactBuilder b) updates]) = _$Contact;
}

class Gender extends EnumClass {
  static const Gender male = _$male;
  static const Gender female = _$female;

  const Gender._(String name) : super(name);

  static BuiltSet<Gender> get values => _$values;

  static Gender valueOf(String name) => _$valueOf(name);
}
