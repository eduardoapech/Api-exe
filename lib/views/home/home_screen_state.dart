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

  @observable
  int _notificationCount = 0;
  

  @computed
  bool get showClearIconForFilter => _showClearIconForFilter;

  @computed
  bool get showClearIconForMinAge => _showClearIconForMinAge;

  @computed
  bool get showClearIconForMaxAge => _showClearIconForMaxAge;

  @computed
  int get notificationCount => _notificationCount;

  @action
  void setFilterText(bool value) {
    _showClearIconForFilter = value;
  }

  @action
  void setMinAgeText(bool value) {
    _showClearIconForMinAge = value;
  }

  @action
  void setMaxAgeText(bool value) {
    _showClearIconForMaxAge = value;
  }

  @action
  void incrementNotificationCount() {
    _notificationCount++;
  }

  @action
  void resetNotificationCount() {
    _notificationCount = 0;
  }
}
