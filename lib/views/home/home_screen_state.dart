import 'package:mobx/mobx.dart';

part 'home_screen_state.g.dart';

class HomeScreenState = _HomeScreenState with _$HomeScreenState;

abstract class _HomeScreenState with Store {
  @observable
  bool _showClearIconForFilter = false;

  @observable
  bool _showClearIconForMinAge = false;

  @observable
  bool _showClearIconForMaxAge = false;


  @computed
  bool get showClearIconForFilter => _showClearIconForFilter;

  @computed
  bool get showClearIconForMinAge => _showClearIconForMinAge;

  @computed
  bool get showClearIconForMaxAge => _showClearIconForMaxAge;

  @action
  void setFilterText() {
    _showClearIconForFilter = !_showClearIconForFilter;
  }

  @action
  void setMinAgeText() {
    _showClearIconForMinAge = !_showClearIconForMinAge;
  }

  @action
  void setMaxAgeText() {
    _showClearIconForMaxAge = !_showClearIconForMaxAge;
  }
}
