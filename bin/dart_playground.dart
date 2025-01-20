import 'dart:io';
import 'package:args/args.dart';

// help
void printUsage(ArgParser parser) {
  print('Usage: dart cli_tool.dart [options]');
  print(parser.usage);
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('name', abbr: 'n', help: 'Your name')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    printUsage(parser);
    exit(-1); // report error status
  }

  // show help
  if (argResults['help'] == true) {
    printUsage(parser);
    return;
  }

  // 名前が指定されている場合
  final name = argResults['name'];
  if (name != null) {
    print('Hello, $name!');
  } else {
    print('Hello, world!');
  }
}

