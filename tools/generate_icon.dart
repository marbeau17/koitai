// Script to generate app icons and splash screen for KoiTai.
//
// Generates proper-sized PNG files with a crescent moon + stars design
// on a dark purple (#6C3FE0) background.
//
// Usage:
//   dart run tools/generate_icon.dart
//
// After running this script, run:
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// --- PNG Encoding Utilities ---

/// CRC-32 lookup table (computed once).
final List<int> _crc32Table = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    if (c & 1 != 0) {
      c = 0xEDB88320 ^ (c >>> 1);
    } else {
      c = c >>> 1;
    }
  }
  return c;
});

int _crc32(List<int> data) {
  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc = _crc32Table[(crc ^ byte) & 0xFF] ^ (crc >>> 8);
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

/// Creates a PNG chunk with the given type and data.
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

/// Encodes an RGBA pixel buffer as a PNG file.
///
/// [pixels] is a flat list of RGBA bytes (length = width * height * 4).
Uint8List encodePng(int width, int height, Uint8List pixels) {
  // PNG signature
  final signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];

  // IHDR chunk
  final ihdrData = <int>[
    (width >> 24) & 0xFF, (width >> 16) & 0xFF,
    (width >> 8) & 0xFF, width & 0xFF,
    (height >> 24) & 0xFF, (height >> 16) & 0xFF,
    (height >> 8) & 0xFF, height & 0xFF,
    8, // bit depth
    6, // color type (RGBA)
    0, // compression method
    0, // filter method
    0, // interlace method
  ];
  final ihdr = _makeChunk('IHDR', ihdrData);

  // Build raw scanline data: each row is filter_byte + RGBA pixels
  final rowBytes = width * 4;
  final rawData = BytesBuilder();
  for (var y = 0; y < height; y++) {
    rawData.addByte(0); // filter type: None
    final offset = y * rowBytes;
    rawData.add(pixels.sublist(offset, offset + rowBytes));
  }

  // Compress using dart:io ZLibCodec
  final compressed = zlib.encode(rawData.toBytes());
  final idat = _makeChunk('IDAT', compressed);

  // IEND chunk
  final iend = _makeChunk('IEND', <int>[]);

  final builder = BytesBuilder();
  builder.add(signature);
  builder.add(ihdr);
  builder.add(idat);
  builder.add(iend);
  return builder.toBytes();
}

// --- Drawing Utilities ---

/// Simple RGBA pixel buffer for drawing.
class PixelBuffer {
  final int width;
  final int height;
  final Uint8List data;

  PixelBuffer(this.width, this.height)
      : data = Uint8List(width * height * 4);

