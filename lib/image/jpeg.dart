import 'dart:typed_data';
import './mime_types.dart' as mime_types;
import '../list_util.dart';
import 'metadata.dart';

const recommendedExtension = '.jpeg';
const extensions = ['.jpg', '.jpeg', '.jpe', '.jif', '.jfif'];
const mimeType = 'image/jpeg';
// 3 bytes
const beginCodes = [0xFF, 0xD8, 0xFF];
// 2 bytes
const endCodes = [0xFF, 0xD9];

/// https://github.com/vivaxy/is-animated-image 只检查开头三个字节 [0xFF, 0xD8, 0xFF]
/// https://www.file-recovery.com/jpg-signature-format.htm 检查开头三个字节和末尾两个字节
bool isJpeg(Uint8List buffer) {
  final header = buffer.sublist(0, beginCodes.length);
  return (bothHave(beginCodes, header));
}

/// 截止 22.02, JPEG 标准没有动图
/// 参数无用, 为了 API
bool isAnimated(Uint8List buffer) {
  return false;
}

Metadata getMetadata(Uint8List buffer) {
  return Metadata(mime_types.jpeg, isAnimated(buffer), recommendedExtension);
}
