import 'dart:async';

import 'package:gemini_agent_tools/tool_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/build_step.dart';
import 'package:build/build.dart';

Builder toolGenerator(BuilderOptions options) =>
    PartBuilder([ToolGenerator()], '.tools.g.dart');

class ToolGenerator extends GeneratorForAnnotation<Tool> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    print("Tool generator running");
    final classElement = element as ClassElement;

    final name = annotation.read('name').stringValue;
    final description = annotation.read('description').stringValue;

    // If overrideParameters exists, use it entirely.
    // final overrideParams = annotation.peek('overrideParameters')?.mapValue;
    // if (overrideParams != null) {
    //   final overrideJson = _dartMapToJson(overrideParams);
    //   return '''
    //     {
    //       "name": "$name",
    //       "description": ${_escape(description)},
    //       "parameters": $overrideJson
    //     }
    //     ''';
    // }

    // else generate from class fields
    final fields = classElement.fields.where((f) => !f.isStatic);

    final properties = fields
        .map((f) {
          final snake = _camelToSnake(f.name ?? "EMPTYNAME");
          return '"$snake": {"type": "string"}';
        })
        .join(',');

    final propertyOrdering =
        annotation
            .peek('propertyOrdering')
            ?.listValue
            .map((v) => '"${v.toStringValue()}"')
            .join(',') ??
        fields
            .map((f) => '"${_camelToSnake(f.name ?? "EMPTYNAME")}"')
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

  // String _dartMapToJson(Map<Object?, Object?> map) {
  //   final buffer = StringBuffer('{');
  //   map.forEach((key, value) {
  //     buffer.write('"$key": ${_jsonValue(value)},');
  //   });
  //   if (buffer.length > 1) buffer.length--;
  //   buffer.write('}');
  //   return buffer.toString();
  // }

  // String _jsonValue(Object? value) {
  //   if (value == null) return 'null';
  //   if (value is String) return '"$value"';
  //   if (value is num || value is bool) return '$value';
  //   if (value is List) {
  //     return '[${value.map(_jsonValue).join(',')}]';
  //   }
  //   if (value is Map) return _dartMapToJson(value);
  //   return '"$value"';
  // }
}
