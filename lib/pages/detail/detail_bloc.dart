import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/contact.dart';
import '../../domain/contact_repository.dart';

class DetailBloc implements BaseBloc {
  final ValueStream<Contact> contact$;

  final void Function() _dispose;

  DetailBloc._(
    this.contact$,
    this._dispose,
  );

  @override
  void dispose() => _dispose();

  factory DetailBloc(
    final ContactRepository contactRepo,
    final Contact initial,
  ) {
    assert(contactRepo != null, 'contactRepo cannot be null');
    assert(initial != null, 'initial cannot be null');

    final contact$ = contactRepo
        .getContactById(initial.id)
        .publishValueSeededDistinct(seedValue: initial);

    final subscriptions = [
      contact$.listen((contact) => print('[DETAIL_BLOC] contact=$contact')),
      contact$.connect(),
    ];

    return DetailBloc._(
      contact$,
      () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        print('[DETAIL_BLOC] disposed id=${initial.id}');
      },
    );
  }
}
