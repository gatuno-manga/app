class ImageMetadata {
  final double width;
  final double height;
  final int? sizeBytes;
  final String? mimeType;
  final String? blurHash;
  final String? dominantColor;
  final String? pHash;
  final double? entropy;
  final String? formatOrigin;

  const ImageMetadata({
    required this.width,
    required this.height,
    this.sizeBytes,
    this.mimeType,
    this.blurHash,
    this.dominantColor,
    this.pHash,
    this.entropy,
    this.formatOrigin,
  });
}
