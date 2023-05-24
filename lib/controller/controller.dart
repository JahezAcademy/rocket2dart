import 'package:flutter/material.dart';
import 'package:rocket_cli/rocket_cli.dart';

class GeneratorController extends ChangeNotifier {
  bool loading = false;
  final controller = ModelsController();
  void setLoading(bool status) {
    loading = status;
    notifyListeners();
  }

  void clearAll() {
    controller.clearAll();
    notifyListeners();
  }

  void generate(String inputUser, String className, {bool multi = false}) {
    setLoading(true);
    Generator generator = Generator();
    generator
        .generate(inputUser, className, controller)
        .whenComplete(() => setLoading(false));
  }
}
