import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import '../../domain/contact.dart';
import '../../domain/contact_repository.dart';
import 'home_state.dart';

// ignore_for_file: close_sinks

class HomeBloc extends DisposeCallbackBaseBloc {
  final Func1<String, void> search;
  final Func1<Contact, void> delete;
  final Func0<void> deleteAll;

  final DistinctValueStream<HomeState> state$;
  final Stream<HomeMessage> message$;

  HomeBloc._(
    this.deleteAll,
    this.search,
    this.delete,
    this.state$,
    this.message$,
    Func0<void> dispose,
  ) : super(dispose);

  factory HomeBloc(final ContactRepository contactRepo) {
    final searchController = PublishSubject<String>();
    final deleteController = PublishSubject<Contact>();
    final deleteAllController = PublishSubject<void>();

    final state$ = searchController
        .debounceTime(const Duration(milliseconds: 500))
        .startWith('')
        .map((s) => s.trim())
        .distinct()
        .switchMap((s) => _performSearch(contactRepo, s))
        .publishValueDistinct(HomeState((b) => b..isLoading = true));

    final message$ = deleteController
        .flatMap((contact) => Rx.fromCallable(() => contactRepo.delete(contact))
            .onErrorReturn(false))
        .map((success) => success
            ? const DeleteContactSuccess()
            : const DeleteContactFailure())
        .publish();

    final bag = DisposeBag([
      deleteAllController
          .exhaustMap((_) => Rx.fromCallable(contactRepo.deleteAll))
          .debug(identifier: '[HOME_BLOC] deteteAll')
          .collect(),
      //
      message$.debug(identifier: '[HOME_BLOC] message').collect(),
      message$.connect(),
      //
      state$.debug(identifier: '[HOME_BLOC] state').collect(),
      state$.connect(),
      //
      deleteAllController,
      searchController,
      deleteController,
    ], 'HomeBloc');

    return HomeBloc._(
      () => deleteAllController.add(null),
      searchController.add,
      deleteController.add,
      state$,
      message$,
      bag.dispose,
    );
  }

  static Stream<HomeState> _performSearch(
    ContactRepository contactRepo,
    String query,
  ) {
    return contactRepo
        .search(query: query)
        .map(
          (contacts) => HomeState((b) => b
            ..contacts.replace(contacts)
            ..isLoading = false),
        )
        .onErrorReturnWith(
          (e) => HomeState((b) => b
            ..error = e
            ..isLoading = false),
        )
        .startWith(HomeState((b) => b.isLoading = true));
  }
}
