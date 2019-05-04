import 'package:flutter/material.dart';
import 'package:sqlite_bloc_rxdart/app.dart';
import 'package:sqlite_bloc_rxdart/data/app_database.dart';
import 'package:sqlite_bloc_rxdart/data/contact_repository_impl.dart';
import 'package:sqlite_bloc_rxdart/domain/contact_repository.dart';
import 'package:flutter_provider/flutter_provider.dart';

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
