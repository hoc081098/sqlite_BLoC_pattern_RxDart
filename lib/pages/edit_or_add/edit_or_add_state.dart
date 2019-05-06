abstract class NameError {}

class LengthOfNameIsLessThanThreeCharacters implements NameError {
  const LengthOfNameIsLessThanThreeCharacters();
}

abstract class PhoneError {}

class InvalidPhoneNumber implements PhoneError {
  const InvalidPhoneNumber();
}

abstract class AddressError {}

class LengthOfAddressIsLessThanThreeCharacters implements AddressError {
  const LengthOfAddressIsLessThanThreeCharacters();
}

abstract class EditOrAddMessage {}

class InvalidInformation implements EditOrAddMessage {
  const InvalidInformation();
}

class AddContactSuccess implements EditOrAddMessage {
  const AddContactSuccess();
}

class AddContactFailure implements EditOrAddMessage {
  final error;

  const AddContactFailure([this.error]);

  @override
  String toString() => 'AddContactFailure{error=$error}';
}

class UpdateContactSuccess implements EditOrAddMessage {
  const UpdateContactSuccess();
}

class UpdateContactFailure implements EditOrAddMessage {
  final error;

  const UpdateContactFailure([this.error]);

  @override
  String toString() => 'UpdateContactFailure{error=$error}';
}
