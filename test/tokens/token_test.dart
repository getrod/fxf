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
      });

      test('missing param inputs returns default values', () {
        var defaultToken =
            UnderlineToken(lineType: 0, lineStyle: 0, color: 0xff000000);

        var underlineToken =
            UnderlineToken.fromRaw(params: ["1"], defaultValue: defaultToken);

        expect(underlineToken.lineStyle, defaultToken.lineStyle);
        expect(underlineToken.color, defaultToken.color);

        underlineToken =
            UnderlineToken.fromRaw(params: ["1", "2"], defaultValue: defaultToken);
        expect(underlineToken.color, defaultToken.color);
      });

      test('throws error on incorrect input', () {
        var defaultToken =
            UnderlineToken(lineType: 0, lineStyle: 0, color: 0xff000000);

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
  });

  group('Color', () {
    test('color gets clipped between ranges [0x00000000-0xffffffff]', () {
      var colorToken = ColorToken(color: 0x00000000 - 1);
      expect(colorToken.color, 0x00000000);
      colorToken = ColorToken(color: 0xffffffff + 1);
      expect(colorToken.color, 0xffffffff);
    });
  });

  group('Italics', () {
    test('isOn gets clipped between ranges [0-1]', () {
      var italicsToken = ItalicsToken(isOn: -1);
      expect(italicsToken.isOn, 0);
      italicsToken = ItalicsToken(isOn: 2);
      expect(italicsToken.isOn, 1);
    });
  });

  group('Link', () {
    test('styleChange gets clipped between ranges [0-1]', () {
      var linkToken = LinkToken(link: "", styleChange: -1);
      expect(linkToken.styleChange, 0);
      linkToken = LinkToken(link: "", styleChange: 2);
      expect(linkToken.styleChange, 1);
    });
  });
}
