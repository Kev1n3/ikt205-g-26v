import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image != null ? File(image.path) : null;
  }

  void validateImage(File file) {
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    final fileExtension = file.path.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(fileExtension)) {
      throw Exception('Invalid image format. Allowed formats: jpg, jpeg, png, webp.');
    }

    if (file.lengthSync() > 15 * 1024 * 1024) {
      throw Exception('Image size exceeds 15MB limit.');
    }
  }

}
