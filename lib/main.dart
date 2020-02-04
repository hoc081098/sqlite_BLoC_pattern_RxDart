import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';

import 'app.dart';
import 'data/contact_repository_impl.dart';
import 'data/local/app_database.dart';
import 'domain/contact_repository.dart';

void main() {
  final appDatabase = AppDatabase();
  final ContactRepository contactRepository = ContactRepositoryImpl(
    appDatabase.contactDao,
  );
  runApp(
    Provider<ContactRepository>(
      value: contactRepository,
      child: const MyApp(),
    ),
  );
}
