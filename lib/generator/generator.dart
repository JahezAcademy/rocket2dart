import 'dart:convert';
import 'dart:developer';
import 'package:dart_style/dart_style.dart';
import 'package:flutter/material.dart';
import 'package:json2dart/controller/controller.dart';
import 'package:json2dart/model/model.dart';
import 'package:json2dart/utils/template.dart';
import 'package:json2dart/utils/extensions.dart';

class Generator {
  String copyTemplate;
  void generate(String inputUser, String className,
      {bool multi = false, ModelsController controller}) {
    copyTemplate = template;
    className = className.isEmpty ? "MyModel" : className.firstUpper;
    inputUser = inputUser.isEmpty ? '{"mcPackage":"mc"}' : inputUser;
    var jsonInputUser = json.decode(inputUser.trim());
    if (jsonInputUser is List) {
      generate(json.encode(jsonInputUser.first), className,
          multi: true, controller: controller);
    } else if (jsonInputUser is Map) {
      generateFields(jsonInputUser, className,
          multi: multi, controller: controller);
    } else {
      log("Unsupported type");
    }
  }

  final String jsonMapType = "_JsonMap";
  void generateFields(Map<String, dynamic> fields, String className,
      {bool multi = false, ModelsController controller}) {
    ModelItems model = ModelItems();
    fields.forEach((key, value) {
      String fieldType = value.runtimeType.toString();
      String line;
      String fromJson;
      String toJson;
      bool isPrimitive =
          value is String || value is int || value is double || value is bool;
      if (isPrimitive) {
        line = "$fieldType? ${key.camel};";
        fromJson = "${key.camel} = json['$key'] ?? ${key.camel};";
        toJson = "data['$key'] = ${key.camel};";
      } else if (value is List) {
        bool isPrimitive = value.first is String ||
            value is int ||
            value is double ||
            value is bool;
        if (isPrimitive) {
          line = "$fieldType? ${key.camel};";
          fromJson = "${key.camel} = json['$key'] ?? ${key.camel};";
          toJson = "data['$key'] = ${key.camel};";
        } else {
          line = "${key.firstUpper} $key = ${key.firstUpper}();";
          fromJson = "${key.camel}.setMulti(json['$key'],isSub:isSub);";
          toJson =
              "data['$key'] = ${key.camel}.multi.map((e)=> e.toJson()).toList();";
          Generator reGenerate = new Generator();
          reGenerate.generate(json.encode(value), key.firstUpper,
              multi: true, controller: controller);
        }
      } else if (value.runtimeType.toString() == jsonMapType) {
        line = "${key.firstUpper} $key = ${key.firstUpper}();";
        fromJson = "${key.camel}.fromJson(json['$key']);";
        toJson = "data['$key'] = ${key.camel}.toJson();";
        Generator reGenerate = new Generator();
        reGenerate.generate(json.encode(value), key.firstUpper,
            controller: controller);
      } else {
        log("Unsupported type");
      }
      model.constFields += "this.${key.camel},";
      model.fieldsLines += line;
      model.fromJsonFields += fromJson;
      model.toJsonFields += toJson;
      if (multi) {
        model.instance = "@override get instance => $className();";
      }
    });
    model.className = className;
    String result = DartFormatter().format(model.result);
    TextEditingController text = TextEditingController();
    // just for re-pull request
    text.text = result;
    controller.addModel(text, className);
  }
}
