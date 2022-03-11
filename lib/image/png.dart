import 'dart:typed_data';

import '../list_util.dart';
import './mime_types.dart' as mime_types;
import 'metadata.dart';

const extensions = ['.png'];
const recommendedExtension = '.png';
const mimeType = 'image/png';
// 8 bytes
const magicNumbers = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

bool isPng(Uint8List buffer) {
  final header = buffer.sublist(0, magicNumbers.length);
  return (bothHave(magicNumbers, header));
}

/// acTL. 0x25 是 a
const actlCodes = [0x61, 0x63, 0x54, 0x4C];

/// https://github.com/qzb/is-animated
bool isAnimated(Uint8List buffer) {
  var hasACTL = false;
  var hasIDAT = false;
  var hasFDAT = false;

  var previousChunkType;

  var offset = 8;

  while (offset < buffer.length) {
    var blob = ByteData.sublistView(buffer);
    var chunkLength = blob.getUint32(offset);
    var chunkType = String.fromCharCodes(buffer.sublist(offset + 4, offset + 8));

    switch (chunkType) {
      case 'acTL':
        hasACTL = true;
        break;
      case 'IDAT':
        if (!hasACTL) {
          return false;
        }

        if (previousChunkType != 'fcTL' && previousChunkType != 'IDAT') {
          return false;
        }

        hasIDAT = true;
        break;
      case 'fdAT':
        if (!hasIDAT) {
          return false;
        }

        if (previousChunkType != 'fcTL' && previousChunkType != 'fdAT') {
          return false;
        }

        hasFDAT = true;
        break;
    }

    previousChunkType = chunkType;
    offset += 4 + 4 + chunkLength + 4;
  }

  return (hasACTL && hasIDAT && hasFDAT);
}

Metadata getMetadata(Uint8List buffer) {
  return Metadata(mime_types.png, isAnimated(buffer), recommendedExtension);
}
