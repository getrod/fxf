import 'package:flutter_test/flutter_test.dart';

import 'package:fxf/src/tokens/token.dart';

void main() {
  group('Bold', () {
    test('weight gets clipped between ranges [-3-5]', () {
      var boldToken = BoldToken(weight: -4);
      expect(boldToken.weight, -3);
      boldToken = BoldToken(weight: 6);
      expect(boldToken.weight, 5);
    });

    group('fromRaw', () {
      test('param "d" returns defaultValue', () {
        var boldToken = BoldToken.fromRaw(
            params: ["d"], defaultValue: BoldToken(weight: 0));
        expect(boldToken.weight, 0);
      });
      test('param parses weight value correctly', () {
        var boldToken = BoldToken.fromRaw(
            params: ["3"], defaultValue: BoldToken(weight: 0));
        expect(boldToken.weight, 3);
      });

      test('throws error when weight is incorrect input', () {
        expect(
            () => BoldToken.fromRaw(
                params: ["0.2"], defaultValue: BoldToken(weight: 0)),
            throwsA(isA<Exception>()));
      });
    });
  });

  group('Underline', () {
    test('lineType gets clipped between ranges [0-3]', () {
      var underlineToken =
          UnderlineToken(lineType: -1, lineStyle: 0, color: 0x00000000);
      expect(underlineToken.lineType, 0);
      underlineToken =
          UnderlineToken(lineType: 4, lineStyle: 0, color: 0x00000000);
      expect(underlineToken.lineType, 3);
    });

    test('lineStyle gets clipped between ranges [0-4]', () {
      var underlineToken =
          UnderlineToken(lineType: 0, lineStyle: -1, color: 0x00000000);
      expect(underlineToken.lineStyle, 0);
      underlineToken =
          UnderlineToken(lineType: 0, lineStyle: 5, color: 0x00000000);
      expect(underlineToken.lineStyle, 4);
    });

    test('color gets clipped between ranges [0x00000000-0xffffffff]', () {
      var underlineToken =
          UnderlineToken(lineType: 0, lineStyle: 0, color: 0x00000000 - 1);
      expect(underlineToken.color, 0x00000000);
      underlineToken =
          UnderlineToken(lineType: 0, lineStyle: 0, color: 0xffffffff + 1);
      expect(underlineToken.color, 0xffffffff);
    });

    group('fromRaw', () {
      test('all params are parsed correctly', () {
        var underlineToken = UnderlineToken.fromRaw(
            params: ["1", "2", "0xff000000"],
            defaultValue: UnderlineToken(lineType: 0, lineStyle: 0, color: 0));
        expect(underlineToken.lineType, 1);
        expect(underlineToken.lineStyle, 2);
        expect(underlineToken.color, 0xff000000);
      });

      test('param "d" returns default value', () {
        var defaultToken =
            UnderlineToken(lineType: 0, lineStyle: 0, color: 0xff000000);

        var underlineToken =
            UnderlineToken.fromRaw(params: ["d"], defaultValue: defaultToken);
        expect(underlineToken.lineType, defaultToken.lineType);
        expect(underlineToken.lineStyle, defaultToken.lineStyle);
        expect(underlineToken.color, defaultToken.color);

        underlineToken = UnderlineToken.fromRaw(
            params: ["1", "d", "d"], defaultValue: defaultToken);
        expect(underlineToken.lineStyle, defaultToken.lineStyle);
        expect(underlineToken.color, defaultToken.color);

        underlineToken = UnderlineToken.fromRaw(
            params: ["d", "d", "d"], defaultValue: defaultToken);
        expect(underlineToken.lineType, defaultToken.lineType);
        expect(underlineToken.lineStyle, defaultToken.lineStyle);
        expect(underlineToken.color, defaultToken.color);
      });

      test('missing param inputs returns default values', () {
        var defaultToken =
            UnderlineToken(lineType: 0, lineStyle: 0, color: 0xff000000);

        var underlineToken =
            UnderlineToken.fromRaw(params: ["1"], defaultValue: defaultToken);

        expect(underlineToken.lineStyle, defaultToken.lineStyle);
        expect(underlineToken.color, defaultToken.color);

        underlineToken = UnderlineToken.fromRaw(
            params: ["1", "2"], defaultValue: defaultToken);
        expect(underlineToken.color, defaultToken.color);
      });

      test('throws error on incorrect input', () {
        var defaultToken =
            UnderlineToken(lineType: 0, lineStyle: 0, color: 0xff000000);

        expect(
            () =>
                UnderlineToken.fromRaw(params: [], defaultValue: defaultToken),
            throwsA(isA<Exception>()));
        expect(
            () => UnderlineToken.fromRaw(
                params: ["0.2"], defaultValue: defaultToken),
            throwsA(isA<Exception>()));
        expect(
            () => UnderlineToken.fromRaw(
                params: ["1", "2.3"], defaultValue: defaultToken),
            throwsA(isA<Exception>()));
        expect(
            () => UnderlineToken.fromRaw(
                params: ["1", "2", "3.3"], defaultValue: defaultToken),
            throwsA(isA<Exception>()));
      });
    });
  });

  group('Size', () {
    test('size gets clipped between ranges [0-inf]', () {
      var sizeToken = SizeToken(size: -1);
      expect(sizeToken.size, 0);
    });

    group('fromRaw', () {
      test('parses input correctly', () {
        final defaultToken = SizeToken(size: 4.35);
        final token =
            SizeToken.fromRaw(params: ["2.3"], defaultValue: defaultToken);
        expect(token.size, 2.3);
      });
      test('returns default token on input "d"', () {
        final defaultToken = SizeToken(size: 4.35);
        final token =
            SizeToken.fromRaw(params: ["d"], defaultValue: defaultToken);
        expect(token.size, defaultToken.size);
      });
      test('throws error on invalid input', () {
        final defaultToken = SizeToken(size: 4.35);
        expect(
            () => SizeToken.fromRaw(params: ["hi"], defaultValue: defaultToken),
            throwsA(isA<Exception>()));
      });
    });
  });

  group('Color', () {
    test('color gets clipped between ranges [0x00000000-0xffffffff]', () {
      var colorToken = ColorToken(color: 0x00000000 - 1);
      expect(colorToken.color, 0x00000000);
      colorToken = ColorToken(color: 0xffffffff + 1);
      expect(colorToken.color, 0xffffffff);
    });

    group('fromRaw', () {
      test('parses input correctly', () {
        final defaultToken = ColorToken(color: 0xff000000);
        final token = ColorToken.fromRaw(
            params: ["0xff000000"], defaultValue: defaultToken);
        expect(token.color, 0xff000000);
      });
      test('returns default token on input "d"', () {
        final defaultToken = ColorToken(color: 0xff000000);
        final token =
            ColorToken.fromRaw(params: ["d"], defaultValue: defaultToken);
        expect(token.color, defaultToken.color);
      });
      test('throws error on invalid input', () {
        final defaultToken = ColorToken(color: 0xff000000);
        expect(
            () =>
                ColorToken.fromRaw(params: ["2.3"], defaultValue: defaultToken),
            throwsA(isA<Exception>()));
      });
    });
  });

  group('Italics', () {
    test('isOn gets clipped between ranges [0-1]', () {
      var italicsToken = ItalicsToken(isOn: -1);
      expect(italicsToken.isOn, 0);
      italicsToken = ItalicsToken(isOn: 2);
      expect(italicsToken.isOn, 1);
    });

    group('fromRaw', () {
      test('parses input correctly', () {
        final defaultToken = ItalicsToken(isOn: 0);
        final token =
            ItalicsToken.fromRaw(params: ["1"], defaultValue: defaultToken);
        expect(token.isOn, 1);
      });
      test('returns default token on input "d"', () {
        final defaultToken = ItalicsToken(isOn: 0);
        final token =
            ItalicsToken.fromRaw(params: ["d"], defaultValue: defaultToken);
        expect(token.isOn, defaultToken.isOn);
      });
      test('throws error on invalid input', () {
        final defaultToken = ItalicsToken(isOn: 0);
        expect(
            () => ItalicsToken.fromRaw(
                params: ["2.3"], defaultValue: defaultToken),
            throwsA(isA<Exception>()));
      });
    });
  });

  group('Font', () {
    test('fromRaw param "d" returns default value', () {
      final defaultToken = FontToken(font: "Roboto");
      final token =
          FontToken.fromRaw(params: ["d"], defaultValue: defaultToken);
      expect(token.font, defaultToken.font);
    });
  });

  group('Link', () {
    test('values get clipped between ranges', () {
      var linkToken = LinkToken(
          link: "", styleChange: -1, color: 0x00000000 - 1, isUnderline: -1);
      expect(linkToken.styleChange, 0);
      expect(linkToken.color, 0x00000000);
      expect(linkToken.isUnderline, 0);
      linkToken = LinkToken(
          link: "", styleChange: 2, color: 0xffffffff + 1, isUnderline: 2);
      expect(linkToken.styleChange, 1);
      expect(linkToken.color, 0xffffffff);
      expect(linkToken.isUnderline, 1);
    });

    group('fromRaw', () {
      test('param "d" returns "d"', () {
        final defaultToken = LinkToken(
            link: "google.com",
            styleChange: 1,
            color: 0x00000000,
            isUnderline: 1);
        final token =
            LinkToken.fromRaw(params: ["d"], defaultValue: defaultToken);
        expect(token.link, "d");
      });
      test('missing param inputs returns default values', () {
        var defaultToken = LinkToken(
            link: "google.com",
            styleChange: 0,
            color: 0x00000000,
            isUnderline: 1);

        var linkToken = LinkToken.fromRaw(
            params: ["google.com"], defaultValue: defaultToken);

        expect(linkToken.styleChange, defaultToken.styleChange);
        linkToken =
            LinkToken.fromRaw(params: ["d", "d", "d"], defaultValue: defaultToken);
        expect(linkToken.link, "d");
        expect(linkToken.styleChange, defaultToken.styleChange);
        expect(linkToken.color, defaultToken.color);
        expect(linkToken.isUnderline, defaultToken.isUnderline);
      });
    });
  });
}
