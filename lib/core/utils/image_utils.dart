import 'package:file_picker/file_picker.dart';

class ImageUtils {
  static Future<List<PlatformFile>> pickImagesWeb() async {
    final result = await FilePicker.platform.pickFiles(
      compressionQuality: 70,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: true,
      withData: true,
    );

    if (result == null) {
      return [];
    }

    return result.files;
  }
}
