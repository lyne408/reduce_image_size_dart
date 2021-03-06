import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'convert.dart' show convert;
import 'file_util.dart' show moveFile;

class SizeReturns {
  final int inputSize;
  final int outputSize;
  const SizeReturns(this.inputSize, this.outputSize);
}

Future<SizeReturns> smallFile(final String input) async {
  final inputFile = File(input);
  final inputSize = await inputFile.length();

  print('\n----------------------------------------------------------');
  print('[Info] Input file: ${path.basename(input)}');

  final convertReturns = await convert(input, true);

  final outputFile = File(convertReturns.output);
  final int outputSize;

  // If output file does not exists, means convert operation failed.
  if (!await outputFile.exists()) {
    print('[Error] Convert to webp failed.');
    print('\texitCode: ${convertReturns.processResult.exitCode}');
    print('\tstdout: ${convertReturns.processResult.stdout}');
    print('\tstderr: ${convertReturns.processResult.stderr}');
    outputSize = inputSize;
  }
  // Convert operation success.
  else {
    outputSize = await outputFile.length();
    print('\tInput file size: $inputSize');
    print('\tOutput file size: $outputSize');

    if (outputSize < inputSize) {
      await File(convertReturns.fixedInput).delete();
      await moveFile(outputFile, path.setExtension(input, '.webp'));
    } else {
      await outputFile.delete();
    }
  }
  return SizeReturns(inputSize, outputSize);
}

Future<void> _smallFileIsolate(List<dynamic> args) async {
  SendPort responsePort = args[0];
  File file = args[1];
  Isolate.exit(responsePort, await smallFile(file.absolute.path));
}

Future<SizeReturns> smallDirectory(final String directory) async {
  print('[Info] Working directory:');
  print('\t${path.basename(directory)}');
  final dir = Directory(directory);
  int sizeBefore = 0;
  int sizeAfter = 0;
  await for (final file in dir.list()) {
    final port = ReceivePort();
    /* 
    Isolate.spawn(
      void Function(T) entryPoint,
      T message
    )
    ??? entryPoint ???????????????, ??? message ??? SendPort, 
    ??? Dart 2.16.1 ???????????????????????????
    */
    await Isolate.spawn(_smallFileIsolate, [port.sendPort, file]);
    final sizes = await port.first as SizeReturns;
    final inputSize = sizes.inputSize;
    final outputSize = sizes.outputSize;
    sizeBefore += inputSize;
    outputSize < inputSize ? sizeAfter += outputSize : sizeAfter += inputSize;
  }
  return SizeReturns(sizeBefore, sizeAfter);
}

Future<SizeReturns> small(final String pathArg) async {
  final SizeReturns sizes;
  if (await FileSystemEntity.isDirectory(pathArg)) {
    sizes = await smallDirectory(pathArg);
  } else {
    sizes = await smallFile(pathArg);
  }
  return sizes;
}
