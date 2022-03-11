import 'package:reduce_image_size/reduce_image_size.dart' as reduce_image_size;

Future<void> main(List<String> args) async {
  final pathVar = args[0];
  // final dir = r'C:\Users\lyne\Downloads\Image Picka';
  // final name = '_author_images_of_BT.2020 LUT and Rudy ENB preset_1.02';
  // final pathVar = path.join(dir, name);
  // await Process.run('cmd.exe', ['/K', 'chcp 65001']);
  final sizes = await reduce_image_size.small(pathVar);

  print('');
  print('----------------------------------------------------------');
  print('[Info] Finished!');
  print('\tSize before: ${sizes.inputSize}');
  print('\tSize after: ${sizes.outputSize}');
}
