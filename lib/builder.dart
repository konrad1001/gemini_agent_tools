import 'dart:async';

import 'package:gemini_agent_tools/tool_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
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
    final classElement = element as ClassElement;

    final name = annotation.read('name').stringValue;
    final description = annotation.read('description').stringValue;
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
}
