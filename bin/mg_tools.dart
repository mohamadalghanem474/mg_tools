import 'dart:convert';
import 'dart:io';
import 'package:recase/recase.dart';

void main(List<String> arguments) async {
  final directory = Directory.current;
  final forceOverwrite = arguments.contains('--replace');
  final targetFile = arguments.firstWhere(
    (arg) => arg.endsWith('.dto.json'),
    orElse: () => '',
  );

  final files = <File>[];

  if (targetFile.isNotEmpty) {
    await for (var file in directory.list(recursive: true)) {
      if (file is File && file.path.endsWith(targetFile)) {
        files.add(file);
      }
    }
    if (files.isEmpty) {
      print('❌ File not found: $targetFile');
      return;
    }
    if (files.length > 1) {
      print(
          '❌ Multiple files found named: $targetFile. Please specify a single file.');
      return;
    }
  } else {
    await for (var file in directory.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dto.json')) {
        files.add(file);
      }
    }
  }

  for (final file in files) {
    final jsonContent = await file.readAsString();

    final rawDecoded = json.decode(jsonContent);
    late Map<String, dynamic> decoded;
    var isListRoot = false;

    if (rawDecoded is Map<String, dynamic>) {
      decoded = rawDecoded;
    } else if (rawDecoded is List &&
        rawDecoded.isNotEmpty &&
        rawDecoded.first is Map<String, dynamic>) {
      decoded = Map<String, dynamic>.from(rawDecoded.first);
      isListRoot = true;
    } else {
      print('❌ Unsupported JSON structure in file: ${file.path}');
      continue;
    }

    final className = _generateClassName(file.uri.pathSegments.last);
    final outputDir = file.parent.path;
    final nestedModels = StringBuffer();

    final mainModelCode = _generateDartModel(
      className,
      decoded,
      outputDir,
      nestedModels,
      forceOverwrite,
      isListRoot: isListRoot,
    );

    final fullCode = StringBuffer();
    fullCode.writeln('// ignore_for_file: invalid_annotation_target');
    fullCode.writeln();
    fullCode.writeln(
        "import 'package:freezed_annotation/freezed_annotation.dart';");
    fullCode.writeln("import 'dart:convert';");
    fullCode.writeln();
    final fileName = ReCase(className).snakeCase;
    fullCode.writeln("part '$fileName.dto.freezed.dart';");
    fullCode.writeln("part '$fileName.dto.g.dart';");
    fullCode.writeln();
    fullCode.writeln(mainModelCode);
    fullCode.writeln(nestedModels.toString());

    final outputPath = file.path.replaceAll('.dto.json', '.dto.dart');
    final outputFile = File(outputPath);

    if (await _shouldWriteFile(
        outputFile, fullCode.toString(), forceOverwrite)) {
      await outputFile.writeAsString(fullCode.toString());
      print('✅ Generated: ${outputFile.path}');
    } else {
      print('⏭️  Skipped: ${outputFile.path}');
    }
  }

  print('🎉 Done.');
}

String _generateClassName(String fileName) {
  final baseName = fileName.split('/').last.replaceAll('.dto.json', '');
  return ReCase(baseName).pascalCase;
}

Future<bool> _shouldWriteFile(File file, String newContent, bool force) async {
  if (force) return true;
  if (await file.exists()) return false;
  return true;
}

String _generateDartModel(
  String className,
  Map<String, dynamic> jsonMap,
  String outputDir,
  StringBuffer nestedModels,
  bool force, {
  bool isListRoot = false,
}) {
  final camelClass = ReCase(className).camelCase;

  final fields = StringBuffer();

  jsonMap.forEach((key, value) {
    final dartType =
        _getDartType(value, key, outputDir, nestedModels, force, className);
    final variableName = ReCase(key).camelCase;

    // ✅ Special handling for Lists → @Default([])
    if (dartType.startsWith('List<')) {
      fields.writeln(
          '    @Default([]) @JsonKey(name: "$key", includeIfNull: false) $dartType $variableName,');
    } else {
      fields.writeln(
          '    @JsonKey(name: "$key", includeIfNull: false) $dartType? $variableName,');
}
  });

  final buffer = StringBuffer();

  if (isListRoot) {
    buffer.writeln('List<$className> ${camelClass}ListFromJsonString(String str) =>');
    buffer.writeln(
        '    List<$className>.from(json.decode(str).map((x) => $className.fromJson(x)));');
    buffer.writeln();
    buffer.writeln('String ${camelClass}ListToJsonString(List<$className> data) =>');
    buffer.writeln('    json.encode(data.map((x) => x.toJson()).toList());');
    buffer.writeln();
  } else {
    buffer.writeln(
        '$className ${camelClass}FromJsonString(String str) => $className.fromJson(json.decode(str));');
    buffer.writeln();
    buffer.writeln(
        'String ${camelClass}ToJsonString($className data) => json.encode(data.toJson());');
    buffer.writeln();
  }

  buffer.writeln('@freezed');
  buffer.writeln('abstract class $className with _\$$className {');
  buffer.writeln('  const factory $className({');
  buffer.write(fields.toString());
  buffer.writeln('  }) = _$className;');
  buffer.writeln();
  buffer.writeln(
      '  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);');
  buffer.writeln('}');
  buffer.writeln();

  return buffer.toString();
}

String _getDartType(
  dynamic value,
  String key,
  String outputDir,
  StringBuffer nestedModels,
  bool force, [
  String? parentClassName,
]) {
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return 'DateTime';
    return 'String';
  }

  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';

  final parent = parentClassName ?? '';
  final baseKey = ReCase(key).pascalCase;
  final nestedClass = '$parent$baseKey';

  // ✅ List
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>';

    final first = value.first;

    if (first is String) {
      final parsed = DateTime.tryParse(first);
      if (parsed != null) return 'List<DateTime>';
      return 'List<String>';
    }
    if (first is int) return 'List<int>';
    if (first is double) return 'List<double>';
    if (first is bool) return 'List<bool>';

    if (first is Map && first.isNotEmpty) {
      final model = _generateDartModel(
        nestedClass,
        Map<String, dynamic>.from(first),
        outputDir,
        nestedModels,
        force,
      );
      nestedModels.writeln(model);
      return 'List<$nestedClass>';
    }

    return 'List<dynamic>';
  }

  // ✅ Single object
  if (value is Map) {
    if (value.isEmpty) return 'Map<String, dynamic>';

    final model = _generateDartModel(
      nestedClass,
      Map<String, dynamic>.from(value),
      outputDir,
      nestedModels,
      force,
    );
    nestedModels.writeln(model);
    return nestedClass;
  }

  return 'Object';
}
