import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart'; // Or your image picker package


import 'dart:typed_data';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';

// Calculates the SHA-256 hash of an XFile's byte data.
Future<String> calculateImageHash(XFile file) async {
  print('calculating hash for ${file.name}');
  // Read the file into memory as a list of bytes.
  final imageBytes = await file.readAsBytes();

  // Use the crypto package to generate the SHA-256 digest.
  final digest = sha256.convert(imageBytes);

  // Return the hexadecimal string representation of the hash.
  return digest.toString();
}

////////////////.   METADATA EXTRACTION

/// Safely convert `IfdTag.values` → List<dynamic>
List<dynamic> _valuesToList(dynamic tag) {
  if (tag == null) return const [];
  try {
    final v = (tag as dynamic).values; // IfdValues, List, etc.
    if (v is List) return v;
    if (v is Iterable) return v.toList();
    // Some IfdValues support indexing and length
    final dyn = v as dynamic;
    final len = (dyn.length is int) ? dyn.length as int : null;
    if (len != null && len > 0) {
      return List.generate(len, (i) => dyn[i]);
    }
  } catch (_) {}
  // Fallback: sometimes tag itself is already a scalar
  return [tag];
}

/// Safely get the first scalar value from a tag (as T if possible)
T? _firstValueOrNull<T>(dynamic tag) {
  final list = _valuesToList(tag);
  if (list.isEmpty) return null;
  final x = list[0];
  if (x is T) return x;
  // Try common conversions
  if (T == double) return (x is num ? x.toDouble() : double.tryParse(x.toString())) as T?;
  if (T == int) return (x is num ? x.toInt() : int.tryParse(x.toString())) as T?;
  return x as T?;
}

/// Convert EXIF DMS to decimal degrees
double? _gpsToDecimal(dynamic dmsTag, String? refRaw) {
  if (dmsTag == null || refRaw == null) return null;
  final vals = _valuesToList(dmsTag).map<double?>((v) {
    if (v is num) return v.toDouble();
    try {
      final d = (v as dynamic).toDouble?.call();
      if (d is double) return d;
    } catch (_) {}
    return double.tryParse(v.toString());
  }).whereType<double>().toList();

  if (vals.length < 3) return null;
  final deg = vals[0];
  final min = vals[1];
  final sec = vals[2];
  double decimal = deg + (min / 60.0) + (sec / 3600.0);
  final ref = refRaw.toUpperCase();
  if (ref == 'S' || ref == 'W') decimal = -decimal;
  return decimal;
}

/// Optional: create a small JPEG thumbnail from full image bytes
Uint8List? _generateThumbnailFromBytes(Uint8List bytes, {int maxSize = 256, int quality = 80}) {
  try {
    final src = im.decodeImage(bytes);
    if (src == null) return null;
    // Preserve aspect ratio, constrain longer side to maxSize
    final w = src.width, h = src.height;
    final isWide = w >= h;
    final resized = im.copyResize(
      src,
      width:  isWide ? maxSize : null,
      height: isWide ? null    : maxSize,
      // Defaults are fine; no extra filters needed
    );
    return Uint8List.fromList(im.encodeJpg(resized, quality: quality));
  } catch (_) {
    return null;
  }
}



Future<Map<String, dynamic>> extractCorePhotoMetadata(XFile file) async {
  final result = <String, dynamic>{};

  final bytes = await file.readAsBytes();
  final exifData = await readExifFromBytes(bytes);
  if (exifData.isEmpty) return result;

  // --- DATE TAKEN (prefer Original → Digitized → Image DateTime) ---
  String? _firstNonNullString(List<String?> values) =>
      values.firstWhere((v) => v != null && v.trim().isNotEmpty, orElse: () => null);

  final dateRaw = _firstNonNullString([
    exifData['EXIF DateTimeOriginal']?.toString(),
    exifData['EXIF DateTimeDigitized']?.toString(),
    exifData['Image DateTime']?.toString(),
  ]);

  if (dateRaw != null) {
    DateTime? parsed;
    try {
      // "YYYY:MM:DD HH:MM:SS"
      parsed = DateFormat('yyyy:MM:dd HH:mm:ss').parse(dateRaw, true).toLocal();
    } catch (_) {}
    result['dateTaken'] = parsed?.toIso8601String() ?? dateRaw;
  }

  // --- GPS ---
  final latTag   = exifData['GPS GPSLatitude'];
  final lonTag   = exifData['GPS GPSLongitude'];
  final latRef   = exifData['GPS GPSLatitudeRef']?.printable.toString()
                ?? exifData['GPS GPSLatitudeRef']?.toString();
  final lonRef   = exifData['GPS GPSLongitudeRef']?.printable.toString()
                ?? exifData['GPS GPSLongitudeRef']?.toString();

  final lat = _gpsToDecimal(latTag, latRef);
  final lon = _gpsToDecimal(lonTag, lonRef);

  if (lat != null && lon != null) {
    final gps = <String, dynamic>{'latitude': lat, 'longitude': lon};

    // Altitude (meters), sign via AltitudeRef (0=above,1=below)
    final altVal = _firstValueOrNull<num>(exifData['GPS GPSAltitude']);
    double? alt = altVal?.toDouble();
    final altRef = _firstValueOrNull<num>(exifData['GPS GPSAltitudeRef'])?.toInt();
    if (alt != null && altRef == 1) alt = -alt;

    if (alt != null) gps['altitude'] = alt;
    result['gps'] = gps;
  }

  // --- EMBEDDED EXIF THUMBNAIL (IF PRESENT) ---
  // IFD1: JPEGInterchangeFormat (offset), JPEGInterchangeFormatLength (length)
  Uint8List? thumbBytes;
  try {
    final offset = _firstValueOrNull<num>(exifData['JPEGInterchangeFormat'])?.toInt();
    final length = _firstValueOrNull<num>(exifData['JPEGInterchangeFormatLength'])?.toInt();
    if (offset != null && length != null && offset >= 0 && length > 0 && offset + length <= bytes.length) {
      thumbBytes = Uint8List.fromList(bytes.sublist(offset, offset + length));
    }
  } catch (_) {}

  if (thumbBytes != null) {
    result['thumbnailBase64'] = base64Encode(thumbBytes);
  } else {
    // Generate a small thumbnail if embedded one is missing
    final gen = _generateThumbnailFromBytes(bytes, maxSize: 256, quality: 80);
    if (gen != null) {
      result['thumbnailBase64'] = base64Encode(gen);
      result['thumbnailGenerated'] = true; // optional flag for your logic
    }
  }

  return result;
}
