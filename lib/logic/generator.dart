import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:flutter/material.dart';
import 'package:json2dart/controller/controller.dart';

Future json2Dart(String inputUser, String className) {
  className = className.isEmpty
      ? "MyModel"
      : className.substring(0, 1).toUpperCase() + className.substring(1);

  inputUser = inputUser.isEmpty ? '{"mcPackage":"mc"}' : inputUser;
  try {
    var jsonInputUser = json.decode(inputUser.trim());
    String data = "";
    String variable = "";
    String parameters = "";
    String fromVar = "";
    String toVar = "";
    String initial = "";
    String tj = "";
    String multi = "";
    if (jsonInputUser is List) {
      data += " List<$className>? multi;\n";
      multi = """@override\n\nvoid setMulti(List data) {
        List<$className> listOf${className.toLowerCase()} = data.map((e) {
          $className ${className.toLowerCase()} = $className();
          ${className.toLowerCase()}.fromJson(e);
          return ${className.toLowerCase()};
            }).toList();
            multi = listOf${className.toLowerCase()};
          }\n""";

      for (Map i in jsonInputUser) {
        for (String u in i.keys) {
          String fixedField = fixFieldName(u);
          variable += ' String ${fixedField}Var = "$u";\n';
          fromVar += "  $fixedField = json['$u'] ?? $fixedField;\n";
          parameters += """  this.$fixedField,\n""";
          toVar += "  data['$u'] = $fixedField$tj;\n";
          if (i[u] is String) {
            data += """ String? $fixedField;\n""";
          } else if (i[u] is num && i[u].toString().contains(".")) {
            data += """ double? $fixedField;\n""";
          } else if (i[u] is int) {
            data += """ int? $fixedField;\n""";
          } else if (i[u] is List) {
            if (i[u][0] is List) {
              String mdl = u.firstUpper;
              json2Dart(json.encode(i[u]), mdl);
              data += """ $mdl? $u;\n""";
              initial += "  $u ??= $mdl();\n";
              fromVar += "  $u!.fromJson(json['$u'] ?? $u!.toJson());\n";
              tj = ".toJson()";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
              tj = "";
            } else if (i[u][0] is Map) {
              String mdl = u.firstUpper;
              json2Dart(json.encode(i[u]), mdl);
              data += """ $mdl? $u;\n""";
              initial += "  $u ??= $mdl();\n";
              fromVar += "  $u!.fromJson(json['$u'] ?? $u!.toJson());\n";
              tj = ".toJson()";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
              tj = "";
            } else {
              data += """ List? $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            }
          } else if (i[u] is Map) {
            String mdl = u.firstUpper;
            json2Dart(json.encode(i[u]), mdl);
            data += """ $mdl? $u;\n""";
            initial += "  $u ??= $mdl();\n";
            fromVar += "  $u!.fromJson(json['$u'] ?? $u!.toJson());\n";
            tj = ".toJson()";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
            tj = "";
          } else {
            print("\n>> See this type is not their .\n");
          }
        }
        break;
      }
    } else {
      for (String u in jsonInputUser.keys) {
        variable += ' String ${u}Var = "$u";\n';
        String fixedField = fixFieldName(u);
        fromVar += "  $fixedField = json['$u'] ?? $fixedField;\n";
        parameters += """  this.$fixedField,\n""";
        toVar += "  data['$u'] = $fixedField$tj;\n";
        if (jsonInputUser[u] is String) {
          data += """ String? $fixedField;\n""";
        } else if (jsonInputUser[u] is num &&
            jsonInputUser[u].toString().contains(".")) {
          data += """ double? $fixedField;\n""";
        } else if (jsonInputUser[u] is int) {
          data += """ int? $fixedField;\n""";
        } else if (jsonInputUser[u] is List) {
          if (jsonInputUser[u][0] is List) {
            String mdl = u.firstUpper;
            json2Dart(json.encode(jsonInputUser[u]), mdl);
            data += """ $mdl? $u;\n""";
            initial += "  $u ??= $mdl();\n";
            fromVar += "  $u!.fromJson(json['$u'] ?? $u!.toJson());\n";
            tj = ".toJson()";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
            tj = "";
          } else if (jsonInputUser[u][0] is Map) {
            String mdl = u.firstUpper;
            json2Dart(json.encode(jsonInputUser[u]), mdl);
            data += """ $mdl? $u;\n""";
            initial += "  $u ??= $mdl();\n";
            fromVar +=
                "  $u!.setMulti(json['$u'] ?? $u!.multi!.map((e) => e.toJson()).toList());\n";
            tj = ".toJson()";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
            tj = "";
          } else {
            data += """ List? $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
          }
        } else if (jsonInputUser[u] is Map) {
          List a = [];
          a.add(jsonInputUser[u]);
          String mdl = u.firstUpper;
          json2Dart(json.encode(a), mdl);
          data += """ $mdl? $u;\n""";
          initial += "  $u ??= $mdl();\n";
          fromVar += "  $u!.fromJson(json['$u'] ?? $u!.toJson());\n";
          tj = ".toJson()";
          parameters += """  this.$u,\n""";
          toVar += "  data['$u'] = this.$u$tj;\n";
          tj = "";
        } else {
          print("\n>> See this type is not their .\n");
        }
      }
    }

    fromVar += "super.fromJson(json);\n";

    String toJson =
        "@override\n\nMap<String, dynamic> toJson() {\n final Map<String, dynamic> data = {};";
    String fromJson =
        "@override\n\nvoid fromJson(covariant Map<String, dynamic> json) {";
    String headClass =
        "import 'package:mc/mc.dart';\n\nclass $className extends McModel<$className>{\n";
    String constractor = " $className({";
    String init = initial.isNotEmpty ? "}" : ";";
    String it = initial.isNotEmpty ? "{\n" : "";
    String model = headClass +
        data +
        "\n" +
        variable +
        constractor +
        "\n" +
        parameters +
        " })" +
        it +
        initial +
        init +
        "\n" +
        fromJson +
        "\n" +
        fromVar +
        " }\n" +
        "\n\n" +
        toJson +
        "\n" +
        toVar +
        "\n" +
        "  return data;" +
        "\n }" +
        multi +
        "\n" +
        "}";

    TextEditingController result = TextEditingController();
    model = DartFormatter().format(model);
    result.text = model;
    mdl.addModel(result, className);

    return Future.value();
  } catch (e) {
    print("[-] $e");
    return Future.value("[-Error] $e");
  }
}

String fixFieldName(String name) {
  String result = "";
  if (name.contains("_")) {
    List<String> splited = name.split("_");
    splited.forEach((e) {
      if (splited.first != e) {
        result += e.substring(0, 1).toUpperCase() + e.substring(1);
      } else {
        result += e;
      }
    });
    return result;
  } else {
    return name;
  }
}

extension FirstUpper on String {
  String get firstUpper =>
      this.substring(0, 1).toUpperCase() + this.substring(1);
}

// class GeneratorRockt {
//   dynamic json;
//   String modelName;
//   GeneratorRockt(this.json, this.modelName) {
//     modelName = modelName.isEmpty
//         ? "MyModel"
//         : modelName.substring(0, 1).toUpperCase() + modelName.substring(1);

//     json = json.isEmpty ? '{"mcPackage":"mc"}' : json;
//   }
//   String data = "";
//   String variable = "";
//   String parameters = "";
//   String fromVar = "";
//   String toVar = "";
//   String initial = "";
//   String tj = "";
//   String multi = "";
//   String model;
//   void setMulti() {
//     data += " List<$modelName>? multi;\n";
//     multi = """\n\nvoid setMulti(List data) {
//         List<$modelName> listOf${modelName.toLowerCase()} = data.map((e) {
//           $modelName ${modelName.toLowerCase()} = $modelName();
//           ${modelName.toLowerCase()}.fromJson(e);
//           return ${modelName.toLowerCase()};
//             }).toList();
//             multi = listOf${modelName.toLowerCase()};
//           }\n""";
//   }

//   void mergeAll() {
//     fromVar += "super.fromJson(json);\n";

//     String toJson =
//         "@override\n\nMap<String, dynamic> toJson() {\n final Map<String, dynamic> data = {};";
//     String fromJson =
//         "@override\n\nvoid fromJson(covariant Map<String, dynamic> json) {";
//     String headClass =
//         "import 'package:mc/mc.dart';\n\nclass $modelName extends McModel<$modelName>{\n";
//     String constractor = " $modelName({";
//     String init = initial.isNotEmpty ? "}" : ";";
//     String it = initial.isNotEmpty ? "{\n" : "";
//     model = headClass +
//         data +
//         "\n" +
//         variable +
//         constractor +
//         "\n" +
//         parameters +
//         " })" +
//         it +
//         initial +
//         init +
//         "\n" +
//         fromJson +
//         "\n" +
//         fromVar +
//         " }\n" +
//         "\n\n" +
//         toJson +
//         "\n" +
//         toVar +
//         "\n" +
//         "  return data;" +
//         "\n }" +
//         multi +
//         "\n" +
//         "}";
//   }

//   void setField(String field) {
//     String fixedField = fixFieldName(field);
//     variable += ' String ${fixedField}Var = "$field";\n';
//     fromVar += "  $fixedField = json['$field'] ?? $fixedField;\n";
//     parameters += """  this.$fixedField,\n""";
//     toVar += "  data['$field'] = $fixedField$tj;\n";
//   }

//   void setType(String field) {
//     String fixedField = fixFieldName(field);
//     if (json[field] is String) {
//       data += """ String? $fixedField;\n""";
//     } else if (json[field] is num && json[field].toString().contains(".")) {
//       data += """ double? $fixedField;\n""";
//     } else if (json[field] is int) {
//       data += """ int? $fixedField;\n""";
//     } else if (json[field] is Map) {
//       // String mdl = u.firstUpper;
//       generate();
//     } else if (json[field] is List) {}
//   }

//   generate() {
//     if (json is Map) {
//       for (String field in json.keys) {
//         setField(field);
//         setType(field);
//         mergeAll();
//       }
//     } else {}
//   }

//   String fixFieldName(String name) {
//     String result = "";
//     if (name.contains("_")) {
//       List<String> splited = name.split("_");
//       splited.forEach((e) {
//         if (splited.first != e) {
//           result += e.substring(0, 1).toUpperCase() + e.substring(1);
//         } else {
//           result += e;
//         }
//       });
//       return result;
//     } else {
//       return name;
//     }
//   }
// }
