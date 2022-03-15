import 'dart:io';

/// 解决 rename() 不能跨分区.
/// FileSystemException: Cannot rename file to 'R:\021_1.6.webp', path = 'C:\021_1.6.webp'
/// (OS Error: The system cannot move the file to a different disk drive. errno = 17)
Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}
