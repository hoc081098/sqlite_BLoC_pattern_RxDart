import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_bloc_rxdart/domain/contact.dart';

import 'package:built_value/built_value.dart';

part 'home_state.g.dart';

abstract class HomeState implements Built<HomeState, HomeStateBuilder> {
  BuiltList<Contact> get contacts;
  bool get isLoading;
  @nullable
  Object get error;

  HomeState._();

  factory HomeState([updates(HomeStateBuilder b)]) = _$HomeState;
}


@immutable
abstract class HomeMessage {}

class DeleteContactSuccess implements HomeMessage {
  const DeleteContactSuccess();
}

class DeleteContactFailure implements HomeMessage {
  const DeleteContactFailure();
}