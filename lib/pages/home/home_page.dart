import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';

import '../../domain/contact.dart';
import '../../utils.dart';
import '../detail/detail_bloc.dart';
import '../detail/detail_page.dart';
import '../edit_or_add/edit_or_add_bloc.dart';
import '../edit_or_add/edit_or_add_page.dart';
import 'home_bloc.dart';
import 'home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<HomeMessage>? _subscription;

  void _handleMessage(HomeMessage message) async {
    if (message is DeleteContactSuccess) {
      _scaffoldKey.snackBar('Delete contact successfully');
    }
    if (message is DeleteContactFailure) {
      _scaffoldKey.snackBar('Delete contact not successfully');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _subscription ??=
        BlocProvider.of<HomeBloc>(context).message$.listen(_handleMessage);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);
    final listPadding = MediaQuery.of(context).padding.copyWith(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          bottom: 56 + 16,
        );

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return BlocProvider<EditOrAddBloc>(
                  initBloc: (context) {
                    return EditOrAddBloc(
                      context.get(),
                      true,
                    );
                  },
                  child: EditOrAddPage(
                    addMode: true,
                  ),
                );
              },
            ),
          );
        },
        tooltip: 'Add new contact',
        child: Icon(Icons.add),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const HomeAppBar(),
          Expanded(
            child: RxStreamBuilder<HomeState>(
              stream: bloc.state$,
              builder: (context, state) {
                if (state!.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (state.error != null) {
                    return Center(
                      child: Text(
                        'Error occurred: ${state.error}',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    );
                  } else {
                    if (state.contacts.isEmpty) {
                      return Center(
                        child: Text(
                          'Empty list',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      );
                    }

                    return Container(
                      constraints: BoxConstraints.expand(),
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: state.contacts.length,
                          physics: const BouncingScrollPhysics(),
                          padding: listPadding,
                          itemBuilder: (BuildContext context, int index) {
                            final contact = state.contacts[index];

                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BlocProvider<DetailBloc>(
                                        initBloc: (context) {
                                          return DetailBloc(
                                            context.get(),
                                            contact,
                                          );
                                        },
                                        child: const DetailPage(),
                                      );
                                    },
                                  ),
                                );
                              },
                              title: Text(contact.name),
                              subtitle: Text(
                                '${contact.phone} - ${contact.address}',
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                              isThreeLine: false,
                              leading: CircleAvatar(
                                child: Text(
                                  contact.name[0],
                                ),
                                foregroundColor: Colors.white,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle),
                                onPressed: () =>
                                    _showDialogDeleteContact(bloc, contact),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDialogDeleteContact(HomeBloc bloc, Contact contact) async {
    final delete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete contact'),
          content: Text('Are you sure you want to delete this contact?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (delete ?? false) {
      bloc.delete(contact);
    }
  }
}

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with TickerProviderStateMixin {
  bool _isSearching = false;

  late AnimationController _controller;
  late Animation<double> _opacityTextField;
  late Animation<double> _opacityTitle;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityTextField = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _opacityTitle = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onIconPressed(HomeBloc bloc) {
    if (_isSearching) {
      setState(() => _isSearching = false);
      _controller.reverse();
      bloc.search('');
    } else {
      setState(() => _isSearching = true);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return Container(
      child: AppBar(
        leading: _isSearching
            ? ScaleTransition(
                child: IconButton(
                  tooltip: 'Close search',
                  icon: Icon(Icons.close),
                  onPressed: () => _onIconPressed(bloc),
                ),
                scale: _opacityTextField,
              )
            : ScaleTransition(
                scale: _opacityTitle,
                child: IconButton(
                  tooltip: 'Open search',
                  icon: Icon(Icons.search),
                  onPressed: () => _onIconPressed(bloc),
                ),
              ),
        title: _isSearching
            ? FadeTransition(
                opacity: _opacityTextField,
                child: TextField(
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  onChanged: bloc.search,
                  decoration: InputDecoration(
                    hintText: 'Search contact...',
                    border: InputBorder.none,
                  ),
                ),
              )
            : FadeTransition(
                opacity: _opacityTitle,
                child: Text('Home page'),
              ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Delete all',
            icon: Icon(Icons.delete),
            onPressed: () => _showDialogDeleteAll(bloc),
          )
        ],
      ),
    );
  }

  void _showDialogDeleteAll(HomeBloc bloc) async {
    final delete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete all contacts'),
          content: Text(
              'Are you sure you want to delete all contacts? This action cannot be undone'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (delete ?? false) {
      bloc.deleteAll();
    }
  }
}
