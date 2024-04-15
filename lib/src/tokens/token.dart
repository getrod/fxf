import 'dart:ui'
    show TextDecoration, TextDecorationStyle, FontWeight, FontStyle, Color;
import 'package:flutter/painting.dart' show TextStyle;

const List<String> kFunctionSymbolNames = ["*", "!", "^", "~", "`", "#", "@"];

/// A unit that a string is converted to.
///
/// See [TextToken] and [StyleToken]
class Token {
  const Token();
}

abstract class StyleToken extends Token {
  const StyleToken();

  /// The symbol that represents the style function
  ///
  /// Ex: The [func]
  String get funcSymbol;

  /// Style token turned into [TextStyle]
  TextStyle get style;

  @override
  String toString() {
    return funcSymbol;
  }
}

class TextToken extends Token {
  TextToken({required this.text});
  final String text;
  @override
  String toString() {
    return text;
  }
}

/// Clips [value] between ranges [begin] - [end]
T _clip<T extends num>(T value, T begin, T end) => value < begin
    ? begin
    : value > end
        ? end
        : value;

/// default raw token checks used for each style token's "fromRaw" factory constructor
T? _defaultRawTokenCheck<T extends StyleToken>(
    {required List<String> params, required T defaultValue}) {
  if (params.isEmpty) {
    throw Exception("${defaultValue.funcSymbol}: params is empty.");
  }
  if (params.length == 1 && params[0].trim() == "d") return defaultValue;
  return null;
}

/// *(weight: int)
class BoldToken extends StyleToken {
  /// Creates a BoldToken
  ///
  /// [weight] corresponds to [FontWeight] and is clipped between [-3-5]
  BoldToken({required int weight}) : weight = _clip(weight, -3, 5);

  /// Creates a BoldToken from raw tokens
  factory BoldToken.fromRaw(
      {required List<String> params, required BoldToken defaultValue}) {
    // if input is only "d", return it
    var token =
        _defaultRawTokenCheck(params: params, defaultValue: defaultValue);
    if (token != null) return token;

    // parse param inputs
    final weight = int.tryParse(params[0]);
    if (weight == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: weight expected int, got $weight");
    }
    return BoldToken(weight: weight);
  }

  @override
  String get funcSymbol => "*";

  /// Font weight. Corresponds to [FontWeight]
  ///
  /// Value range [-3-5]. Get's clipped.
  ///
  /// 0 is [FontWeight.normal]
  /// 5 is [FontWeight.w900]
  /// -3 is [FontWeight.w100]
  final int weight;

  /// The [FontWeight]'s index
  ///
  /// [weight] + 3
  int get weightNormalized => weight + 3;

  @override
  TextStyle get style =>
      TextStyle(fontWeight: FontWeight.values[weightNormalized]);
}

/// !(lineType: int, lineStyle: int, color: int)
class UnderlineToken extends StyleToken {
  /// Creates an UnderlineToken
  ///
  /// [lineType] corresponds to [TextDecoration] and is clipped to range [0-3]
  /// [lineStyle] corresponds to [TextDecorationStyle] and is clipped to range [0-4]
  /// [color] is a hexidecimal and is clipped to range [0x00000000 - 0xffffffff]
  UnderlineToken(
      {required int lineType, required int lineStyle, required int color})
      : lineType = _clip(lineType, 0, 3),
        lineStyle = _clip(lineStyle, 0, 4),
        color = _clip(color, 0x00000000, 0xffffffff);

  /// Creates a UnderlineToken from raw tokens
  ///
  /// If not all the parameters are present, return default values.
  /// ie. !(0,2) would return the default color.
  factory UnderlineToken.fromRaw(
      {required List<String> params, required UnderlineToken defaultValue}) {
    // if input is only "d", return it
    var token =
        _defaultRawTokenCheck(params: params, defaultValue: defaultValue);
    if (token != null) return token;

    // parse lineType
    final lineType = params[0].trim() == "d"
        ? defaultValue.lineType
        : int.tryParse(params[0]);
    if (lineType == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: lineType expected int, got $lineType");
    }

    // parse lineStyle
    // if no second parameter, return default
    var lineStyle = params.length >= 2
        ? params[1].trim() == "d"
            ? defaultValue.lineStyle
            : int.tryParse(params[1])
        : defaultValue.lineStyle;
    if (lineStyle == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: lineStyle expected int, got $lineStyle");
    }

    // parse color
    // if no third parameter, return default
    final color = params.length >= 3
        ? params[2].trim() == "d"
            ? defaultValue.color
            : int.tryParse(params[2])
        : defaultValue.color;
    if (color == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: color expected int, got $color");
    }

    return UnderlineToken(
        lineType: lineType, lineStyle: lineStyle, color: color);
  }

  @override
  String get funcSymbol => "!";

  /// Corresponds to [TextDecoration]. Range is [0-3].
  final int lineType;

  /// Corresponds to [TextDecorationStyle]. Range is [0-4].
  final int lineStyle;

