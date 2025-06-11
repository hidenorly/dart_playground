/*
  Copyright (C) 2025 hidenorly

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import 'dart:io';
import 'package:args/args.dart';

// help
void printUsage(ArgParser parser) {
  print('Usage: dart arg_parser arg1 arg2... [-p password]');
  print(parser.usage);
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('password', abbr: 'p', help: 'Password')
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

  print('Parsed arguments:');
  int i = 0;
  for (var arg in argResults.rest) {
    print("args[${i}]=${arg}");
  }

  for (final key in argResults.options) {
    final value = argResults[key];
    print('${key}=${value}');
  }
}