import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'image/metadata.dart';
import 'image/gif.dart' as gif;

final scriptDirPath = path.dirname(Platform.script.toFilePath());
final cwebp = path.join(scriptDirPath, r'./vendor/libwebp/cwebp.exe');
final gif2webp = path.join(scriptDirPath, r'./vendor/libwebp/gif2webp.exe');

final tempDirPath = Platform.environment['TEMP'];

class ConvertReturns {
  // 修复扩展名的 input. 如果扩展名原本是推荐的扩展名, 则是原文件名
  final String fixedInput;
  // 链接图片文件的 link, 这个 link 位于 %TEMP% 下
  final String actualInput;
  // 默认值: actualInput + '.webp'
  final String output;

  final ProcessResult processResult;
  ConvertReturns(this.fixedInput, this.actualInput, this.output, this.processResult);
}

/// 注意:
///   因为 Windows Shell Console 的对于 UTF-8 支持欠佳.
///   目前要求 input 和 output 只能是 ASCII 字符串. 而非 ANSI, UTF-8.
/// 怎么把 input 处理后 赋值给 output
/// 若 fixExtension == true, 则 input 会被改变
Future<ConvertReturns> convert(String input,
    [bool fixExtension = false, String output = '', final int quality = 100]) async {
  final inputBasename = path.basename(input);
  print('[Info] Convert "$inputBasename" to webp:');

  final inputFile = File(input);

  // 为了 I/O 优化. 但尚不知能判定是为为动图需要的 offset
  // RandomAccessFile file = await inputFile.open(mode: FileMode.read);
  // final meta = getIMeta(await file.read(maxMetaOffset));
  // await file.close();

  // 若非 recommended extension, 则重命名
  var extension = path.extension(input);
  String fixedInput = input;
  final meta = getMetadata(await inputFile.readAsBytes());
  if (null != meta) {
    print('\tMIME type: ${meta.mimeType}');
    print('\tIs animated: ${meta.isAnimated}');
    // nexusmods.com 的图片扩展名总是出错. 修正一下.
    // 即便是大写的, 也要转成小写.
    final isRecExt = extension == meta.recommendedExtension;
    if (fixExtension && !isRecExt) {
      fixedInput = path.setExtension(input, meta.recommendedExtension);
      await inputFile.rename(fixedInput);
    }
    extension = meta.recommendedExtension;
  } else {
    print('\t[Warning]: Unknown image format. Use cwebp to convert.');
  }
  final actualInput = path.join(tempDirPath!, '${Uuid().v1()}$extension');
  final tempLink = Link(actualInput);
  await tempLink.create(fixedInput);

  if (output == '') output = actualInput + '.webp';
  final String executable;
  final args = ['-q', quality.toString(), '-mt'];
  final inAndOut = [actualInput, '-o', output];
  final ProcessResult processResult;
  // 目前除了 GIF 是用 gif2webp 转换, 其它的均尝试用 cwebp 转换
  if (null != meta && meta.mimeType == gif.mimeType) {
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

  return ConvertReturns(fixedInput, actualInput, output, processResult);
}
