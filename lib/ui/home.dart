import 'package:dart_code_viewer2/dart_code_viewer2.dart';
import 'package:flutter/material.dart';
import 'package:json2dart/controller/controller.dart';
import 'package:json2dart/ui/widgets/link.dart';
import 'package:json2dart/ui/widgets/txtfield.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  MyHomePage({required this.title});
  final TextEditingController data = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController result = TextEditingController();
  final GeneratorController gen = GeneratorController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          InkWell(
            onTap: () => gen.clearAll(),
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
                key: Key("input"),
              ),
              MyTextField(
                name,
                hint: 'Here your Model name',
                help: 'Default name MyModel',
                label: 'Model name',
                icon: Icons.title,
                key: Key("model_name"),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.08,
                child: TextButton(
                  key: Key("generate"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.brown)),
                  child: Text(
                    "Generate MVCRocket model",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    gen.generate(data.text, name.text);
                  },
                ),
              ),
              AnimatedBuilder(
                builder: (BuildContext context, Widget? _) {
                  return gen.loading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.brown),
                          ),
                        )
                      : Wrap(
                          children: gen.controller.models.reversed
                              .map(
                                (e) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DartCodeViewer(
                                      e.result,
                                      key: Key("output"),
                                      copyButtonText:
                                          Text("Copy ${e.name} Model"),
                                      backgroundColor: Colors.white,
                                    )),
                              )
                              .toList(),
                        );
                },
                animation: gen,
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  Links("https://pub.dev/packages/flutter_rocket",
                      Icons.library_add, "Flutter Rocket Package"),
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
}
