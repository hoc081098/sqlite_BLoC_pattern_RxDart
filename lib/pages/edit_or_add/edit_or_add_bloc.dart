import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

import '../../domain/contact.dart';
import '../../domain/contact_repository.dart';
import 'edit_or_add_state.dart';

bool _isValidPhone(String phone) {
  final _phoneRegExpString = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
  return RegExp(_phoneRegExpString, caseSensitive: false).hasMatch(phone);
}

class EditOrAddBloc extends DisposeCallbackBaseBloc {
  final Func1<String, void> nameChanged;
  final Func1<String, void> phoneChanged;
  final Func1<String, void> addressChanged;
  final Func1<Gender?, void> genderChanged;
  final VoidAction submit;

  final Stream<NameError?> nameError$;
  final Stream<PhoneError?> phoneError$;
  final Stream<AddressError?> addressError$;
  final ValueStream<Gender> gender$;
  final Stream<bool> isLoading$;
  final Stream<EditOrAddMessage> message$;

  EditOrAddBloc._(
    VoidAction dispose, {
    required this.nameChanged,
    required this.phoneChanged,
    required this.addressChanged,
    required this.genderChanged,
    required this.submit,
    required this.nameError$,
    required this.phoneError$,
    required this.addressError$,
    required this.gender$,
    required this.isLoading$,
    required this.message$,
  }) : super(dispose);

  factory EditOrAddBloc(
    final ContactRepository contactRepo,
    final bool addMode, {
    Contact? contact,
  }) {
    assert(addMode || contact != null,
        'contact must be not null when in editing mode');

    //ignore_for_file: close_sinks

    final nameController = BehaviorSubject<String>.seeded(contact?.name ?? '');
    final phoneController =
        BehaviorSubject<String>.seeded(contact?.phone ?? '');
    final addressController =
        BehaviorSubject<String>.seeded(contact?.address ?? '');
    final genderController =
        BehaviorSubject<Gender>.seeded(contact?.gender ?? Gender.male);
    final submitController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);

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
          Rx.combineLatest(
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

    final message$ = Rx.merge([
      submit$
          .where((isValid) => !isValid)
          .map((_) => const InvalidInformation()),
      submit$
          .where((isValid) => isValid)
          .exhaustMap((_) => _performInsertOrUpdate(
                contactRepo,
                addMode,
                contact?.id,
                nameController.requireValue,
                phoneController.requireValue,
                addressController.requireValue,
                genderController.requireValue,
                isLoadingController,
              )),
    ]).publish();

    final bag = DisposeBag([
      nameController.debug(identifier: '[EDIT_OR_ADD_BLOC] name').collect(),
      phoneController.debug(identifier: '[EDIT_OR_ADD_BLOC] phone').collect(),
      addressController
          .debug(identifier: '[EDIT_OR_ADD_BLOC] address')
          .collect(),
      genderController.debug(identifier: '[EDIT_OR_ADD_BLOC] gender').collect(),
      message$.debug(identifier: '[EDIT_OR_ADD_BLOC] message').collect(),
      message$.connect(),
      //
      nameController,
      phoneController,
      addressController,
      genderController,
      submitController,
      isLoadingController,
    ], 'EditOrAddBloc');

    return EditOrAddBloc._(
      bag.dispose,
      nameChanged: nameController.add,
      phoneChanged: phoneController.add,
      addressChanged: addressController.add,
      genderChanged: (v) => v != null ? genderController.add(v) : null,
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
    ContactRepository contactRepo,
    bool addMode,
    int? id,
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
              ..id = id
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
              ..id = id
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
