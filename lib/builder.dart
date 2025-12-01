// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:analyzer/dart/element/type.dart';
import 'package:gemini_agent_tools/tool_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';

Builder toolGenerator(BuilderOptions options) =>
    PartBuilder([ToolGenerator()], '.tools.g.dart');

class ToolGenerator extends GeneratorForAnnotation<Tool> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final classElement = element as ClassElement2;

    final name = annotation.read('name').stringValue;
    final description = annotation.read('description').stringValue;
    final fields = classElement.fields2.where((f) => !f.isStatic);

    final properties = fields
        .map((f) {
          final fieldName = f.name3;
          if (fieldName == null) {
            throw Exception("Error: Found a field with a null name");
          }

          final snake = _camelToSnake(fieldName);
          return '"$snake": {"type": "${_type(f.type, fieldName)}"}';
        })
        .join(',');

    final propertyOrdering =
        annotation
            .peek('propertyOrdering')
            ?.listValue
            .map((v) => '"${v.toStringValue()}"')
            .join(',') ??
        fields
            .map((f) {
              final fieldName = f.name3;
              if (fieldName == null) {
                throw Exception("Error: Found a field with a null name");
              }
              return '"${_camelToSnake(fieldName)}"';
            })
            .join(',');

    final requiredFields =
        annotation
            .peek('requiredFields')
            ?.listValue
            .map((v) => '"${_camelToSnake(v.toStringValue()!)}"')
            .join(',') ??
        "";

    final requiredBlock = requiredFields.isEmpty
        ? ""
        : ',"required": [$requiredFields]';

    return '''const Map ${name}ToolAsMap =
      {
        "name": "$name",
        "description": ${_escape(description)},
        "parameters": {
          "type": "object",
          "properties": { $properties },
          "propertyOrdering": [ $propertyOrdering ]$requiredBlock
        }
      };
      ''';
  }

  // ----- utilities -----

  String _camelToSnake(String input) => input.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (m) => "_${m.group(0)!.toLowerCase()}",
  );

  String _escape(String text) {
    final escaped = text.replaceAll('\n', '\\n').replaceAll('"', '\\"');
    return '"$escaped"';
  }

  String _type(DartType type, String name) {
    if (type.isDartCoreString) {
      return "string";
    } else if (type.isDartCoreInt) {
      return "integer";
    } else if (type.isDartCoreBool) {
      return "boolean";
    } else {
      throw Exception(
        "Invalid type for $name. Expected one of String, int or bool",
      );
    }
  }
}
