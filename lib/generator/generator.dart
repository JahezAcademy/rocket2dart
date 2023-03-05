import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:flutter/material.dart';
import 'package:json2dart/controller/controller.dart';
import 'package:json2dart/model/model.dart';
import 'package:json2dart/utils/extensions.dart';
import 'package:json2dart/utils/template.dart';

class Generator {
  String copyTemplate;
  void generate(String inputUser, String className,
      {bool multi = false, ModelsController controller}) {
    copyTemplate = template;
    className = className.isEmpty ? "MyModel" : className.firstUpper;
    inputUser =
        inputUser.isEmpty ? '{"MVCRocket Package":"MvcRocket"}' : inputUser;
    var jsonInputUser = json.decode(inputUser.trim());
    if (jsonInputUser is List) {
      generate(json.encode(jsonInputUser.first), className,
          multi: true, controller: controller);
    } else if (jsonInputUser is Map) {
      generateFields(jsonInputUser, className,
          multi: multi, controller: controller);
    } else {
      print("Unsupported type");
    }
  }

  void generateFields(Map<String, dynamic> fields, String className,
      {bool multi = false, ModelsController controller}) {
    ModelItems modelItems = ModelItems();
    fields.forEach((key, value) {
      String fieldType = _solveDouble(value);
      String line;
      String fromJson, toJson;
      String initFields = "";
      String fieldsKey, updateFieldsParams, updateFieldsBody;
      final String fieldKeyMap =
          "${className.toLowerCase()}${key.camel.firstUpper}Field";
      final String fieldLine =
          'const String ${className.toLowerCase()}${key.camel.firstUpper}Field = "$key";';
      final String updateFieldParamLine = "$fieldType? ${key.camel}Field,";
      final String updateFieldBodyLine =
          "${key.camel} = ${key.camel}Field ?? ${key.camel};";
      bool isPrimitive = (value as Object).isPrimitive;
      if (isPrimitive) {
        line = "$fieldType? ${key.camel};";
        fromJson = "${key.camel} = json[$fieldKeyMap];";
        toJson = "data[$fieldKeyMap] = ${key.camel};";
        fieldsKey = fieldLine;
        updateFieldsParams = updateFieldParamLine;
        updateFieldsBody = updateFieldBodyLine;
      } else if (value is List) {
        bool isNotEmpty = value.isNotEmpty;
        bool isPrimitive = false;
        if (isNotEmpty) isPrimitive = (value.first as Object).isPrimitive;
        if (!isNotEmpty || isPrimitive) {
          final String fieldSubType =
              isNotEmpty ? _solveDouble(value.first) : "dynamic";
          line = "List<$fieldSubType>? ${key.camel};";
          fromJson = "${key.camel} = json[$fieldKeyMap];";
          toJson = "data[$fieldKeyMap] = ${key.camel};";
          fieldsKey = fieldLine;
          updateFieldsParams = "List<$fieldSubType>? ${key.camel}Field,";
          updateFieldsBody = updateFieldBodyLine;
        } else {
          line = "${key.firstUpper}? $key;";
          fromJson = "${key.camel}!.setMulti(json['$key']);";
          toJson =
              "data[$fieldKeyMap] = ${key.camel}!.multi.map((e)=> e.toJson()).toList();";
          fieldsKey = fieldLine;
          updateFieldsParams = "${key.firstUpper}? ${key.camel}Field,";
          updateFieldsBody = updateFieldBodyLine;
          initFields = "$key??=${key.firstUpper}();";

          Generator reGenerate = Generator();
          reGenerate.generate(json.encode(value), key.firstUpper,
              multi: true, controller: controller);
        }
      } else if (value is Map) {
        line = "${key.firstUpper}? $key;";
        fromJson = "${key.camel}!.fromJson(json[$fieldKeyMap]);";
        toJson = "data[$fieldKeyMap] = ${key.camel}!.toJson();";
        fieldsKey = fieldLine;
        updateFieldsParams = "${key.firstUpper}? ${key.camel}Field,";
        updateFieldsBody = updateFieldBodyLine;
        initFields = "$key??=${key.firstUpper}();";

        Generator reGenerate = Generator();
        reGenerate.generate(json.encode(value), key.firstUpper,
            controller: controller);
      } else {
        print("Unsupported type");
      }
      modelItems.constFields += "this.${key.camel},";
      modelItems.fieldsLines += line;
      modelItems.fromJsonFields += fromJson;
      modelItems.toJsonFields += toJson;
      modelItems.fieldsKey += fieldsKey;
      modelItems.updateFieldsParams += updateFieldsParams;
      modelItems.updateFieldsBody += updateFieldsBody;
      modelItems.initFields += initFields;
      if (multi) {
        modelItems.instance = "@override get instance => $className();";
      }
    });
    modelItems.className = className;
    String result = DartFormatter().format(modelItems.result);
    TextEditingController text = TextEditingController(text: result);
    controller.addModel(text, className);
  }

  String _solveDouble(dynamic field) {
    if (field is int) {
      if (field.isDouble) {
        return "double";
      }
    }
    return field.runtimeType.toString();
  }
}
