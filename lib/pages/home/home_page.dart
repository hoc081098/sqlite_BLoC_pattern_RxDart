import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';
import 'package:sqlite_bloc_rxdart/pages/home/home_bloc.dart';
import 'package:sqlite_bloc_rxdart/pages/home/home_state.dart';
import 'package:sqlite_bloc_rxdart/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<HomeMessage> _subscription;

  _handleMessage(HomeMessage message) async {
    if (message is DeleteContactSuccess) {
      showSnackBar(
        _scaffoldKey?.currentState,
        'Delete contact successfully',
      );
    }
    if (message is DeleteContactFailure) {
      showSnackBar(
        _scaffoldKey?.currentState,
        'Delete contact not successfully',
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
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

    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const HomeAppBar(),
          Expanded(
            child: StreamBuilder<HomeState>(
              stream: bloc.state$,
              initialData: bloc.state$.value,
              builder: (context, snapshot) {
                final state = snapshot.data;

                if (state.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (state.error != null) {
                    return Center(
                      child: Text(
                        'Error occurred: ${state.error}',
                      ),
                    );
                  } else {
                    return Container(
                      constraints: BoxConstraints.expand(),
                      child: ListView.builder(
                        itemCount: state.contacts.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          final contact = state.contacts[index];

                          return ListTile(
                            onTap: () {},
                            title: Text(contact.name),
                            subtitle: Text(
                              '${contact.phone} - ${contact.address}',
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                            ),
                            isThreeLine: true,
                            leading: CircleAvatar(
                              child: Text(
                                contact.name[0],
                              ),
                              foregroundColor: Colors.white,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.remove_circle),
                                  onPressed: () =>
                                      _showDialogDeleteContact(bloc, contact),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    //TODO: edit contact
                                  },
                                )
                              ],
                            ),
                          );
                        },
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
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
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
  const HomeAppBar({Key key}) : super(key: key);

  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with TickerProviderStateMixin {
  bool _isSearching = false;

  AnimationController _controller;
  Animation<double> _opacityTextField;
  Animation<double> _opacityTitle;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
