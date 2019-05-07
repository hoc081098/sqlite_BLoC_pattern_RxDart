import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';
import 'package:sqlite_bloc_rxdart/domain/contact_repository.dart';
import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:sqlite_bloc_rxdart/pages/home/home_state.dart';

// ignore_for_file: close_sinks

class HomeBloc implements BaseBloc {
  final void Function(String) search;
  final void Function(Contact) delete;
  final void Function() deleteAll;

  final ValueObservable<HomeState> state$;
  final Stream<HomeMessage> message$;

  final void Function() _dispose;

  HomeBloc._(
    this.deleteAll,
    this.search,
    this.delete,
    this.state$,
    this.message$,
    this._dispose,
  );

  @override
  void dispose() => _dispose();

  factory HomeBloc(final ContactRepository contactRepo) {
    final searchController = PublishSubject<String>();
    final deleteController = PublishSubject<Contact>();
    final deleteAllController = PublishSubject<void>();

    final state$ = searchController
        .debounceTime(const Duration(milliseconds: 500))
        .startWith('')
        .map((s) => s.trim())
        .distinct()
        .switchMap((s) => _performSearch(contactRepo, s));

    final stateDistinct$ = publishValueSeededDistinct(
      state$,
      seedValue: HomeState(
        (b) => b
          ..contacts = ListBuilder<Contact>()
          ..isLoading = true,
      ),
    );

    final message$ = deleteController.flatMap((contact) async* {
      try {
        yield await contactRepo.delete(contact);
      } catch (_) {
        yield false;
      }
    }).map((success) {
      return success
          ? const DeleteContactSuccess()
          : const DeleteContactFailure();
    }).publish();

    final subscriptions = [
      deleteAllController.exhaustMap((_) async* {
        await contactRepo.deleteAll();
      }).listen(null),
      message$.listen((message) => print('[HOME_BLOC] message=$message')),
      stateDistinct$.listen((state) =>
          print('[HOME_BLOC] state.length=${state.contacts.length}')),
      stateDistinct$.connect(),
      message$.connect(),
    ];

    return HomeBloc._(
      () => deleteAllController.add(null),
      searchController.add,
      deleteController.add,
      stateDistinct$,
      message$,
      () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait([
          deleteAllController,
          searchController,
          deleteController,
        ].map((c) => c.close()));
        print('[HOME_BLOC] disposed');
      },
    );
  }

  static Stream<HomeState> _performSearch(
    ContactRepository contactRepo,
    String s,
  ) {
    return contactRepo.search(query: s).map((contacts) {
      return HomeState(
        (b) => b
          ..contacts = ListBuilder<Contact>(contacts)
          ..isLoading = false,
      );
    }).onErrorReturnWith((e) {
      return HomeState(
        (b) => b
          ..contacts = ListBuilder<Contact>()
          ..error = e
          ..isLoading = false,
      );
    }).startWith(
      HomeState(
        (b) => b
          ..contacts = ListBuilder<Contact>()
          ..isLoading = true,
      ),
    );
  }
}
