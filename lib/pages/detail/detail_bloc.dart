import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';
import 'package:sqlite_bloc_rxdart/domain/contact_repository.dart';

class DetailBloc implements BaseBloc {
  final ValueObservable<Contact> contact$;

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

    final contactDistinct$ = publishValueSeededDistinct(
      contactRepo.getContactById(initial.id),
      seedValue: initial,
    );

    final subscriptions = [
      contactDistinct$
          .listen((contact) => print('[DETAIL_BLOC] contact=$contact')),
      contactDistinct$.connect(),
    ];

    return DetailBloc._(
      contactDistinct$,
      () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        print('[DETAIL_BLOC] disposed id=${initial.id}');
      },
    );
  }
}
