import 'package:meta/meta.dart';

import 'contact_entry.dart';

class ContactEntity {
  final int id;
  final String name;
  final String phone;
  final String address;
  final bool male;
  final DateTime updatedAt;
  final DateTime createdAt;

  const ContactEntity({
    @required this.id,
    @required this.name,
    @required this.phone,
    @required this.address,
    @required this.male,
    @required this.updatedAt,
    @required this.createdAt,
  });

  factory ContactEntity.fromJson(Map<String, dynamic> json) {
    return ContactEntity(
      address: json[columnAddress],
      createdAt: DateTime.parse(json[columnCreatedAt]),
      id: json[columnId],
      male: json[columnMale] == 1,
      name: json[columnName],
      phone: json[columnPhone],
      updatedAt: DateTime.parse(json[columnUpdatedAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      columnId: id,
      columnAddress: address,
      columnName: name,
      columnPhone: phone,
      columnMale: male ? 1 : 0,
      columnUpdatedAt: updatedAt.toIso8601String(),
      columnCreatedAt: createdAt?.toIso8601String(),
    }..removeWhere((_, v) => v == null);
  }
}
