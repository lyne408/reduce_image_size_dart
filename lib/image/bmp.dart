import 'dart:typed_data';
import './metadata.dart';
import '../list_util.dart';

const recommendedExtension = '.bmp';
const extensions = ['.bmp'];
const mimeType = 'image/bmp';

/// 2 bytes, is 'BM'
/// https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader
const magicNumbers = [0x42, 0x4D];

bool isBmp(Uint8List buffer) {
  final header = buffer.sublist(0, magicNumbers.length);
  return bothHave(magicNumbers, header);
}

bool isAnimated(Uint8List buffer) {
  return false;
}

Metadata getMetadata(Uint8List buffer) {
  return Metadata(mimeType, isAnimated(buffer), recommendedExtension);
}
