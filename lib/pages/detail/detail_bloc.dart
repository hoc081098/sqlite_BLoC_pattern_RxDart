import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import '../../domain/contact.dart';
import '../../domain/contact_repository.dart';

class DetailBloc extends DisposeCallbackBaseBloc {
  final DistinctValueStream<Contact> contact$;

  DetailBloc._(
    this.contact$,
    Func0<void> dispose,
  ) : super(dispose);

  factory DetailBloc(
    final ContactRepository contactRepo,
    final Contact initial,
  ) {
    assert(contactRepo != null, 'contactRepo cannot be null');
    assert(initial != null, 'initial cannot be null');

    final contact$ =
        contactRepo.getContactById(initial.id).publishValueDistinct(initial);

    final bag = DisposeBag([
      contact$.debug(identifier: '[DETAIL_BLOC] contact').collect(),
      contact$.connect(),
    ], 'DetailBloc');

    return DetailBloc._(contact$, bag.dispose);
  }
}
