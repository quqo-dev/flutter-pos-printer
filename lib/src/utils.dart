import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';

const String TEXT_SPACE = '  ';
const int MAX_DKSH_ROW = 9;

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
      'TIS-620',
      text,
    );
