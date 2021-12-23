import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json2dart/controller/controller.dart';
import 'package:json2dart/ui/widgets/link.dart';
import 'package:json2dart/ui/widgets/txtfield.dart';
import 'package:dart_style/dart_style.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  MyHomePage({this.title});
  final TextEditingController data = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController result = TextEditingController();
  final Mdls mdl = Mdls();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          InkWell(
            onTap: () => mdl.clearAll(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [Icon(Icons.clear), Text("Clear All  ")],
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: MediaQuery.of(context).size.height * 0.05),
        child: SingleChildScrollView(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: MediaQuery.of(context).size.height * 0.05,
            children: [
              MyTextField(
                data,
                hint: 'Here your json data',
                help: "Type your json data from your API",
                label: 'Json Data',
                icon: Icons.data_usage,
                max: 15,
              ),
              MyTextField(
                name,
                hint: 'Here your Model name',
                help: 'Default name MyModel',
                label: 'Model name',
                icon: Icons.title,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.08,
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.brown)),
                  child: Text(
                    "Convert",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    mdl.setloadingt(true);
                    json2Dart(data.text, name.text)
                        .whenComplete(() => mdl.setloadingt(false));
                  },
                ),
              ),
              AnimatedBuilder(
                builder: (BuildContext context, Widget _) {
                  return mdl.loading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.brown),
                          ),
                        )
                      : Wrap(
                          children: mdl.models
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyTextField(e,
                                      hint: 'Here your Model for mc package',
                                      label:
                                          'Result ${mdl.titles[mdl.models.indexOf(e)]} Model',
                                      icon: Icons.restore_outlined,
                                      copy: IconButton(
                                        icon: Icon(Icons.copy),
                                        onPressed: () => Clipboard.setData(
                                                new ClipboardData(text: e.text))
                                            .whenComplete(() =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content:
                                                      const Text('Data copied'),
                                                  duration: const Duration(
                                                      seconds: 1),
                                                ))),
                                      )),
                                ),
                              )
                              .toList(),
                        );
                },
                animation: mdl,
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  Links("https://pub.dev/packages/mc", Icons.library_add,
                      "mc Package"),
                  Links("https://github.com/M97Chahboun", Icons.code, "Github"),
                  Links("https://github.com/ourflutter/Json2Dart",
                      Icons.settings, "Tool"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

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
        multi = """\n\nvoid setMulti(List data) {
        List<$className> listOf${className.toLowerCase()} = data.map((e) {
          $className ${className.toLowerCase()} = $className();
          ${className.toLowerCase()}.fromJson(e);
          return ${className.toLowerCase()};
            }).toList();
            multi = listOf${className.toLowerCase()};
          }\n""";

        for (Map i in jsonInputUser) {
          for (String u in i.keys) {
            variable += ' String ${u}Var = "$u";\n';
            if (i[u] is String) {
              data += """ String? $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            } else if (i[u] is num && i[u].toString().contains(".")) {
              data += """ double? $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            } else if (i[u] is int) {
              data += """ int? $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            } else if (i[u] is List) {
              if (i[u][0] is List) {
                String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
                json2Dart(json.encode(i[u]), mdl);
                data += """ $mdl? $u;\n""";
                initial += "  $u ??= $mdl();\n";
                fromVar += "  $u!.fromJson(json['$u'] ?? $u!.toJson());\n";
                tj = ".toJson()";
                parameters += """  this.$u,\n""";
                toVar += "  data['$u'] = this.$u$tj;\n";
                tj = "";
              } else if (i[u][0] is Map) {
                String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
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
              String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
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
          if (jsonInputUser[u] is String) {
            data += """ String? $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
          } else if (jsonInputUser[u] is num &&
              jsonInputUser[u].toString().contains(".")) {
            data += """ double? $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
          } else if (jsonInputUser[u] is int) {
            data += """ int? $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
          } else if (jsonInputUser[u] is List) {
            if (jsonInputUser[u][0] is List) {
              String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
              json2Dart(json.encode(jsonInputUser[u]), mdl);
              data += """ $mdl? $u;\n""";
              initial += "  $u ??= $mdl();\n";
              fromVar += "  $u!.fromJson(json['$u'] ?? $u!.toJson());\n";
              tj = ".toJson()";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
              tj = "";
            } else if (jsonInputUser[u][0] is Map) {
              String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
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
            String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
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

      fromVar += "  return super.fromJson(json);\n";

      String toJson =
          " Map<String, dynamic> toJson() {\n final Map<String, dynamic> data = {};";
      String fromJson =
          "\n\nvoid fromJson(covariant Map<String, dynamic> json) {";
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
}
