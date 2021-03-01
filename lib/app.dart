import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';

import 'pages/home/home_bloc.dart';
import 'pages/home/home_page.dart';

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
        initBloc: (context) => HomeBloc(context.get()),
        child: const HomePage(),
      ),
    );
  }
}
