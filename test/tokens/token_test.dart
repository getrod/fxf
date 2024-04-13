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
