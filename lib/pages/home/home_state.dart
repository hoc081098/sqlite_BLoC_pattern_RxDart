import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:flutter/foundation.dart';

import '../../domain/contact.dart';

part 'home_state.g.dart';

abstract class HomeState implements Built<HomeState, HomeStateBuilder> {
  BuiltList<Contact> get contacts;

  bool get isLoading;

  Object? get error;

  HomeState._();

  factory HomeState([Function(HomeStateBuilder b) updates]) = _$HomeState;
}

@immutable
abstract class HomeMessage {}

class DeleteContactSuccess implements HomeMessage {
  const DeleteContactSuccess();
}

class DeleteContactFailure implements HomeMessage {
  const DeleteContactFailure();
}
