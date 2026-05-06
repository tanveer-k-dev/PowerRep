import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndSaveImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String localPath = path.join(appDir.path, fileName);

      final File localFile = await File(image.path).copy(localPath);
      return localFile.path;
    } catch (e) {
      print('Error picking/saving image: $e');
      return null;
    }
  }

  static bool isLocalPath(String path) {
    return !path.startsWith('http');
  }
}
