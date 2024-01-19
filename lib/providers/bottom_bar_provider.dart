import 'package:flutter/foundation.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class BottomBarProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get getCurrentIndex => _currentIndex;
  PersistentTabController? persistentTabController;

  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setController() {
    persistentTabController =
        PersistentTabController(initialIndex: _currentIndex);
    notifyListeners();
  }
}
