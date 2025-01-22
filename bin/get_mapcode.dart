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


import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> getMapcode(double latitude, double longitude) async {
  final data = {
    "t": "jpndeg",
    "jpn_lat": latitude.toString(),
    "jpn_lon": longitude.toString(),
  };

  // POST request
  final response = await http.post(
    Uri.parse("https://saibara.sakura.ne.jp/map/convgeo.cgi"),
    body: data,
  );

  if (response.statusCode == 200) {
    // Extract map code from the response
    final responseBody = response.body;
    final mapcodeStartIndex = responseBody.indexOf('name="mapcode" value="') + 22;
    final mapcodeEndIndex = responseBody.indexOf('"', mapcodeStartIndex);

    if (mapcodeStartIndex > 22 && mapcodeEndIndex > mapcodeStartIndex) {
      return responseBody.substring(mapcodeStartIndex, mapcodeEndIndex);
    } else {
      throw Exception("Failed to extract mapcode from response.");
    }
  } else {
    throw Exception("Failed to fetch mapcode: ${response.statusCode}");
  }
}

void main(List<String> arguments) async {
  if (arguments.length != 2) {
    print("Usage: dart get_mapcode.dart <latitude> <longitude>");
    exit(1);
  }

  try {
    final latitude = double.parse(arguments[0]);
    final longitude = double.parse(arguments[1]);

    final mapcode = await getMapcode(latitude, longitude);
    print("Mapcode: $mapcode");
  } catch (e) {
    print("Error: $e");
    exit(1);
  }
}
