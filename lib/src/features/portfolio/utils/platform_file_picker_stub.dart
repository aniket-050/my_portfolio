import 'dart:typed_data';

class PickedImageAsset {
  const PickedImageAsset({
    required this.name,
    required this.dataUrl,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final String dataUrl;
  final Uint8List bytes;
  final String mimeType;
}

Future<PickedImageAsset?> pickImageAsset() async {
  return null;
}
