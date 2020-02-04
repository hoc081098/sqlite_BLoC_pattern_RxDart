import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/contact.dart';
import '../../domain/contact_repository.dart';
import 'home_state.dart';

// ignore_for_file: close_sinks

class HomeBloc implements BaseBloc {
  final void Function(String) search;
  final void Function(Contact) delete;
  final void Function() deleteAll;

  final ValueStream<HomeState> state$;
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
        .switchMap((s) => _performSearch(contactRepo, s))
        .publishValueSeededDistinct(
          seedValue: HomeState((b) => b..isLoading = true),
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
      state$.listen((state) =>
          print('[HOME_BLOC] state.length=${state.contacts.length}')),
      state$.connect(),
      message$.connect(),
    ];

    return HomeBloc._(
      () => deleteAllController.add(null),
      searchController.add,
      deleteController.add,
      state$,
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
