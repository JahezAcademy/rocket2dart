import 'dart:convert';
import 'package:flutter/material.dart';
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
                help:
                    "Example your json data as List:\n[{'first_name':'Mohammed','last_name':'chahboun'}]",
                label: 'Json Data',
                icon: Icons.data_usage,
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
                child: FlatButton(
                  color: Colors.brown,
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
                                  child: MyTextField(
                                    e,
                                    hint: 'Here your Model for mc package',
                                    label:
                                        'Result ${mdl.titles[mdl.models.indexOf(e)]} Model',
                                    icon: Icons.restore_outlined,
                                  ),
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
                  Links("https://chahboun.dev", Icons.person, "Portfolio"),
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
    try {
      List jsonInputUser = json.decode(inputUser.trim());
      String data = "";
      String parameters = "";
      String fromVar = "";
      String toVar = "";
      String initial = "{\n  multi = multi ?? [];\n";
      String tj = "";
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
            data += """ List $u;\n""";
            fromVar += "  $u = json['$u'] ?? $u;\n";
            parameters += """  this.$u,\n""";

            toVar += "  data['$u'] = this.$u$tj;\n";
          } else if (i[u] is Map) {
            List a = [];
            a.add(i[u]);
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
        break;
      }
      data += " List multi;\n";
      fromVar += "  return super.fromJson(json);\n";
      String multi = """\n\nvoid setMulti(List d) {
    List r = d.map((e) {
      $className m = $className();
      m.fromJson(e);
      return m;
    }).toList();
    multi = r;
  }\n""";
      String toJson =
          " Map<String, dynamic> toJson() {\n final Map<String, dynamic> data = new Map<String, dynamic>();";
      String fromJson = " fromJson(Map<String, dynamic> json) {";
      String headClass = "class $className extends McModel{\n";
      String constractor = " $className({";
      String model = headClass +
          data +
          "\n" +
          constractor +
          "\n" +
          parameters +
          " })" +
          initial +
          "}" +
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
  MyTextField(this.controller,
      {Key key, this.hint, this.help, this.label, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: new InputDecoration(
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
            hintText: hint,
            helperText: help,
            labelText: label,
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
