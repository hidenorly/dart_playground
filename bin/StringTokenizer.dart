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


class StringTokenizer {
  final String str;
  final String token;
  List<String> results = [];
  int index = 0;

  StringTokenizer(this.str, this.token){
    if( this.token.isNotEmpty ){
      this.results = this.str.split(this.token);
      } else {
        this.results = [this.str];
      }
  }

  bool hasNext(){
    return index < results.length;
  }

  String? getNext(){
    if( hasNext() ){
      return results[index++];
    }
    return null;
  }
}


void main() {
  final String text = "1,22,333,4444,5,,7";
  StringTokenizer tok = StringTokenizer(text, ",");
  int i = 0;
  while(tok.hasNext()){
    print('index=${i++} token result=${tok.getNext()}');
  }

  StringTokenizer tok2 = StringTokenizer(text, "");
  i = 0;
  while(tok2.hasNext()){
    print('index=${i++} token result=${tok2.getNext()}');
  }

  StringTokenizer tok3 = StringTokenizer(text, "*");
  i = 0;
  while(tok3.hasNext()){
    print('index=${i++} token result=${tok3.getNext()}');
  }
  print("over-call:${tok3.getNext()}");
}
