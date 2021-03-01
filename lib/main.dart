import 'package:built_value/built_value.dart';
import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';

import 'app.dart';
import 'data/contact_repository_impl.dart';
import 'data/local/app_database.dart';
import 'domain/contact_repository.dart';
import 'utils.dart';

void main() {
  // Function used by generated code to get a `BuiltValueToStringHelper`.
  newBuiltValueToStringHelper = (className) => kReleaseMode
      ? const EmptyBuiltValueToStringHelper()
      : CustomIndentingBuiltValueToStringHelper(className, true);

  // Logger that logs disposed resources.
  DisposeBagConfigs.logger = kReleaseMode ? null : disposeBagDefaultLogger;

  WidgetsFlutterBinding.ensureInitialized();

  final appDatabase = AppDatabase();
  final ContactRepository contactRepository = ContactRepositoryImpl(
    appDatabase.contactDao,
  );
  runApp(
    Provider<ContactRepository>.value(
      contactRepository,
      child: const MyApp(),
    ),
  );
}
