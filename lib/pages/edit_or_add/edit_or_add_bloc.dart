import 'dart:async';

import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';
import 'package:sqlite_bloc_rxdart/domain/contact_repository.dart';
import 'package:sqlite_bloc_rxdart/pages/edit_or_add/edit_or_add_state.dart';

bool _isValidPhone(String phone) {
  final _phoneRegExpString = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
  return RegExp(_phoneRegExpString, caseSensitive: false).hasMatch(phone);
}

class EditOrAddBloc implements BaseBloc {
  final void Function(String) nameChanged;
  final void Function(String) phoneChanged;
  final void Function(String) addressChanged;
  final void Function(Gender) genderChanged;
  final void Function() submit;

  final Stream<NameError> nameError$;
  final Stream<PhoneError> phoneError$;
  final Stream<AddressError> addressError$;
  final ValueObservable<Gender> gender$;
  final Stream<bool> isLoading$;
  final Stream<EditOrAddMessage> message$;

  final void Function() _dispose;

  EditOrAddBloc._(
    this._dispose, {
    @required this.nameChanged,
    @required this.phoneChanged,
    @required this.addressChanged,
    @required this.genderChanged,
    @required this.submit,
    @required this.nameError$,
    @required this.phoneError$,
    @required this.addressError$,
    @required this.gender$,
    @required this.isLoading$,
    @required this.message$,
  });

  @override
  void dispose() => _dispose();

  factory EditOrAddBloc(
    final ContactRepository contactRepo,
    final bool addMode,
  ) {
    assert(contactRepo != null, 'contactRepo cannot be null');
    assert(addMode != null, 'addMode cannot be null');

    //ignore_for_file: close_sinks

    final nameController = BehaviorSubject<String>.seeded('');
    final phoneController = BehaviorSubject<String>.seeded('');
    final addressController = BehaviorSubject<String>.seeded('');
    final genderController = BehaviorSubject<Gender>.seeded(Gender.male);
    final submitController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);

    final controllers = <StreamController>[
      nameController,
      phoneController,
      addressController,
      genderController,
      submitController,
      isLoadingController
    ];

    final nameError$ = nameController.map((name) {
      if (name.length < 3) {
        return const LengthOfNameIsLessThanThreeCharacters();
      }
      return null;
    }).share();

    final phoneError$ = phoneController.map((phone) {
      if (!_isValidPhone(phone)) {
        return const InvalidPhoneNumber();
      }
      return null;
    }).share();

    final addressError$ = addressController.map((address) {
      if (address.length < 3) {
        return const LengthOfAddressIsLessThanThreeCharacters();
      }
      return null;
    }).share();

    final submit$ = submitController
        .withLatestFrom(
          Observable.combineLatest(
            [
              nameError$,
              phoneError$,
              addressError$,
            ],
            (allErrors) => allErrors.every((error) => error == null),
          ),
          (_, bool isValid) => isValid,
        )
        .share();

    final message$ = Observable.merge([
      submit$
          .where((isValid) => !isValid)
          .map((_) => const InvalidInformation()),
      submit$
          .where((isValid) => isValid)
          .exhaustMap((_) => _performInsertOrUpdate(
                addMode,
                contactRepo,
                nameController.value,
                phoneController.value,
                addressController.value,
                genderController.value,
                isLoadingController,
              )),
    ]).publish();

    final subscriptions = <StreamSubscription>[
      message$
          .listen((message) => print('[EDIT_OR_ADD_BLOC] message=$message')),
      message$.connect(),
    ];

    return EditOrAddBloc._(
      () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
        print('[EDIT_OR_ADD_BLOC] disposed');
      },
      nameChanged: nameController.add,
      phoneChanged: phoneController.add,
      addressChanged: addressController.add,
      genderChanged: genderController.add,
      submit: () => submitController.add(null),
      nameError$: nameError$,
      phoneError$: phoneError$,
      addressError$: addressError$,
      gender$: genderController,
      isLoading$: isLoadingController,
      message$: message$,
    );
  }

  static Stream<EditOrAddMessage> _performInsertOrUpdate(
    bool addMode,
    ContactRepository contactRepo,
    String name,
    String phone,
    String address,
    Gender gender,
    Sink<bool> isLoadingSink,
  ) async* {
    isLoadingSink.add(true);

    if (addMode) {
      final now = DateTime.now();
      try {
        final success = await contactRepo.insert(
          Contact(
            (b) => b
              ..name = name
              ..phone = phone
              ..address = address
              ..gender = gender
              ..createdAt = now
              ..updatedAt = now,
          ),
        );
        if (success) {
          yield const AddContactSuccess();
        } else {
          yield const AddContactFailure();
        }
      } catch (e) {
        yield AddContactFailure(e);
      } finally {
        isLoadingSink.add(false);
      }
    } else {
      try {
        final success = await contactRepo.update(
          Contact(
            (b) => b
              ..name = name
              ..phone = phone
              ..address = address
              ..gender = gender
              ..updatedAt = DateTime.now(),
          ),
        );
        if (success) {
          yield const UpdateContactSuccess();
        } else {
          yield const UpdateContactFailure();
        }
      } catch (e) {
        yield UpdateContactFailure(e);
      } finally {
        isLoadingSink.add(false);
      }
    }
  }
}
