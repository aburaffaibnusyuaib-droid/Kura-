import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Parameter data untuk background isolate compute
class ImageCompressionParams {
  const ImageCompressionParams({
    required this.bytes,
    this.maxDimension = 1024,
    this.quality = 78,
  });

  final Uint8List bytes;
  final int maxDimension;
  final int quality;
}

/// Fungsi kompresi murni top-level yang dieksekusi di background thread
Uint8List _compressImageWorker(ImageCompressionParams params) {
  try {
    final decoded = img.decodeImage(params.bytes);
    if (decoded == null) {
      return params.bytes;
    }

    img.Image resized = decoded;
    if (decoded.width > params.maxDimension || decoded.height > params.maxDimension) {
      if (decoded.width >= decoded.height) {
        resized = img.copyResize(decoded, width: params.maxDimension);
      } else {
        resized = img.copyResize(decoded, height: params.maxDimension);
      }
    }

    final compressed = img.encodeJpg(resized, quality: params.quality);
    return Uint8List.fromList(compressed);
  } catch (_) {
    return params.bytes;
  }
}

/// Utilitas kompresi gambar mandiri untuk efisiensi memori & performa AI.
///
/// Menjaga batas dimensi visual maksimal 1024px, kualitas JPEG 75-80%,
/// dan mengalihkan kompresi ke isolate `compute` bila ukuran byte > 1.5MB.
class ImageCompressor {
  const ImageCompressor._();

  static const int maxDimension = 1024;
  static const int defaultQuality = 78;
  static const int heavyThresholdBytes = 1572864; // 1.5 MB

  /// Mengompres bytes gambar. Menjalankan di background compute jika ukuran > 1.5MB.
  static Future<Uint8List> compressBytes(
    Uint8List rawBytes, {
    int maxDim = maxDimension,
    int quality = defaultQuality,
  }) async {
    if (rawBytes.isEmpty) return rawBytes;

    final params = ImageCompressionParams(
      bytes: rawBytes,
      maxDimension: maxDim,
      quality: quality,
    );

    if (rawBytes.lengthInBytes > heavyThresholdBytes) {
      return await compute(_compressImageWorker, params);
    } else {
      return _compressImageWorker(params);
    }
  }

  /// Mengompres file gambar dari path lokal dan mengembalikan bytes terkompresi.
  static Future<Uint8List> compressFile(
    String filePath, {
    int maxDim = maxDimension,
    int quality = defaultQuality,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File gambar tidak ditemukan', filePath);
    }
    final rawBytes = await file.readAsBytes();
    return await compressBytes(rawBytes, maxDim: maxDim, quality: quality);
  }
}
