import 'package:flutter/material.dart';

class ModelsController extends ChangeNotifier {
  final List<TextEditingController> models = [];
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

  void addModel(TextEditingController result, String title) {
    models.add(result);
    titles.add(title);
    notifyListeners();
  }
}

final ModelsController mdl = ModelsController();
