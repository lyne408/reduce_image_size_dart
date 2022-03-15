import 'dart:io';
import 'package:io/io.dart' show copyPath;
import 'package:path/path.dart' as path;
import 'package:reduce_image_size/program_info.dart' show name, version;

final projectDirPath = path.dirname(path.dirname(Platform.script.toFilePath()));
final outputDirPath = path.join(projectDirPath, 'build/$version');

final vendorDirPath = path.join(projectDirPath, 'vendor');
final vendorCopyedDirPath = path.join(outputDirPath, 'vendor');

final entryPath = path.join(projectDirPath, 'bin/$name.dart');
final outputBinPath = path.join(outputDirPath, '$name.exe');

Future<void> main(List<String> args) async {
  // 应该先清空或删除 outputDir
  await Directory(outputDirPath).create(recursive: true);
  await Process.run('dart.exe', ['compile', 'exe', entryPath, '-o', outputBinPath]);
  await copyPath(vendorDirPath, vendorCopyedDirPath);
  print('[Info] Build finished. Check directory:');
  print('\t$outputDirPath');
}
