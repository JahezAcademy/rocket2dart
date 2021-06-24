import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Json2Dart [mc Package]',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MyHomePage(title: 'Json to Dart for mc Package'),
    );
  }
}

class Mdls extends ChangeNotifier {
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
      String parameters = "";
      String fromVar = "";
      String toVar = "";
      String initial = "";
      String tj = "";
      String multi = "";
      if (jsonInputUser is List) {
        initial = "\n\n  multi = multi ?? [];\n";
        data += " List<$className> multi;\n";
        multi = """\n\nvoid setMulti(List data) {
        List listOf${className.toLowerCase()} = data.map((e) {
          $className ${className.toLowerCase()} = $className();
          ${className.toLowerCase()}.fromJson(e);
          return ${className.toLowerCase()};
            }).toList();
            multi = listOf${className.toLowerCase()};
          }\n""";

        for (Map i in jsonInputUser) {
          for (String u in i.keys) {
            if (i[u] is String) {
              data += """ String $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            } else if (i[u] is num && i[u].toString().contains(".")) {
              data += """ double $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            } else if (i[u] is int) {
              data += """ int $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            } else if (i[u] is List) {
              if (i[u][0] is List) {
                String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
                json2Dart(json.encode(i[u]), mdl);
                data += """ $mdl $u;\n""";
                initial += "  $u ??= $mdl();\n";
                fromVar += "  $u.fromJson(json['$u'] ?? $u.toJson());\n";
                tj = ".toJson()";
                parameters += """  this.$u,\n""";
                toVar += "  data['$u'] = this.$u$tj;\n";
                tj = "";
              } else if (i[u][0] is Map) {
                String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
                json2Dart(json.encode(i[u]), mdl);
                data += """ $mdl $u;\n""";
                initial += "  $u ??= $mdl();\n";
                fromVar += "  $u.fromJson(json['$u'] ?? $u.toJson());\n";
                tj = ".toJson()";
                parameters += """  this.$u,\n""";
                toVar += "  data['$u'] = this.$u$tj;\n";
                tj = "";
              } else {
                data += """ List $u;\n""";
                fromVar += "  $u = json['$u'] ?? $u;\n";
                parameters += """  this.$u,\n""";
                toVar += "  data['$u'] = this.$u$tj;\n";
              }
            } else if (i[u] is Map) {
              String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
              json2Dart(json.encode(i[u]), mdl);
              data += """ $mdl $u;\n""";
              initial += "  $u ??= $mdl();\n";
              fromVar += "  $u.fromJson(json['$u'] ?? $u.toJson());\n";
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
          if (jsonInputUser[u] is String) {
            data += """ String $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
          } else if (jsonInputUser[u] is num &&
              jsonInputUser[u].toString().contains(".")) {
            data += """ double $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
          } else if (jsonInputUser[u] is int) {
            data += """ int $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";
            toVar += "  data['$u'] = this.$u$tj;\n";
          } else if (jsonInputUser[u] is List) {
            if (jsonInputUser[u][0] is List) {
              String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
              json2Dart(json.encode(jsonInputUser[u]), mdl);
              data += """ $mdl $u;\n""";
              initial += "  $u ??= $mdl();\n";
              fromVar += "  $u.fromJson(json['$u'] ?? $u.toJson());\n";
              tj = ".toJson()";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
              tj = "";
            } else if (jsonInputUser[u][0] is Map) {
              String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
              json2Dart(json.encode(jsonInputUser[u]), mdl);
              data += """ $mdl $u;\n""";
              initial += "  $u ??= $mdl();\n";
              fromVar += "  $u.fromJson(json['$u'] ?? $u.toJson());\n";
              tj = ".toJson()";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
              tj = "";
            } else {
              data += """ List $u;\n""";
              fromVar += "  $u = json['$u'] ?? $u;\n";
              parameters += """  this.$u,\n""";
              toVar += "  data['$u'] = this.$u$tj;\n";
            }
          } else if (jsonInputUser[u] is Map) {
            List a = [];
            a.add(jsonInputUser[u]);
            String mdl = u.substring(0, 1).toUpperCase() + u.substring(1);
            json2Dart(json.encode(a), mdl);
            data += """ $mdl $u;\n""";
            initial += "  $u ??= $mdl();\n";
            fromVar += "  $u.fromJson(json['$u'] ?? $u.toJson());\n";
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
          " Map<String, dynamic> toJson() {\n final Map<String, dynamic> data = new Map<String, dynamic>();";
      String fromJson = " fromJson(Map<String, dynamic> json) {";
      String headClass = "class $className extends McModel<$className>{\n";
      String constractor = " $className({";
      String init = initial.isNotEmpty ? "}" : ";";
      String it = initial.isNotEmpty ? "{\n" : "";
      String model = headClass +
          data +
          "\n" +
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
      result.text = model;
      mdl.addModel(result, className);

      return Future.value();
    } catch (e) {
      print("[-] $e");
      return Future.value("[-Error] $e");
    }
  }
}

class MyTextField extends StatelessWidget {
  final String hint, help, label;
  final IconData icon;
  final TextEditingController controller;
  final int max;
  final IconButton copy;
  MyTextField(this.controller,
      {Key key,
      this.hint,
      this.help,
      this.label,
      this.icon,
      this.max,
      this.copy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
          controller: controller,
          maxLines: max,
          keyboardType: TextInputType.multiline,
          decoration: new InputDecoration(
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
            hintText: hint,
            helperText: help,
            labelText: label,
            suffixIcon: copy,
            prefixIcon: Icon(
              icon,
              color: Colors.brown,
            ),
          )),
    );
  }
}

class Links extends StatelessWidget {
  final String link, title;
  final IconData icon;
  Links(this.link, this.icon, this.title);
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  TextStyle stl = TextStyle(
      fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.brown);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(link),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.brown,
              size: 45.0,
            ),
            Text(
              title,
              style: stl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
