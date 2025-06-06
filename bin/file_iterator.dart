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
import 'package:path/path.dart' as p;

Stream<FileSystemEntity> listEntities(Directory directory) async* {
  try {
    await for (final entity in directory.list()) {
      yield entity;
    }
  } catch (e) {
    print('Error listing directory ${directory.path}: $e');
  }
}

Future<void> findFilesRecursively(String targetPath, void Function(File file) onFileFound) async {
  final directory = Directory(targetPath);

  if (await directory.exists()) {
    await for (final entity in listEntities(directory)) {
      if (entity is File) {
        onFileFound(entity);
      } else if (entity is Directory) {
        await findFilesRecursively(entity.path, onFileFound);
      }
    }
  } else {
    print('not found: ${targetPath}');
  }
}

void main(List<String> arguments) async {
  List<String> files = [];

  for (final path in arguments) {
    final dir = Directory(path);
    final isDir = await dir.exists();
    if( isDir ){
      await findFilesRecursively(path, (File file) {
        files.add(file.path);
      });
    } else {
      files.add(path);
    }
  }

  for(final path in files){
    print(path);
  }
}