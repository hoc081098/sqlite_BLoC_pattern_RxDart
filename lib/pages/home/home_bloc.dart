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
  final ValueObservable<HomeState> state$;
  final void Function() _dispose;

  HomeBloc._(this.search, this.state$, this._dispose);

  @override
  void dispose() => _dispose();

  factory HomeBloc(final ContactRepository contactRepo) {
    final searchController = PublishSubject<String>();

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

    final subscriptions = [
      stateDistinct$.listen((state) => print('[HOME_BLOC] state=$state')),
      stateDistinct$.connect(),
    ];

    return HomeBloc._(
      searchController.add,
      stateDistinct$,
      () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await searchController.close();
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