  /// Sets a pixel at (x, y) to the given RGBA color.
  void setPixel(int x, int y, int r, int g, int b, int a) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    final i = (y * width + x) * 4;
    data[i] = r;
    data[i + 1] = g;
    data[i + 2] = b;
    data[i + 3] = a;
  }

  /// Blends a pixel with alpha compositing (source over).
  void blendPixel(int x, int y, int r, int g, int b, int a) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    if (a == 0) return;
    final i = (y * width + x) * 4;
    if (a == 255) {
      data[i] = r;
      data[i + 1] = g;
      data[i + 2] = b;
      data[i + 3] = 255;
      return;
    }
    final srcA = a / 255.0;
    final dstA = data[i + 3] / 255.0;
    final outA = srcA + dstA * (1 - srcA);
    if (outA == 0) return;
    data[i] = ((r * srcA + data[i] * dstA * (1 - srcA)) / outA).round();
    data[i + 1] =
        ((g * srcA + data[i + 1] * dstA * (1 - srcA)) / outA).round();
    data[i + 2] =
        ((b * srcA + data[i + 2] * dstA * (1 - srcA)) / outA).round();
    data[i + 3] = (outA * 255).round();
  }

  /// Fills the entire buffer with a solid color.
  void fill(int r, int g, int b, int a) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        setPixel(x, y, r, g, b, a);
      }
    }
  }

  /// Draws a filled circle with anti-aliasing.
  void fillCircle(
      double cx, double cy, double radius, int r, int g, int b, int a) {
    final minX = (cx - radius - 2).floor().clamp(0, width - 1);
    final maxX = (cx + radius + 2).ceil().clamp(0, width - 1);
    final minY = (cy - radius - 2).floor().clamp(0, height - 1);
    final maxY = (cy + radius + 2).ceil().clamp(0, height - 1);

    for (var py = minY; py <= maxY; py++) {
      for (var px = minX; px <= maxX; px++) {
        final dx = px - cx;
        final dy = py - cy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist <= radius - 0.7) {
          blendPixel(px, py, r, g, b, a);
        } else if (dist <= radius + 0.7) {
          // Anti-aliased edge
          final coverage = ((radius + 0.7 - dist) / 1.4).clamp(0.0, 1.0);
          final aa = (a * coverage).round();
          blendPixel(px, py, r, g, b, aa);
        }
      }
    }
  }

  /// Draws a crescent moon by drawing a white circle and cutting out
  /// a circle offset to the upper-right.
  ///
  /// Returns pixel data that can be used as a mask for the crescent.
  void drawCrescent(double cx, double cy, double outerRadius,
      double innerRadius, double offsetX, double offsetY,
      {int r = 255, int g = 255, int b = 255, int a = 255}) {
    final minX = (cx - outerRadius - 2).floor().clamp(0, width - 1);
    final maxX = (cx + outerRadius + 2).ceil().clamp(0, width - 1);
    final minY = (cy - outerRadius - 2).floor().clamp(0, height - 1);
    final maxY = (cy + outerRadius + 2).ceil().clamp(0, height - 1);

    final innerCx = cx + offsetX;
    final innerCy = cy + offsetY;

    for (var py = minY; py <= maxY; py++) {
      for (var px = minX; px <= maxX; px++) {
        // Distance from outer circle center
        final dx1 = px - cx;
        final dy1 = py - cy;
        final dist1 = sqrt(dx1 * dx1 + dy1 * dy1);

        // Distance from inner (cutout) circle center
        final dx2 = px - innerCx;
        final dy2 = py - innerCy;
        final dist2 = sqrt(dx2 * dx2 + dy2 * dy2);

        // Pixel is in the crescent if inside outer circle but outside inner
        double outerCoverage;
        if (dist1 <= outerRadius - 0.7) {
          outerCoverage = 1.0;
        } else if (dist1 <= outerRadius + 0.7) {
          outerCoverage =
              ((outerRadius + 0.7 - dist1) / 1.4).clamp(0.0, 1.0);
        } else {
          continue;
        }

        double innerCoverage;
        if (dist2 <= innerRadius - 0.7) {
          innerCoverage = 1.0;
        } else if (dist2 <= innerRadius + 0.7) {
          innerCoverage =
              ((innerRadius + 0.7 - dist2) / 1.4).clamp(0.0, 1.0);
        } else {
          innerCoverage = 0.0;
        }

        final coverage = outerCoverage * (1.0 - innerCoverage);
        if (coverage > 0) {
          final aa = (a * coverage).round();
          blendPixel(px, py, r, g, b, aa);
        }
      }
    }
  }

  /// Draws a small 4-pointed star shape.
  void drawStar(double cx, double cy, double size,
      {int r = 255, int g = 255, int b = 255, int a = 255}) {
    // Draw a diamond/4-pointed star shape
    final minX = (cx - size - 1).floor().clamp(0, width - 1);
    final maxX = (cx + size + 1).ceil().clamp(0, width - 1);
    final minY = (cy - size - 1).floor().clamp(0, height - 1);
    final maxY = (cy + size + 1).ceil().clamp(0, height - 1);

    for (var py = minY; py <= maxY; py++) {
      for (var px = minX; px <= maxX; px++) {
        final dx = (px - cx).abs();
        final dy = (py - cy).abs();

        // 4-pointed star: use max of diamond distances
        // A diamond shape: dx/size + dy/size <= 1
        // Combined with a circular core for brightness
        final diamondDist = dx / size + dy / size;
        final circDist = sqrt(dx * dx + dy * dy) / (size * 0.5);

        // Blend diamond and circle shape
        final shapeDist = min(diamondDist, circDist);

        if (shapeDist <= 1.0) {
          final brightness = (1.0 - shapeDist).clamp(0.0, 1.0);
          final aa = (a * brightness).round();
          blendPixel(px, py, r, g, b, aa);
        }
      }
    }
  }

  /// Draws a small dot/circle for tiny stars.
  void drawDot(double cx, double cy, double radius,
      {int r = 255, int g = 255, int b = 255, int a = 255}) {
    fillCircle(cx, cy, radius, r, g, b, a);
  }

  Uint8List toPng() => encodePng(width, height, data);
}

// --- Icon Design ---

