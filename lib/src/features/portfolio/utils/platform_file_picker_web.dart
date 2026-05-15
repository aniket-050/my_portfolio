// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
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
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;
  input.click();

  await input.onChange.first;
  final file = input.files?.first;
  if (file == null) {
    return null;
  }

  final dataUrlReader = html.FileReader();
  dataUrlReader.readAsDataUrl(file);
  await dataUrlReader.onLoad.first;
  final dataUrlResult = dataUrlReader.result;
  if (dataUrlResult is! String) {
    return null;
  }

  final bytesReader = html.FileReader();
  bytesReader.readAsArrayBuffer(file);
  await bytesReader.onLoad.first;
  final bytesResult = bytesReader.result;
  if (bytesResult is! ByteBuffer) {
    return null;
  }

  return PickedImageAsset(
    name: file.name,
    dataUrl: dataUrlResult,
    bytes: bytesResult.asUint8List(),
    mimeType: file.type,
  );
}
