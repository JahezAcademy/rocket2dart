import 'package:json2dart/utils/template.dart';

class ModelItems {
  String fieldsLines = "";
  String constFields = "";
  String fromJsonFields = "";
  String toJsonFields = "";
  String instance = "";
  String className = "";
  String get result{
     return template.replaceFirst("-fields-", fieldsLines)
        .replaceFirst("-fieldsConstructor-", constFields)
        .replaceFirst("-fromJsonFields-", fromJsonFields)
        .replaceFirst("-toJsonFields-", toJsonFields)
        .replaceAll("-name-", className)
        .replaceFirst("-instance-", instance);
  }
}