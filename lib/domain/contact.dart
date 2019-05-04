import 'package:built_value/built_value.dart';

part 'contact.g.dart';

abstract class Contact implements Built<Contact, ContactBuilder> {
  int get id;
  String get name;
  String get phone;
  String get address;
  bool get male;
  DateTime get updatedAt;
  DateTime get createdAt;

  Contact._();

  factory Contact([updates(ContactBuilder b)]) = _$Contact;
}
