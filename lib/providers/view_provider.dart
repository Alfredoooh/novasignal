import 'package:flutter/material.dart';

enum ViewType { grid, list }

class ViewProvider extends ChangeNotifier {
  ViewType _currentView = ViewType.grid;

  ViewType get currentView => _currentView;

  void toggleView() {
    _currentView = _currentView == ViewType.grid ? ViewType.list : ViewType.grid;
    notifyListeners();
  }

  void setView(ViewType view) {
    _currentView = view;
    notifyListeners();
  }
}