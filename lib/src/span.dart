import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/gestures.dart';
import './parser.dart';
import './tokens/token.dart';

/// Converts text into TextSpans
///
/// Ignores links
List<TextSpan> textToSpans({required String text, TextStyle? style}) {
  final defaultSetting = style != null
      ? DefaultStyleTokenSettings.fromStyle(style)
      : DefaultStyleTokenSettings();
  final tokens = TextParser.parse(text: text, defaultSetting: defaultSetting);
  List<TextSpan> spans = [];
  TextStyle currentStyle = defaultSetting.style;

  for (final token in tokens) {
    if (token is StyleToken) {
      currentStyle = currentStyle.merge(token.style);
    } else {
      spans.add(TextSpan(text: (token as TextToken).text, style: currentStyle));
    }
  }

  return spans;
}

class ListChangeNotifier<T> extends ChangeNotifier {
  final List<T> _list;
  ListChangeNotifier({required List<T> list})
      : _list = List.from(list, growable: false);

  void update(int elementAt, T val) {
    _list[elementAt] = val;
    notifyListeners();
  }

  List<T> get list => List.unmodifiable(_list);
}

typedef LinkCallback = void Function(String link);

/// Clone of [m.Text.rich] but with added text features
class Text extends StatelessWidget {
  const Text(this.text,
      {super.key,
      this.style,
      this.strutStyle,
      this.textAlign,
      this.textDirection,
      this.locale,
      this.softWrap,
      this.overflow,
      this.textScaler,
      this.maxLines,
      this.semanticsLabel,
      this.textWidthBasis,
      this.textHeightBehavior,
      this.selectionColor,
      this.onLinkTap});

  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final LinkCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final defaultSetting = style != null
        ? DefaultStyleTokenSettings.fromStyle(style!)
        : DefaultStyleTokenSettings();
    final tokens = TextParser.parse(text: text, defaultSetting: defaultSetting);

    int linkCount = 0;
    for (final token in tokens) {
      if (token is LinkToken) {
        if (token.linkEnd) {
          linkCount++;
        }
      }
    }

    // create ListChangeNotifier to listen for link mouse hovers
    List<bool> hovers = [];
    for (int i = 0; i < linkCount; i++) {
      hovers.add(false);
    }
    ListChangeNotifier<bool> hoverNotifier = ListChangeNotifier(list: hovers);

    return ListenableBuilder(
      listenable: hoverNotifier,
      builder: (context, child) {
        List<TextSpan> spans = [];
        TextStyle currentStyle = defaultSetting.style;

        int count = 0;
        int linkPosition = -1;
        String link = "";

        for (final token in tokens) {
          if (token is StyleToken) {
            if (token is LinkToken) {
              if (token.linkEnd) {
                // end of link
                List<TextSpan> subSpans = spans.sublist(linkPosition);
                spans.removeRange(linkPosition, spans.length);

                // add link behavior to the removed Text Spans
                List<TextSpan> newTextSpans = [];
                for (final span in subSpans) {
                  int c = count;
                  String l = link;
                  newTextSpans.add(
                    TextSpan(
                        text: span.text,
                        onEnter: (e) {
                          hoverNotifier.update(c, true);
                        },
                        onExit: (e) {
                          hoverNotifier.update(c, false);
                        },
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            onLinkTap?.call(l);
                          },
                        style: hoverNotifier.list[c]
                            ? span.style!.merge(token.style)
                            : span.style!),
                  );
                }

                spans.addAll(newTextSpans);
                count++;
                link = "";
              } else {
                // link beginning
                linkPosition = spans.length;
                link = token.link;
              }
            } else {
              currentStyle = currentStyle.merge(token.style);
            }
          } else {
            spans.add(
                TextSpan(text: (token as TextToken).text, style: currentStyle));
          }
        }

        return m.Text.rich(
          TextSpan(children: spans),
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaler: textScaler,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor
        );
      },
    );
  }
}
