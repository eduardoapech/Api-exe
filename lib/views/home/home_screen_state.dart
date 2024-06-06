import 'package:mobx/mobx.dart';

part 'home_screen_state.g.dart';

class HomeScreenState = _HomeScreenState with _$HomeScreenState;

abstract class _HomeScreenState with Store {
  @observable
  bool showClearIconForFilter = false;

  @observable
  bool showClearIconForMinAge = false;

  @observable
  bool showClearIconForMaxAge = false;

  @observable
  String filterText = '';

  @observable
  String minAgeText = '';

  @observable
  String maxAgeText = '';

  @computed
  bool get showClearIconForFilterComputed => filterText.isNotEmpty;

  @computed
  bool get showClearIconForMinAgeComputed => minAgeText.isNotEmpty;

  @computed
  bool get showClearIconForMaxAgeComputed => maxAgeText.isNotEmpty;

  @action
  void setFilterText(String text) {
    filterText = text;
    updateClearIcons();
  }

  @action
  void setMinAgeText(String text) {
    minAgeText = text;
    updateClearIcons();
  }

  @action
  void setMaxAgeText(String text) {
    maxAgeText = text;
    updateClearIcons();
  }

  @action
  void updateClearIcons() {
    showClearIconForFilter = filterText.isNotEmpty;
    showClearIconForMinAge = minAgeText.isNotEmpty;
    showClearIconForMaxAge = maxAgeText.isNotEmpty;
  }

  @action
  void clearFilterText() {
    filterText = '';
    updateClearIcons();
  }

  @action
  void clearMinAgeText() {
    minAgeText = '';
    updateClearIcons();
  }

  @action
  void clearMaxAgeText() {
    maxAgeText = '';
    updateClearIcons();
  }
}
