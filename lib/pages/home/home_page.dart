import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:sqlite_bloc_rxdart/pages/home/home_bloc.dart';
import 'package:sqlite_bloc_rxdart/pages/home/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return Scaffold(
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
                                  onPressed: () {
                                    //TODO: delete contact
                                  },
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
}

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({Key key}) : super(key: key);

  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with TickerProviderStateMixin {
  bool _isSearching = false;

  AnimationController _controller;
  Animation<double> _opacity;
  Animation<double> _opacityRev;
  AnimationController _controllerRev;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controllerRev = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _opacityRev = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controllerRev,
        curve: Curves.easeOut,
      ),
    );

    _controller.reverse();
    _controllerRev.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerRev.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<HomeBloc>(context);

    return Container(
      child: AppBar(
        title: FadeTransition(
          opacity: _opacity,
          child: _isSearching
              ? TextField(
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  onChanged: bloc.search,
                  decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        tooltip: 'Close search',
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() => _isSearching = false);

                          _controller
                            ..reset()
                            ..reverse();
                          _controllerRev
                            ..reset()
                            ..forward();
                          bloc.search('');
                        },
                      ),
                    ),
                    hintText: 'Search contact...',
                    border: UnderlineInputBorder(),
                  ),
                )
              : FadeTransition(
                  opacity: _opacityRev,
                  child: Text('Home page'),
                ),
        ),
        actions: <Widget>[
          if (!_isSearching)
            IconButton(
              tooltip: 'Open search',
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() => _isSearching = true);

                _controller
                  ..reset()
                  ..forward();
                _controllerRev
                  ..reset()
                  ..reverse();
              },
            ),
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
