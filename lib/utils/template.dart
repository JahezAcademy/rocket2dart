const String template = """import 'package:mvc_rocket/mvc_rocket.dart';

class -name- extends RocketModel<-name-> {
  -fields-

  -name-({
    -fieldsConstructor-
  });

  @override
  void fromJson(Map<String, dynamic> json, {bool isSub = false}) {
    -fromJsonFields-
    super.fromJson(json, isSub: isSub);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    -toJsonFields-

    return data;
  }

  -instance-
}""";
