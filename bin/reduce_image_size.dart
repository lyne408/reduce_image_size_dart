import 'package:reduce_image_size/reduce_image_size.dart' as reduce_image_size;

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('[Usage]');
    print('\treduce_image_size <file or directory>');
  } else {
    final pathVar = args[0];
    final sizes = await reduce_image_size.small(pathVar);
    print('\n----------------------------------------------------------');
    print('[Info] Finished!');
    print('\tSize before: ${sizes.inputSize}');
    print('\tSize after: ${sizes.outputSize}');
  }
}
