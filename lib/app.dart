import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:sqlite_bloc_rxdart/domain/contact_repository.dart';
import 'package:sqlite_bloc_rxdart/pages/home/home_bloc.dart';
import 'package:sqlite_bloc_rxdart/pages/home/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sqlite BLoC RxDart ',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        accentColor: Colors.redAccent,
      ),
      home: BlocProvider<HomeBloc>(
        child: const HomePage(),
        initBloc: () => HomeBloc(Provider.of<ContactRepository>(context)),
      ),
    );
  }
}