  /// A hexidecimal (ex. 0xff0000ff is blue)
  final int color;

  @override
  TextStyle get style => TextStyle(
        decoration: [
          TextDecoration.none,
          TextDecoration.underline,
          TextDecoration.overline,
          TextDecoration.lineThrough
        ][lineType],
        decorationStyle: TextDecorationStyle.values[lineStyle],
        decorationColor: Color(color),
      );
}

/// ^(size: double)
class SizeToken extends StyleToken {
  /// Creates a SizeToken
  ///
  /// [size] corresponds to [TextStyle].height and is clipped [0-inf]
  SizeToken({required double size}) : size = _clip(size, 0, double.infinity);

  /// Creates a SizeToken from raw tokens
  factory SizeToken.fromRaw(
      {required List<String> params, required SizeToken defaultValue}) {
    // if input is only "d", return it
    var token =
        _defaultRawTokenCheck(params: params, defaultValue: defaultValue);
    if (token != null) return token;

    // parse param inputs
    final size = double.tryParse(params[0]);
    if (size == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: size expected double, got $size");
    }
    return SizeToken(size: size);
  }

  @override
  String get funcSymbol => "^";

  /// Corresponds to [TextStyle].height and is clipped [0-inf]
  final double size;

  @override
  TextStyle get style => TextStyle(fontSize: size);
}

/// ~(color: int)
class ColorToken extends StyleToken {
  /// Creates a color token
  ///
  /// [color] is a hexidecimal between ranges [0x00000000 - 0xffffffff]
  ColorToken({required int color})
      : color = _clip(color, 0x00000000, 0xffffffff);

  /// Creates a ColorToken from raw tokens
  factory ColorToken.fromRaw(
      {required List<String> params, required ColorToken defaultValue}) {
    // if input is only "d", return it
    var token =
        _defaultRawTokenCheck(params: params, defaultValue: defaultValue);
    if (token != null) return token;

    // parse param inputs
    final color = int.tryParse(params[0]);
    if (color == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: color expected int, got $color");
    }
    return ColorToken(color: color);
  }
  @override
  String get funcSymbol => "~";

  /// A hexidecimal (ex. 0xff0000ff is blue)
  final int color;

  @override
  TextStyle get style => TextStyle(color: Color(color));
}

/// `(isOn: int)
class ItalicsToken extends StyleToken {
  /// Creates an ItalicsToken
  ///
  /// [isOn] acts as a boolean (0 false, 1 true) for whether
  /// italics should be activated. Corresponds to [FontStyle.normal]
  /// and [FontStyle.italic]
  ItalicsToken({required int isOn}) : isOn = _clip(isOn, 0, 1);

  /// Creates a ItalicsToken from raw tokens
  factory ItalicsToken.fromRaw(
      {required List<String> params, required ItalicsToken defaultValue}) {
    // if input is only "d", return it
    var token =
        _defaultRawTokenCheck(params: params, defaultValue: defaultValue);
    if (token != null) return token;

    // parse param inputs
    final isOn = int.tryParse(params[0]);
    if (isOn == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: isOn expected int, got $isOn");
    }
    return ItalicsToken(isOn: isOn);
  }

  @override
  String get funcSymbol => "`";

  /// Acts as a boolean (0 false, 1 true) for whether
  /// italics should be activated. Corresponds to [FontStyle.normal]
  /// and [FontStyle.italic]
  final int isOn;

  @override
  TextStyle get style => TextStyle(fontStyle: FontStyle.values[isOn]);
}

/// @(font: str)
class FontToken extends StyleToken {
  /// Creates a FontToken
  ///
  /// [font] corresponds to [TextStyle] fontFamily.
  FontToken({required this.font});

  /// Creates a FontToken from raw tokens
  factory FontToken.fromRaw(
      {required List<String> params, required FontToken defaultValue}) {
    // if input is only "d", return it
    var token =
        _defaultRawTokenCheck(params: params, defaultValue: defaultValue);
    if (token != null) return token;

    final font = params[0];
    return FontToken(font: font);
  }
  @override
  String get funcSymbol => "@";

  /// Corresponds to [TextStyle] fontFamily.
  final String font;

  @override
  TextStyle get style => TextStyle(fontFamily: font);
}

/// #(link: str, styleChange: int, color: int, isUnderline: int)
class LinkToken extends StyleToken {
  /// Creates a LinkToken
  ///
  /// [link] is a link, typically https
  ///
  /// [styleChange] acts as a boolean (0 false, 1 true) for whether
  /// the text's style should change when user hovers over text.
  LinkToken(
      {required this.link,
      required int styleChange,
      required int color,
      required int isUnderline})
      : styleChange = _clip(styleChange, 0, 1),
        color = _clip(color, 0x00000000, 0xffffffff),
        isUnderline = _clip(isUnderline, 0, 1);

