class AssetDownloadResult {
  const AssetDownloadResult({required this.fileName, this.path});

  final String fileName;
  final String? path;
}

Future<AssetDownloadResult> downloadAsset({
  required String assetPath,
  required String fileName,
}) {
  throw UnsupportedError('Asset download is not supported on this platform.');
}
