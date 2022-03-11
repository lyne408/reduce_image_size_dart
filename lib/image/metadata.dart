import 'dart:typed_data';

import './gif.dart' as gif;
import './jpeg.dart' as jpeg;
import './png.dart' as png;
import './webp.dart' as webp;

// const maxMetaOffset = 100;

/// JPG 不是标准
enum ImageFormat { apng, gif, jpeg, png, webp }

class Metadata {
  final String mimeType;
  final String recommendedExtension;
  final bool isAnimated;
  const Metadata(this.mimeType, this.isAnimated, this.recommendedExtension);
}

/// Checks if buffer contains animated image
///
/// @param {Buffer} buffer
/// @returns Meta? 当非这几种支持的类型, 就返回 null
Metadata? getMetadata(Uint8List buffer) {
  final Metadata meta;
  if (gif.isGif(buffer)) {
    meta = gif.getMetadata(buffer);
  } else if (jpeg.isJpeg(buffer)) {
    meta = jpeg.getMetadata(buffer);
  } else if (png.isPng(buffer)) {
    meta = png.getMetadata(buffer);
  } else if (webp.isWebp(buffer)) {
    meta = webp.getMetadata(buffer);
  } else {
    return null;
  }
  return meta;
}
