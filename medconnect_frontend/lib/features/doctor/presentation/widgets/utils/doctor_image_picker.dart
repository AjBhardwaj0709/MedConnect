import 'package:image_picker/image_picker.dart';

class DoctorImagePicker {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
  }
}
