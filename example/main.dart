import 'package:flutter/material.dart';
import 'package:fxf/fxf.dart' as fxf;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String text = '''
Hello *(5)Best Western*(0), this is a #(google.com,d,0xff00ff00,0)link#(d).

This is me changing the ^(70)Font Size & ~(0xff00ffff)Color~(d)^(d).

I will !(1,0,0xffff0000)underline!(d) this! 
And time to get `(1)slanted`(d).

#(test.html, d)Link 2#(d)

Time to change this with a change of @(Dancing Script)^(50)heart^(d)@(d). And done.
''';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: fxf.Text(
        text,
        onLinkTap: (link) {
          print(link);
        },
      ),
    );
  }
}
