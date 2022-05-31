import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json2dart/controller/controller.dart';

import 'package:json2dart/generator/generator.dart';
import 'package:json2dart/ui/widgets/link.dart';
import 'package:json2dart/ui/widgets/txtfield.dart';

class MyHomePage extends StatelessWidget {
  final String title;
  MyHomePage({this.title});
  final TextEditingController data = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController result = TextEditingController();

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
                    "Generate MVCRocket model",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    Generator generator = Generator();
                    generator.generate(data.text, name.text, controller: mdl);
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
                  Links("https://pub.dev/packages/mvc_rocket",
                      Icons.library_add, "MVCRocket Package"),
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
