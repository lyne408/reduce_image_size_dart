import 'dart:math';
import 'dart:typed_data';

import '../list_util.dart' as list_util;
import 'metadata.dart';

class ImageHeader {
  final int start;
  final int end;
  final List<int> codes;
  const ImageHeader(this.start, this.end, this.codes);
}

const extensions = ['.gif'];
const recommendedExtension = '.gif';
const mimeType = 'image/gif';
// 3 bytes, is 'GIF'
const magicNumbers = [0x47, 0x49, 0x46];

/// get total length of data blocks sequence
///
/// @param {Buffer} buffer
/// @param {number} offset
/// @returns {number}
int getDataBlocksLength(Uint8List bytes, int offset) {
  var length = 0;
  while (bytes[offset + length] > 0) {
    length += bytes[offset + length] + 1;
  }
  return length + 1;
}

/// Checks if buffer contains GIF image
///
/// @param {Buffer} buffer
/// @returns {boolean}
bool isGif(Uint8List buffer) {
  final header = buffer.sublist(0, magicNumbers.length);
  return (list_util.bothHave(magicNumbers, header));
}

/// Checks if buffer contains animated GIF image
///
/// @param {Buffer} buffer
/// @returns {boolean}
bool isAnimated(Uint8List bytes) {
  int hasColorTable, colorTableSize;
  int offset = 0;
  int imagesCount = 0;

  // Check if this is this image has valid GIF header.
  // If not return false. Chrome, FF and IE doesn't handle GIFs with invalid version.

  /* __start__ Skip header, logical screen descriptor and global color table */
  // 0b10000000
  hasColorTable = bytes[10] & 0x80;
  // 0b00000111
  colorTableSize = bytes[10] & 0x07;

  // skip header
  offset += 6;
  // skip logical screen descriptor
  offset += 7;
  // skip global color table
  offset += hasColorTable > 0 ? 3 * pow(2, colorTableSize + 1).toInt() : 0;
  /* __end__ Skip header, logical screen descriptor and global color table */

  // Find if there is more than one image descriptor

  while (imagesCount < 2 && offset < bytes.length) {
    switch (bytes[offset]) {
      // Image descriptor block. According to specification there could be any
      // number of these blocks (even zero). When there is more than one image
      // descriptor browsers will display animation (they shouldn't when there
      // is no delays defined, but they do it anyway).
      case 0x2C:
        imagesCount += 1;
        // 0b10000000
        hasColorTable = bytes[offset + 9] & 0x80;
        // 0b00000111
        colorTableSize = bytes[offset + 9] & 0x07;
        // skip image descriptor
        offset += 10;
        // skip local color table
        offset += hasColorTable > 0 ? 3 * pow(2, colorTableSize + 1).toInt() : 0;
        // skip image data
        offset += getDataBlocksLength(bytes, offset + 1) + 1;
        break;

      // Skip all extension blocks. In theory this "plain text extension" blocks
      // could be frames of animation, but no browser renders them.
      case 0x21:
        // skip introducer and label
        offset += 2;
        // skip this block and following data blocks
        offset += getDataBlocksLength(bytes, offset);
        break;

      // Stop processing on trailer block,
      // all data after this point will is ignored by decoders
      case 0x3B:
        // fast forward to end of buffer
        offset = bytes.length;
        break;

      // Oops! This GIF seems to be invalid
      default:
        // fast forward to end of buffer
        offset = bytes.length;
        break;
    }
  }

  return imagesCount > 1;
}

Metadata getMetadata(Uint8List buffer) {
  return Metadata(mimeType, isAnimated(buffer), recommendedExtension);
}
