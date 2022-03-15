import 'dart:typed_data';
import 'metadata.dart';

const extensions = ['.webp'];
const mimeType = 'image/webp';
const recommendedExtension = '.webp';
const riffCodes = [0x52, 0x49, 0x46, 0x46];
const webpCodes = [0x57, 0x45, 0x42, 0x50];

/// WebP file header (12 bytes)
/// 'RIFF': 32 bits
///     The ASCII characters 'R' 'I' 'F' 'F'.
/// File Size: 32 bits (uint32)
///     The size of the file in bytes starting at offset 8.
/// 'WEBP': 32 bits
///     The ASCII characters 'W' 'E' 'B' 'P'.
bool isWebp(Uint8List buffer) {
  for (var i = 0; i < 4; i++) {
    if (buffer[i] != riffCodes[i] || buffer[i + 8] != webpCodes[i]) {
      return false;
    }
  }
  return true;
}

/// ANIM
const animCodes = [0x41, 0x4E, 0x49, 0x4D];

/// 暂时没有时间查看标准. webp 动图 0x1E 开始确实有 ANIM.
/// 需 buffer.length >= 0x21
bool isAnimated(Uint8List buffer) {
  for (var i = 0; i < animCodes.length; i++) {
    // 1E 是 A.
    if (buffer[i + 0x1E] != animCodes[i]) {
      return false;
    }
  }
  return true;
}

Metadata getMetadata(Uint8List buffer) {
  return Metadata(mimeType, isAnimated(buffer), recommendedExtension);
}
