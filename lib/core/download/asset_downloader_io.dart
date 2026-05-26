import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');

  await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

  return AssetDownloadResult(fileName: fileName, path: file.path);
}
