// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeScreenState on _HomeScreenState, Store {
  Computed<bool>? _$showClearIconForFilterComputedComputed;

  @override
  bool get showClearIconForFilterComputed =>
      (_$showClearIconForFilterComputedComputed ??= Computed<bool>(
              () => super.showClearIconForFilterComputed,
              name: '_HomeScreenState.showClearIconForFilterComputed'))
          .value;
  Computed<bool>? _$showClearIconForMinAgeComputedComputed;

  @override
  bool get showClearIconForMinAgeComputed =>
      (_$showClearIconForMinAgeComputedComputed ??= Computed<bool>(
              () => super.showClearIconForMinAgeComputed,
              name: '_HomeScreenState.showClearIconForMinAgeComputed'))
          .value;
  Computed<bool>? _$showClearIconForMaxAgeComputedComputed;

  @override
  bool get showClearIconForMaxAgeComputed =>
      (_$showClearIconForMaxAgeComputedComputed ??= Computed<bool>(
              () => super.showClearIconForMaxAgeComputed,
              name: '_HomeScreenState.showClearIconForMaxAgeComputed'))
          .value;

  late final _$showClearIconForFilterAtom =
      Atom(name: '_HomeScreenState.showClearIconForFilter', context: context);

  @override
  bool get showClearIconForFilter {
    _$showClearIconForFilterAtom.reportRead();
    return super.showClearIconForFilter;
  }

  @override
  set showClearIconForFilter(bool value) {
    _$showClearIconForFilterAtom
        .reportWrite(value, super.showClearIconForFilter, () {
      super.showClearIconForFilter = value;
    });
  }

  late final _$showClearIconForMinAgeAtom =
      Atom(name: '_HomeScreenState.showClearIconForMinAge', context: context);

  @override
  bool get showClearIconForMinAge {
    _$showClearIconForMinAgeAtom.reportRead();
    return super.showClearIconForMinAge;
  }

  @override
  set showClearIconForMinAge(bool value) {
    _$showClearIconForMinAgeAtom
        .reportWrite(value, super.showClearIconForMinAge, () {
      super.showClearIconForMinAge = value;
    });
  }

  late final _$showClearIconForMaxAgeAtom =
      Atom(name: '_HomeScreenState.showClearIconForMaxAge', context: context);

  @override
  bool get showClearIconForMaxAge {
    _$showClearIconForMaxAgeAtom.reportRead();
    return super.showClearIconForMaxAge;
  }

  @override
  set showClearIconForMaxAge(bool value) {
    _$showClearIconForMaxAgeAtom
        .reportWrite(value, super.showClearIconForMaxAge, () {
      super.showClearIconForMaxAge = value;
    });
  }

  late final _$filterTextAtom =
      Atom(name: '_HomeScreenState.filterText', context: context);

  @override
  String get filterText {
    _$filterTextAtom.reportRead();
    return super.filterText;
  }

  @override
  set filterText(String value) {
    _$filterTextAtom.reportWrite(value, super.filterText, () {
      super.filterText = value;
    });
  }

  late final _$minAgeTextAtom =
      Atom(name: '_HomeScreenState.minAgeText', context: context);

  @override
  String get minAgeText {
    _$minAgeTextAtom.reportRead();
    return super.minAgeText;
  }

  @override
  set minAgeText(String value) {
    _$minAgeTextAtom.reportWrite(value, super.minAgeText, () {
      super.minAgeText = value;
    });
  }

  late final _$maxAgeTextAtom =
      Atom(name: '_HomeScreenState.maxAgeText', context: context);

  @override
  String get maxAgeText {
    _$maxAgeTextAtom.reportRead();
    return super.maxAgeText;
  }

  @override
  set maxAgeText(String value) {
    _$maxAgeTextAtom.reportWrite(value, super.maxAgeText, () {
      super.maxAgeText = value;
    });
  }

  late final _$_HomeScreenStateActionController =
      ActionController(name: '_HomeScreenState', context: context);

  @override
  void setFilterText(String text) {
    final _$actionInfo = _$_HomeScreenStateActionController.startAction(
        name: '_HomeScreenState.setFilterText');
    try {
      return super.setFilterText(text);
    } finally {
      _$_HomeScreenStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMinAgeText(String text) {
    final _$actionInfo = _$_HomeScreenStateActionController.startAction(
        name: '_HomeScreenState.setMinAgeText');
    try {
      return super.setMinAgeText(text);
    } finally {
      _$_HomeScreenStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMaxAgeText(String text) {
    final _$actionInfo = _$_HomeScreenStateActionController.startAction(
        name: '_HomeScreenState.setMaxAgeText');
    try {
      return super.setMaxAgeText(text);
    } finally {
      _$_HomeScreenStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showClearIconForFilter: ${showClearIconForFilter},
showClearIconForMinAge: ${showClearIconForMinAge},
showClearIconForMaxAge: ${showClearIconForMaxAge},
filterText: ${filterText},
minAgeText: ${minAgeText},
maxAgeText: ${maxAgeText},
showClearIconForFilterComputed: ${showClearIconForFilterComputed},
showClearIconForMinAgeComputed: ${showClearIconForMinAgeComputed},
showClearIconForMaxAgeComputed: ${showClearIconForMaxAgeComputed}
    ''';
  }
}
