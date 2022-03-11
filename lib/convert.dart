import 'dart:io';
import 'package:path/path.dart' as path;
import 'image/metadata.dart';
import './image/mime_types.dart' as mime_types;

const libwebp = r'D:\Program_Files\libwebp';
final cwebp = path.join(libwebp, r'./bin/cwebp.exe');
final gif2webp = path.join(libwebp, r'./bin/gif2webp.exe');

class ConvertReturns {
  final ProcessResult processResult;
  final String actualInput;
  final String output;
  const ConvertReturns(this.actualInput, this.output, this.processResult);
}

/// 怎么把 input 处理后 赋值给 output
/// 若 fixExtension == true, 则 input 会被改变
Future<ConvertReturns> convert(String input,
    [bool fixExtension = false, String output = '', final int quality = 100]) async {
  print('[Info] Convert "${path.basename(input)}" to webp:');

  final inputFile = File(input);
  // RandomAccessFile file = await inputFile.open(mode: FileMode.read);
  // final meta = getIMeta(await file.read(maxMetaOffset));
  // await file.close();
  final meta = getMetadata(await inputFile.readAsBytes());
  if (null != meta) {
    print('\tMIME Type: ${meta.mimeType}');
    print('\tIs animated: ${meta.isAnimated}');
    // nexusmods.com 的图片扩展名总是出错. 修正一下
    if (fixExtension && path.extension(input).toLowerCase() != meta.recommendedExtension) {
      input = path.setExtension(input, meta.recommendedExtension);
      await inputFile.rename(input);
    }
  } else {
    print('\t[Warning]: unknown format. Use cwebp to convert.');
  }
  if (output == '') output = input + '.webp';
  final String executable;
  final args = ['-q', quality.toString(), '-mt'];
  final inAndOut = [input, '-o', output];
  final ProcessResult processResult;
  // 目前除了 GIF 是用 gif2webp 转换, 其它的均尝试用 cwebp 转换
  if (null != meta && meta.mimeType == mime_types.gif) {
    executable = gif2webp;
    args.addAll(inAndOut);
    processResult = await Process.run(executable, args);
    // gif2webp.exe 不认 -near_lossless.  Error! Unknown option '-near_lossless'
  } else {
    executable = cwebp;
    // 使用 -near_lossless 0 后太慢了.
    // args.addAll(['-near_lossless', '0']);
    args.addAll(inAndOut);
    processResult = await Process.run(executable, args);
  }
  // if (meta.format == ImageFormat.AVIF)
  // if (meta.format == ImageFormat.APNG) 暂不处理 APNG
  // if (meta.format == ImageFormat.WEBP && meta.isAnimated)  暂不处理 WEBP 动图

  return ConvertReturns(input, output, processResult);
}
