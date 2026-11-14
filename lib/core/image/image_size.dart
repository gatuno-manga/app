import 'dart:typed_data';
import 'dart:ui' as ui;

/// Decodes only the header of [bytes] and reports the image size.
Future<void> reportImageSize(
  Uint8List bytes,
  void Function(ui.Size)? onImageLoaded,
) async {
  if (onImageLoaded == null) return;
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    onImageLoaded(
      ui.Size(descriptor.width.toDouble(), descriptor.height.toDouble()),
    );
    descriptor.dispose();
  } catch (e) {
    buffer.dispose();
    rethrow;
  }
}