/// Draws the moon and stars design onto the given buffer.
///
/// The design is centered and scaled to fit the buffer dimensions.
/// [scale] is relative to buffer size (1.0 = fill the buffer).
void drawMoonAndStars(PixelBuffer buf,
    {double scale = 0.7,
    int moonR = 255,
    int moonG = 255,
    int moonB = 255}) {
  final size = buf.width.toDouble();
  final center = size / 2.0;

  // Moon parameters (crescent moon facing right)
  final moonRadius = size * scale * 0.35;
  final cutoutRadius = moonRadius * 0.85;
  // Offset the cutout circle to the upper-right to create a crescent
  final cutoutOffsetX = moonRadius * 0.45;
  final cutoutOffsetY = -moonRadius * 0.15;

  // Draw the crescent moon
  buf.drawCrescent(
    center - moonRadius * 0.05,
    center + moonRadius * 0.05,
    moonRadius,
    cutoutRadius,
    cutoutOffsetX,
    cutoutOffsetY,
    r: moonR,
    g: moonG,
    b: moonB,
  );

  // Stars - scattered around the moon
  final random = Random(42); // Fixed seed for reproducibility

  // A few medium 4-pointed stars
  final starPositions = <List<double>>[
    // [x_factor, y_factor, size_factor]
    [0.72, 0.22, 0.035], // top-right
    [0.80, 0.38, 0.025], // right
    [0.75, 0.55, 0.020], // right-center
    [0.30, 0.20, 0.028], // top-left
    [0.22, 0.42, 0.018], // left
    [0.65, 0.78, 0.022], // bottom-right
    [0.35, 0.75, 0.015], // bottom-left
  ];

  for (final pos in starPositions) {
    buf.drawStar(
      size * pos[0],
      size * pos[1],
      size * pos[2],
      r: moonR,
      g: moonG,
      b: moonB,
    );
  }

  // Small dot stars scattered around
  for (var i = 0; i < 15; i++) {
    final angle = random.nextDouble() * 2 * pi;
    final dist = size * (0.25 + random.nextDouble() * 0.22);
    final sx = center + cos(angle) * dist;
    final sy = center + sin(angle) * dist;
    final dotSize = size * (0.004 + random.nextDouble() * 0.006);
    final alpha = 150 + random.nextInt(106);

    // Skip if too close to the moon center
    final dx = sx - center;
    final dy = sy - center;
    if (sqrt(dx * dx + dy * dy) < moonRadius * 1.1) continue;

    buf.drawDot(sx, sy, dotSize, r: moonR, g: moonG, b: moonB, a: alpha);
  }
}

void main() async {
  print('Generating KoiTai app icons...');
  print('');

  // --- 1. App Icon (1024x1024) - Purple background with moon/stars ---
  print('Generating app_icon.png (1024x1024)...');
  final iconBuf = PixelBuffer(1024, 1024);

  // Fill with purple background (#6C3FE0)
  iconBuf.fill(108, 63, 224, 255);

  // Add a subtle radial gradient - slightly lighter in center
  for (var y = 0; y < 1024; y++) {
    for (var x = 0; x < 1024; x++) {
      final dx = x - 512.0;
      final dy = y - 512.0;
      final dist = sqrt(dx * dx + dy * dy) / 512.0;
      // Lighten center slightly
      final lighten = ((1.0 - dist) * 15).clamp(0, 15).toInt();
      final i = (y * 1024 + x) * 4;
      iconBuf.data[i] = (iconBuf.data[i] + lighten).clamp(0, 255);
      iconBuf.data[i + 1] = (iconBuf.data[i + 1] + lighten).clamp(0, 255);
      iconBuf.data[i + 2] = (iconBuf.data[i + 2] + lighten).clamp(0, 255);
    }
  }

  // Draw moon and stars
  drawMoonAndStars(iconBuf);

  final iconPng = iconBuf.toPng();
  await File('assets/icon/app_icon.png').writeAsBytes(iconPng);
  print('  Created assets/icon/app_icon.png (${iconPng.length} bytes)');

  // --- 2. Adaptive Icon Foreground (1024x1024) - Transparent background ---
  print('Generating app_icon_foreground.png (1024x1024)...');
  final fgBuf = PixelBuffer(1024, 1024);
  // Transparent background (all zeros) is the default

  // Draw moon and stars, slightly smaller for adaptive icon safe zone
  // Android adaptive icons have a 66% safe zone, so we scale down
  drawMoonAndStars(fgBuf, scale: 0.50);

  final fgPng = fgBuf.toPng();
  await File('assets/icon/app_icon_foreground.png').writeAsBytes(fgPng);
  print(
      '  Created assets/icon/app_icon_foreground.png (${fgPng.length} bytes)');

  // --- 3. Splash Logo (512x512) - White moon/stars on transparent ---
  print('Generating splash_logo.png (512x512)...');
  final splashBuf = PixelBuffer(512, 512);
  // Transparent background (all zeros) is the default

  // Draw moon and stars
  drawMoonAndStars(splashBuf, scale: 0.65);

  final splashPng = splashBuf.toPng();
  await File('assets/splash/splash_logo.png').writeAsBytes(splashPng);
  print('  Created assets/splash/splash_logo.png (${splashPng.length} bytes)');

  print('');
  print('All icons generated successfully!');
  print('');
  print('Next steps:');
  print('  dart run flutter_launcher_icons');
  print('  dart run flutter_native_splash:create');
}
