// Simple script to generate placeholder app icons for KoiTai.
//
// This generates minimal placeholder PNG files so that the
// flutter_launcher_icons and flutter_native_splash packages
// can run without errors during development.
//
// Usage:
//   dart run tools/generate_icon.dart
//
// These placeholders should be replaced with proper design assets
// before release. The final icons should follow the design spec:
// - Heart + Moon + Stars theme
// - Primary color: #6C3FE0
// - App icon: 1024x1024 PNG
// - Adaptive foreground: 1024x1024 PNG (centered in safe zone)
// - Splash logo: 512x512 PNG

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

/// Generates a minimal valid PNG file filled with a solid color.
///
/// This creates a very small (1x1 pixel) PNG that can serve as a
/// placeholder. Replace with real assets before running the icon
/// generation commands.
Uint8List generateMinimalPng({
  int r = 108,
  int g = 63,
  int b = 224,
  int a = 255,
}) {
  // Minimal valid 1x1 RGBA PNG
  // PNG signature
  final signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];

  // IHDR chunk: width=1, height=1, bit depth=8, color type=6 (RGBA)
  final ihdrData = <int>[
    0, 0, 0, 1, // width
    0, 0, 0, 1, // height
    8, // bit depth
    6, // color type (RGBA)
    0, // compression
    0, // filter
    0, // interlace
  ];
  final ihdr = _makeChunk('IHDR', ihdrData);

  // IDAT chunk: zlib-compressed filter+pixel data
  // Raw data: filter byte (0) + R, G, B, A
  // We use a stored (uncompressed) zlib block
  final rawRow = <int>[0, r, g, b, a]; // filter=none + RGBA pixel
  final idat = _makeChunk('IDAT', _zlibStore(rawRow));

  // IEND chunk
  final iend = _makeChunk('IEND', <int>[]);

  return Uint8List.fromList([...signature, ...ihdr, ...idat, ...iend]);
}

List<int> _makeChunk(String type, List<int> data) {
  final typeBytes = type.codeUnits;
  final length = data.length;
  final lengthBytes = [
    (length >> 24) & 0xFF,
    (length >> 16) & 0xFF,
    (length >> 8) & 0xFF,
    length & 0xFF,
  ];
  final crcInput = [...typeBytes, ...data];
  final crc = _crc32(crcInput);
  final crcBytes = [
    (crc >> 24) & 0xFF,
    (crc >> 16) & 0xFF,
    (crc >> 8) & 0xFF,
    crc & 0xFF,
  ];
  return [...lengthBytes, ...typeBytes, ...data, ...crcBytes];
}

List<int> _zlibStore(List<int> data) {
  // zlib header (no compression)
  final header = <int>[0x78, 0x01];
  // DEFLATE stored block: final=1, type=00
  final len = data.length;
  final storedBlock = <int>[
    0x01, // BFINAL=1, BTYPE=00
    len & 0xFF,
    (len >> 8) & 0xFF,
    (~len) & 0xFF,
    (~len >> 8) & 0xFF,
    ...data,
  ];
  // Adler-32 checksum
  int a = 1, b = 0;
  for (final byte in data) {
    a = (a + byte) % 65521;
    b = (b + a) % 65521;
  }
  final adler = (b << 16) | a;
  final adlerBytes = [
    (adler >> 24) & 0xFF,
    (adler >> 16) & 0xFF,
    (adler >> 8) & 0xFF,
    adler & 0xFF,
  ];
  return [...header, ...storedBlock, ...adlerBytes];
}

int _crc32(List<int> data) {
  // CRC-32 lookup table
  final table = List<int>.generate(256, (n) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      if (c & 1 != 0) {
        c = 0xEDB88320 ^ (c >> 1);
      } else {
        c = c >> 1;
      }
    }
    return c;
  });

  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc = table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}

void main() async {
  // Generate app icon placeholder (purple)
  final iconPng = generateMinimalPng(r: 108, g: 63, b: 224);
  await File('assets/icon/app_icon.png').writeAsBytes(iconPng);
  print('Created assets/icon/app_icon.png (placeholder)');

  // Generate adaptive icon foreground placeholder (white)
  final foregroundPng = generateMinimalPng(r: 255, g: 255, b: 255);
  await File('assets/icon/app_icon_foreground.png').writeAsBytes(foregroundPng);
  print('Created assets/icon/app_icon_foreground.png (placeholder)');

  // Generate splash logo placeholder (white)
  final splashPng = generateMinimalPng(r: 255, g: 255, b: 255);
  await File('assets/splash/splash_logo.png').writeAsBytes(splashPng);
  print('Created assets/splash/splash_logo.png (placeholder)');

  print('');
  print('Placeholder icons generated successfully!');
  print('Replace these with proper design assets before release.');
  print('');
  print('Then run:');
  print('  dart run flutter_launcher_icons');
  print('  dart run flutter_native_splash:create');
}
