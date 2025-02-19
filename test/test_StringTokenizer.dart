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

import 'package:test/test.dart';
import '../bin/StringTokenizer.dart';


void main()
{
  final String text = "1,22,333,4444,5,,7";

  test('Construct', () {
    StringTokenizer tok = StringTokenizer(text, ",");
  });

  test('Construct with , & hasNext', () {
    StringTokenizer tok = StringTokenizer(text, ",");

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals("1"));

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals("22"));

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals("333"));

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals("4444"));

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals("5"));

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals(""));

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals("7"));

    expect(tok.hasNext(), equals(false));
  });


  test('Construct with "" & hasNext', () {
    StringTokenizer tok = StringTokenizer(text, "");

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals(text));

    expect(tok.hasNext(), equals(false));
  });


  test('Construct with * & hasNext', () {
    StringTokenizer tok = StringTokenizer(text, "*");

    expect(tok.hasNext(), equals(true));
    expect(tok.getNext(), equals(text));

    expect(tok.hasNext(), equals(false));
  });
}