import 'package:flutter_test/flutter_test.dart';

import 'package:fxf/src/parser.dart';

void main() {
  test('parse all tokens', () {
    const text = '''
Text*(5)*(d)#(google.com)#(d)
^(70)~(0xff00ffff)~(d)^(d)
!(1,0,0xffff0000)!(d,d,d)!(1,d)
`(1)`(d)
@(Dancing Script)@(d)
''';
    TextParser.parse(text: text);
  });
}