  /// Creates a LinkToken from raw tokens
  ///
  /// If not all the parameters are present, return default values.
  factory LinkToken.fromRaw(
      {required List<String> params, required LinkToken defaultValue}) {
    // get link
    final link = params[0];

    // parse styleChange
    // if no second parameter, return default
    final styleChange = params.length >= 2
        ? params[1].trim() == "d"
            ? defaultValue.styleChange
            : int.tryParse(params[1])
        : defaultValue.styleChange;
    if (styleChange == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: styleChange expected int, got $styleChange");
    }

    final color = params.length >= 3
        ? params[2].trim() == "d"
            ? defaultValue.color
            : int.tryParse(params[2])
        : defaultValue.color;
    if (color == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: color expected int, got $color");
    }

    final isUnderline = params.length >= 4
        ? params[3].trim() == "d"
            ? defaultValue.isUnderline
            : int.tryParse(params[3])
        : defaultValue.isUnderline;
    if (isUnderline == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: isUnderline expected int, got $isUnderline");
    }

    return LinkToken(
        link: link,
        styleChange: styleChange,
        color: color,
        isUnderline: isUnderline);
  }

  @override
  String get funcSymbol => "#";

  ///  A link, typically https
  final String link;

  /// Acts as a boolean (0 false, 1 true) for whether
  /// the text's style should change when user hovers over text.
  final int styleChange;

  final int color;

  final int isUnderline;

  @override
  TextStyle get style => TextStyle(
      color: Color(color),
      decoration:
          isUnderline == 1 ? TextDecoration.underline : TextDecoration.none,
      decorationColor: Color(color));

  /// This token is the link's end if link = "d"
  bool get linkEnd => link.trim() == "d";

  @override
  String toString() {
    return "$funcSymbol($link,$styleChange,$color,$isUnderline)";
  }
}

/// A class that holds default values for all style tokens
class DefaultStyleTokenSettings {
  DefaultStyleTokenSettings(
      {int weight = 0,
      int lineType = 0,
      int lineStyle = 0,
      int lineColor = 0xff000000,
      double fontSize = 20,
      int fontColor = 0xff000000,
      int isOn = 0,
      String fontName = "Roboto",
      String linkName = "",
      int linkColor = 0xff0000ff,
      int isUnderline = 1,
      int styleChange = 1}) {
    _bold = BoldToken(weight: weight);
    _underline = UnderlineToken(
        lineType: lineType, lineStyle: lineStyle, color: lineColor);
    _size = SizeToken(size: fontSize);
    _color = ColorToken(color: fontColor);
    _italics = ItalicsToken(isOn: isOn);
    _font = FontToken(font: fontName);
    _link = LinkToken(
        link: linkName,
        styleChange: styleChange,
        color: linkColor,
        isUnderline: isUnderline);
  }

  // TODO: untested
  factory DefaultStyleTokenSettings.fromStyle(TextStyle style) {
    final d = DefaultStyleTokenSettings();
    int weight = style.fontWeight != null
        ? FontWeight.values.indexOf(style.fontWeight!) - 3
        : d.bold.weight;
    final decorations = [
      TextDecoration.none,
      TextDecoration.underline,
      TextDecoration.overline,
      TextDecoration.lineThrough
    ];
    int lineType = style.decoration != null
        ? decorations.indexOf(style.decoration!)
        : d.underline.lineType;
    int lineStyle = style.decorationStyle != null
        ? TextDecorationStyle.values.indexOf(style.decorationStyle!)
        : d.underline.lineStyle;
    int lineColor = style.decorationColor != null
        ? style.decorationColor!.value
        : d.underline.color;
    double fontSize = style.fontSize ?? d.size.size;
    int fontColor = style.color?.value ?? d.color.color;
    int isOn = style.fontStyle != null
        ? FontStyle.values.indexOf(style.fontStyle!)
        : d.italics.isOn;
    String fontName = style.fontFamily ?? d.font.font;

    return DefaultStyleTokenSettings(
        weight: weight,
        lineType: lineType,
        lineStyle: lineStyle,
        lineColor: lineColor,
        fontSize: fontSize,
        fontColor: fontColor,
        isOn: isOn,
        fontName: fontName);
  }

  BoldToken get bold => _bold;
  UnderlineToken get underline => _underline;
  SizeToken get size => _size;
  ColorToken get color => _color;
  ItalicsToken get italics => _italics;
  FontToken get font => _font;
  LinkToken get link => _link;

  TextStyle get style => TextStyle(
      fontWeight: FontWeight.values[bold.weightNormalized],
      decoration: [
        TextDecoration.none,
        TextDecoration.underline,
        TextDecoration.overline,
        TextDecoration.lineThrough
      ][underline.lineType],
      decorationStyle: TextDecorationStyle.values[underline.lineStyle],
      decorationColor: Color(underline.color),
      fontSize: size.size,
      color: Color(color.color),
      fontStyle: FontStyle.values[italics.isOn],
      fontFamily: font.font);

  late final BoldToken _bold;
  late final UnderlineToken _underline;
  late final SizeToken _size;
  late final ColorToken _color;
  late final ItalicsToken _italics;
  late final FontToken _font;
  late final LinkToken _link;
}
