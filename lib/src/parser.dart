import './tokens/token.dart';

/// Converts a [String] into a list of text and style [Token]s.
class TextParser {
  /// Convert [text] into [Token]s.
  static List<Token> parse(
      {required String text,
      DefaultStyleTokenSettings? defaultSetting}) {
    final defaultTokens = defaultSetting ?? DefaultStyleTokenSettings();
    // get raw tokens
    List<Map<String, dynamic>> rawTokens = parseRichText(text);
    List<Token> tokens = [];

    // convert raw tokens into Tokens
    for (final rawToken in rawTokens) {
      if (rawToken["type"] == "text") {
        tokens.add(TextToken(text: rawToken["text"]));
      } else {
        final String funcSymbol = rawToken["func"];
        final List<String> params = rawToken["params"];
        StyleToken token;
        switch (funcSymbol) {
          case "*":
            token = BoldToken.fromRaw(
                params: params, defaultValue: defaultTokens.bold);
            tokens.add(token);
            break;
          case "!":
            token = UnderlineToken.fromRaw(
                params: params, defaultValue: defaultTokens.underline);
            tokens.add(token);
            break;
          case "^":
            token = SizeToken.fromRaw(
                params: params, defaultValue: defaultTokens.size);
            tokens.add(token);
            break;
          case "~":
            token = ColorToken.fromRaw(
                params: params, defaultValue: defaultTokens.color);
            tokens.add(token);
            break;
          case "`":
            token = ItalicsToken.fromRaw(
                params: params, defaultValue: defaultTokens.italics);
            tokens.add(token);
            break;
          case "#":
            token = LinkToken.fromRaw(
                params: params, defaultValue: defaultTokens.link);
            tokens.add(token);
            break;
          case "@":
            token = FontToken.fromRaw(
                params: params, defaultValue: defaultTokens.font);
            tokens.add(token);
        }
      }
    }

    return tokens;
  }

  /// Parse [plainText] into raw text and style tokens
  ///
  /// Output is an array of json-like text & style tokens.
  ///
  /// Example string:
  /// ```json
  /// "!(0,d,0xff00ff00)Example text!!"
  /// ```
  ///
  /// json text token format:
  /// ```json
  /// {
  ///   "type": "text",
  ///   "text": "Example text!!"
  /// }
  /// ```
  ///
  /// json style token format:
  /// ```json
  /// {
  ///   "type": "style",
  ///   "func": "!",
  ///   "params": ["0", "d", "0xff00ff00"]
  /// }
  /// ```
  static List<Map<String, dynamic>> parseRichText(String plainText) {
    int state = 0;
    String res = "";
    String func = "";
    List<String> functionNames = kFunctionSymbolNames;
    List<Map<String, dynamic>> tokenStream = [];
    String newPlainText = "";

    // new line is no space, while two newlines is one newline
    int newLineState = 0;
    plainText.split("").forEach((ch) {
      if (newLineState == 0) {
        if (ch == "\n") {
          // skip it
          newLineState = 1;
        } else {
          newPlainText += ch;
        }
      } else if (newLineState == 1) {
        if (ch == "\n") {
          // two new lines, replaced with one \n
          newPlainText += "\n";
          newLineState = 0;
        } else {
          newPlainText += ch;
          newLineState = 0;
        }
      }
    });

    // parse plain text into text and style tokens
    newPlainText.split('').forEach((ch) {
      if (state == 0) {
        // "Init" State
        if (functionNames.join().contains(ch)) {
          res += ch;
          state = 1; // go to "Is Style Token" State
        } else {
          res += ch;
        }
      } else if (state == 1) {
        // "Is Style Token" State
        if (ch == "(") {
          // remove last char from res and save it in func
          func = res.substring(res.length - 1, res.length);
          res = res.substring(0, res.length - 1);

          // Create text token
          tokenStream.add({"type": "text", "text": res});

          res = "";
          state = 2; // go to Get Params state
        } else if (functionNames.join().contains(ch)) {
          // if function name appears again, save to res and check again
          res += ch;
        } else {
          // false alarm. go back to init state
          res += ch;
          state = 0; // Go to Init State
        }
      } else if (state == 2) {
        // "Get Param" State
        if (ch == ")") {
          // split params
          var params = res.split(",");

          // Create style token
          tokenStream.add({"type": "style", "func": func, "params": params});

          // reset res and func
          res = "";
          func = "";
          state = 0;
        } else {
          res += ch;
        }
      }
    });
    // add last token
    tokenStream.add({"type": "text", "text": res});

    return tokenStream;
  }
}
