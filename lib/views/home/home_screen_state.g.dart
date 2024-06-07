// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeScreenState on _HomeScreenState, Store {
  Computed<bool>? _$showClearIconForFilterComputed;

  @override
  bool get showClearIconForFilter => (_$showClearIconForFilterComputed ??=
          Computed<bool>(() => super.showClearIconForFilter,
              name: '_HomeScreenState.showClearIconForFilter'))
      .value;
  Computed<bool>? _$showClearIconForMinAgeComputed;

  @override
  bool get showClearIconForMinAge => (_$showClearIconForMinAgeComputed ??=
          Computed<bool>(() => super.showClearIconForMinAge,
              name: '_HomeScreenState.showClearIconForMinAge'))
      .value;
  Computed<bool>? _$showClearIconForMaxAgeComputed;

  @override
  bool get showClearIconForMaxAge => (_$showClearIconForMaxAgeComputed ??=
          Computed<bool>(() => super.showClearIconForMaxAge,
              name: '_HomeScreenState.showClearIconForMaxAge'))
      .value;

  late final _$_showClearIconForFilterAtom =
      Atom(name: '_HomeScreenState._showClearIconForFilter', context: context);

  @override
  bool get _showClearIconForFilter {
    _$_showClearIconForFilterAtom.reportRead();
    return super._showClearIconForFilter;
  }

  @override
  set _showClearIconForFilter(bool value) {
    _$_showClearIconForFilterAtom
        .reportWrite(value, super._showClearIconForFilter, () {
      super._showClearIconForFilter = value;
    });
  }

  late final _$_showClearIconForMinAgeAtom =
      Atom(name: '_HomeScreenState._showClearIconForMinAge', context: context);

  @override
  bool get _showClearIconForMinAge {
    _$_showClearIconForMinAgeAtom.reportRead();
    return super._showClearIconForMinAge;
  }

  @override
  set _showClearIconForMinAge(bool value) {
    _$_showClearIconForMinAgeAtom
        .reportWrite(value, super._showClearIconForMinAge, () {
      super._showClearIconForMinAge = value;
    });
  }

  late final _$_showClearIconForMaxAgeAtom =
      Atom(name: '_HomeScreenState._showClearIconForMaxAge', context: context);

  @override
  bool get _showClearIconForMaxAge {
    _$_showClearIconForMaxAgeAtom.reportRead();
    return super._showClearIconForMaxAge;
  }

  @override
  set _showClearIconForMaxAge(bool value) {
    _$_showClearIconForMaxAgeAtom
        .reportWrite(value, super._showClearIconForMaxAge, () {
      super._showClearIconForMaxAge = value;
    });
  }

  late final _$_HomeScreenStateActionController =
      ActionController(name: '_HomeScreenState', context: context);

  @override
  void setFilterText(bool value) {
    final _$actionInfo = _$_HomeScreenStateActionController.startAction(
        name: '_HomeScreenState.setFilterText');
    try {
      return super.setFilterText(value);
    } finally {
      _$_HomeScreenStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMinAgeText(bool value) {
    final _$actionInfo = _$_HomeScreenStateActionController.startAction(
        name: '_HomeScreenState.setMinAgeText');
    try {
      return super.setMinAgeText(value);
    } finally {
      _$_HomeScreenStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMaxAgeText(bool value) {
    final _$actionInfo = _$_HomeScreenStateActionController.startAction(
        name: '_HomeScreenState.setMaxAgeText');
    try {
      return super.setMaxAgeText(value);
    } finally {
      _$_HomeScreenStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showClearIconForFilter: ${showClearIconForFilter},
showClearIconForMinAge: ${showClearIconForMinAge},
showClearIconForMaxAge: ${showClearIconForMaxAge}
    ''';
  }
}
