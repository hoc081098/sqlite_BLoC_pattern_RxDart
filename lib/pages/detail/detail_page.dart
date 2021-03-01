import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/contact.dart';
import '../edit_or_add/edit_or_add_bloc.dart';
import '../edit_or_add/edit_or_add_page.dart';
import 'detail_bloc.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _dateFormat = DateFormat.yMd().add_Hms();
  final scrollController = ScrollController();
  double _scale;
  double _top;

  void calculateScaleAndTop() {
    final defaultTopMargin = 256.0 - 23.0;
    final startScale = 96.0;
    final endScale = startScale / 2;

    _top = defaultTopMargin;
    _scale = 1.0;

    if (scrollController.hasClients) {
      final offset = scrollController.offset;
      _top -= offset;
      if (offset < defaultTopMargin - startScale) {
        _scale = 1.0;
      } else if (offset < defaultTopMargin - endScale) {
        _scale = (defaultTopMargin - endScale - offset) / endScale;
      } else {
        _scale = 0.0;
      }
    }
  }

  @override
  void initState() {
    scrollController.addListener(() {
      setState(() {
        calculateScaleAndTop();
      });
    });
    calculateScaleAndTop();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<DetailBloc>(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: RxStreamBuilder<Contact>(
        stream: bloc.contact$,
        builder: (context, contact) {
          return Stack(
            children: <Widget>[
              CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                          contact == null ? 'Does not exists' : contact.name),
                      background: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Theme.of(context).accentColor,
                              Theme.of(context).primaryColor,
                            ],
                            begin: AlignmentDirectional.topStart,
                            end: AlignmentDirectional.bottomEnd,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (contact != null) _buildDetailContent(contact, height),
                ],
              ),
              if (contact != null)
                Positioned(
                  child: Transform.scale(
                    scale: _scale,
                    child: FloatingActionButton(
                      elevation: 12,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return BlocProvider<EditOrAddBloc>(
                                initBloc: (context) {
                                  return EditOrAddBloc(
                                    context.get(),
                                    false,
                                    contact: contact,
                                  );
                                },
                                child: EditOrAddPage(
                                  addMode: false,
                                  contact: contact,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Icon(Icons.mode_edit),
                    ),
                  ),
                  top: _top,
                  right: 16.0,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(Contact contact, double height) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        <Widget>[
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone number: '),
            subtitle: Text(contact.phone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () => _call(contact.phone),
                ),
                IconButton(
                  icon: Icon(Icons.sms),
                  onPressed: () => _sms(contact.phone),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.label_outline),
            title: Text('Address: '),
            subtitle: Text(contact.address),
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Gender: '),
            subtitle: Text(
              contact.gender == Gender.male
                  ? 'Male'
                  : contact.gender == Gender.female
                      ? 'Female'
                      : '???',
            ),
          ),
          ListTile(
            leading: Icon(Icons.create),
            title: Text('Created at: '),
            subtitle: Text(
              _dateFormat.format(contact.createdAt),
            ),
          ),
          ListTile(
            leading: Icon(Icons.update),
            title: Text('Updated at: '),
            subtitle: Text(
              _dateFormat.format(contact.updatedAt),
            ),
          ),
          Container(
            height: height / 2,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  void _call(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _sms(String phone) async {
    final url = 'sms:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
