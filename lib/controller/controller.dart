import 'package:dart_code_viewer2/dart_code_viewer2.dart';
import 'package:flutter/material.dart';

class ModelsController extends ChangeNotifier {
  final List<DartCodeViewer> models = [];
  bool loading = false;
  List<String> titles = [];
  void setloadingt(bool status) {
    loading = status;
    notifyListeners();
  }

  void clearAll() {
    models.clear();
    titles.clear();
    notifyListeners();
  }

  void addModel(DartCodeViewer result, String title) {
    models.add(result);
    titles.add(title);
    notifyListeners();
  }
}
