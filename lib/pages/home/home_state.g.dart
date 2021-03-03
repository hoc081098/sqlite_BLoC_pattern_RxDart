// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HomeState extends HomeState {
  @override
  final BuiltList<Contact> contacts;
  @override
  final bool isLoading;
  @override
  final Object? error;

  factory _$HomeState([void Function(HomeStateBuilder)? updates]) =>
      (new HomeStateBuilder()..update(updates)).build();

  _$HomeState._({required this.contacts, required this.isLoading, this.error})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(contacts, 'HomeState', 'contacts');
    BuiltValueNullFieldError.checkNotNull(isLoading, 'HomeState', 'isLoading');
  }

  @override
  HomeState rebuild(void Function(HomeStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HomeStateBuilder toBuilder() => new HomeStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HomeState &&
        contacts == other.contacts &&
        isLoading == other.isLoading &&
        error == other.error;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc(0, contacts.hashCode), isLoading.hashCode), error.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('HomeState')
          ..add('contacts', contacts)
          ..add('isLoading', isLoading)
          ..add('error', error))
        .toString();
  }
}

class HomeStateBuilder implements Builder<HomeState, HomeStateBuilder> {
  _$HomeState? _$v;

  ListBuilder<Contact>? _contacts;
  ListBuilder<Contact> get contacts =>
      _$this._contacts ??= new ListBuilder<Contact>();
  set contacts(ListBuilder<Contact>? contacts) => _$this._contacts = contacts;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  Object? _error;
  Object? get error => _$this._error;
  set error(Object? error) => _$this._error = error;

  HomeStateBuilder();

  HomeStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contacts = $v.contacts.toBuilder();
      _isLoading = $v.isLoading;
      _error = $v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HomeState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$HomeState;
  }

  @override
  void update(void Function(HomeStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$HomeState build() {
    _$HomeState _$result;
    try {
      _$result = _$v ??
          new _$HomeState._(
              contacts: contacts.build(),
              isLoading: BuiltValueNullFieldError.checkNotNull(
                  isLoading, 'HomeState', 'isLoading'),
              error: error);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'contacts';
        contacts.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'HomeState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
