import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:unicode_data/unicode_data.dart';

const String TEXT_SPACE = '  ';

class ImageData {
  final int width;
  final int height;
  ImageData({
    required this.width,
    required this.height,
  });
}

ImageData toPixel(ImageData image,
    {required int paperWidth, required int dpi, required bool isTspl}) {
  final double mmToInch = 0.036;

  int targetWidthPx =
      (paperWidth.toDouble() * dpi.toDouble() * mmToInch).toInt();
  final int nearest = 8;
  targetWidthPx = (targetWidthPx - (targetWidthPx % nearest)).round();
  final double widthRatio = targetWidthPx / image.width;

  int targetHeightPx = 0;
  if (isTspl) {
    targetHeightPx =
        (image.height.toDouble() * dpi.toDouble() * mmToInch).toInt();
  } else {
    targetHeightPx = (image.height * widthRatio).toInt();
  }
  return ImageData(width: targetWidthPx, height: targetHeightPx);
}

String getTabs(int n, {String? customSeperateCharacter}) {
  String response = '';
  String seperator = customSeperateCharacter ?? TEXT_SPACE;

  for (int i = 0; i < n; i++) {
    response += seperator;
  }

  return response;
}

String getRightAlignedText(String text, int maxLength) {
  if (text.length >= maxLength) return text;

  return getTabs(maxLength - text.length, customSeperateCharacter: ' ') +
      text +
      ' ';
}

Future<Uint8List> getThaiEncoded(String text) async =>
    await CharsetConverter.encode(
      'Windows-874',
      text,
    );

double getDoubleFromFormattedString(String str) {
  String stringValue = str.replaceAll(',', '');
  return double.parse(stringValue);
}

String formatCurrencyValue(String value) {
  List<String> parts = value.split('.');
  parts[0] = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');
  return parts.join('.');
}

String fillSpaceText(String text, int maxLength) {
  int difference = text.length - get_thai_string_length(text);
  print(difference);
  return get_thai_string_length(text) <= maxLength
      ? text.padRight(maxLength-difference)
      : text.substring(0, maxLength+difference).padRight(maxLength);
}


int get_thai_string_length(String text) {
  List<Script> scripts = UnicodeScript.scripts;
  int length = 0;
  for(int i=0; i<text.length; i++) {
    var char = text[i];

    final codePoint = char.runes.single;
    final found = scripts.where(
            (script) => codePoint >= script.start && codePoint <= script.end);
    final script = found.single;
    final name = script.name; // Latin
    final category = script.category; // L&

    if(category != 'Mn'){
      length += 1;
    }
  }



  return length;
}
