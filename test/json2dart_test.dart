// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json2dart/main.dart';
import 'package:json2dart/ui/widgets/txtfield.dart';

import 'data.dart';

const Key inputKey = Key("input");
const Key generateButton = Key("generate");
const Key outputKey = Key("output");
const Key modelNameKey = Key("model_name");

void main() {
  testWidgets('Test Json to Rocket Model Generator',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    // Add Json data
    await tester.enterText(find.byKey(inputKey), json.encode(inputJson));
    // Add model name
    await tester.enterText(find.byKey(modelNameKey), modelName);
    // Click to generate button
    await tester.tap(find.byKey(generateButton));
    // wait 1 sec
    await tester.pump(const Duration(seconds: 1));
    // Get Rocket Model
    final MyTextField outputField =
        tester.widget<MyTextField>(find.byKey(outputKey));
    // Check model name
    expect(outputField.controller.text,
        outputModel.replaceFirst("\n\n  (instance)", ""));
    // Check model name
    expect(outputField.controller.text.contains(resultModelName), isTrue);
    // Check fields is created from keys
    for (var field in inputJson.keys) {
      expect(outputField.controller.text.contains(field), isTrue);
    }
  });

  testWidgets('Test List to Rocket Model Generator',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    // Add List data
    await tester.enterText(find.byKey(inputKey), "[${json.encode(inputJson)}]");
    // Add model name
    await tester.enterText(find.byKey(modelNameKey), modelName);
    // Click to generate button
    await tester.tap(find.byKey(generateButton));
    // wait 1 sec
    await tester.pump(const Duration(seconds: 1));
    // Get Rocket Model
    final MyTextField outputField =
        tester.widget<MyTextField>(find.byKey(outputKey));
    // Check Result
    expect(outputField.controller.text, outputMultiModel);
    // Check model name
    expect(outputField.controller.text.contains(resultModelName), isTrue);
    // Check if instance code added
    expect(outputField.controller.text.contains(instance), isTrue);
    // Check fields is created from keys
    for (var field in inputJson.keys) {
      expect(outputField.controller.text.contains(field), isTrue);
    }
  });
}

//TODO : Add tests for sub-model.
// TODO: Add test for empty list case
