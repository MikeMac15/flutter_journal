
import 'package:convert/convert.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

// // Calculates the SHA-256 hash of an XFile's byte data.
// Future<String> calculateImageHash(XFile file) async {
//   print('calculating hash for ${file.name}');
//   // Read the file into memory as a list of bytes.
//   final imageBytes = await file.readAsBytes();

//   // Use the crypto package to generate the SHA-256 digest.
//   final digest = sha256.convert(imageBytes);

//   // Return the hexadecimal string representation of the hash.
//   return digest.toString();
// }


Future<String> calculateImageHash(XFile file) async {
  final hash = sha256;
  final sink = AccumulatorSink<Digest>();
  final byteSink = hash.startChunkedConversion(sink);

  // Stream the file bytes in chunks 64kb ish
  await for (final chunk in file.openRead()) {
    byteSink.add(chunk);
  }
  // 5. finalize the hash
  byteSink.close();
  // 6. Extract and return the hash string
  return sink.events.single.toString();
}

////////////////.   METADATA EXTRACTION
