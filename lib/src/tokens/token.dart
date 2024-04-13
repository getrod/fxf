import 'dart:ui'
    show TextDecoration, TextDecorationStyle, FontWeight, TextStyle, FontStyle;

/// A unit that a string is converted to.
///
/// See [TextToken] and [StyleToken]
class Token {}

abstract class StyleToken extends Token {
  /// The symbol that represents the style function
  ///
  /// Ex: The [func]
  String get funcSymbol;

  @override
  String toString() {
    return funcSymbol;
  }
}

class TextToken extends Token {
  TextToken({required this.text});
  final String text;
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
  if (params.length == 1 && params[0] == "d") return defaultValue;
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
    final lineType = int.tryParse(params[0]);
    if (lineType == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: lineType expected int, got $lineType");
    }

    // parse lineStyle
    // if no second parameter, return default
    final lineStyle =
        params.length >= 2 ? int.tryParse(params[1]) : defaultValue.lineStyle;
    if (lineStyle == null) {
      throw Exception(
          "${defaultValue.funcSymbol}: lineStyle expected int, got $lineStyle");
    }

    // parse color
    // if no third parameter, return default
    final color =
        params.length >= 3 ? int.tryParse(params[2]) : defaultValue.color;
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
}

/// ~(color: int)
class ColorToken extends StyleToken {
  /// Creates a color token
  ///
  /// [color] is a hexidecimal between ranges [0x00000000 - 0xffffffff]
  ColorToken({required int color})
      : color = _clip(color, 0x00000000, 0xffffffff);
  
  /// Creates a ColorToken from raw tokens
  factory ColorToken.fromRaw({required List<String> params, required ColorToken defaultValue}) {
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
}

/// `(isOn: int)
class ItalicsToken extends StyleToken {
  /// Creates an ItalicsToken
  ///
  /// [isOn] acts as a boolean (0 false, 1 true) for whether
  /// italics should be activated. Corresponds to [FontStyle.normal]
  /// and [FontStyle.italic]
  ItalicsToken({required int isOn}) : isOn = _clip(isOn, 0, 1);

  factory ItalicsToken.fromRaw({required List<String> params, required ItalicsToken defaultValue}) {
    throw UnimplementedError();
  }

  @override
  String get funcSymbol => "`";

  /// Acts as a boolean (0 false, 1 true) for whether
  /// italics should be activated. Corresponds to [FontStyle.normal]
  /// and [FontStyle.italic]
  final int isOn;
}

/// @(font: str)
class FontToken extends StyleToken {
  /// Creates a FontToken
  ///
  /// [font] corresponds to [TextStyle] fontFamily.
  FontToken({required this.font});
  @override
  String get funcSymbol => "@";

  /// Corresponds to [TextStyle] fontFamily.
  final String font;
}

/// #(link: str, styleChange: int)
class LinkToken extends StyleToken {
  /// Creates a LinkToken
  ///
  /// [link] is a link, typically https
  ///
  /// [styleChange] acts as a boolean (0 false, 1 true) for whether
  /// the text's style should change when user hovers over text.
  LinkToken({required this.link, required int styleChange})
      : styleChange = _clip(styleChange, 0, 1);
  @override
  String get funcSymbol => "#";

  ///  A link, typically https
  final String link;

  /// Acts as a boolean (0 false, 1 true) for whether
  /// the text's style should change when user hovers over text.
  final int styleChange;
}
