// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'package:flutter/services.dart';

class AssetDownloadResult {
  const AssetDownloadResult({required this.fileName, this.path});

  final String fileName;
  final String? path;
}

Future<AssetDownloadResult> downloadAsset({
  required String assetPath,
  required String fileName,
}) async {
  final data = await rootBundle.load(assetPath);
  final bytes = Uint8List.view(data.buffer);
  final blob = html.Blob([bytes], _mimeType(fileName));
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..download = fileName
    ..click();

  html.Url.revokeObjectUrl(url);

  return AssetDownloadResult(fileName: fileName);
}

String _mimeType(String fileName) {
  if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  return 'image/png';
}
