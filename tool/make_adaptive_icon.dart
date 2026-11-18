// Generates the three Android adaptive-icon layers from the supplied artwork.
//
//   assets/icon/ic_background.png  – the original, full bleed (no ring, no white)
//   assets/icon/ic_foreground.png  – the black tally artwork only, transparent
//   assets/icon/ic_monochrome.png  – the same silhouette for themed icons
//
// Run with:   dart run tool/make_adaptive_icon.dart
//
// The tally artwork is the interior shape: ink that does not reach the canvas
// border. The foreground is centred and scaled to <= 58% of the 108dp canvas
// (inside the 66dp safe zone). A report is written to build/icon_report.txt.

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// The adaptive-icon canvas at 4x (108dp × 4).
const int kCanvas = 432;

/// Safe zone as a fraction of the 108dp canvas.
const double kSafeZone = 0.611;

/// Fraction of the canvas the foreground artwork may occupy.
const double kArtworkFill = 0.58;

/// Luminance at or below which a pixel is solid ink.
const double kInkDark = 70;

/// Luminance at or above which a pixel is pure background.
const double kInkClear = 170;

/// Below this alpha a pixel counts as transparent, never as ink.
const int kMinAlpha = 16;

/// The app's lime, used only if the artwork yields no background colour.
const int kFallbackBackground = 0x9BE15D;

double _lum(num r, num g, num b) =>
    0.299 * r.toDouble() + 0.587 * g.toDouble() + 0.114 * b.toDouble();

int _inkAlpha(img.Pixel p) {
  final a = p.a.toInt();
  if (a < kMinAlpha) return 0;
  final l = _lum(p.r, p.g, p.b);
  final int base;
  if (l <= kInkDark) {
    base = 255;
  } else if (l >= kInkClear) {
    base = 0;
  } else {
    base = (255 * (kInkClear - l) / (kInkClear - kInkDark)).round();
  }
  return (base * a / 255).round();
}

String _hex(List<int> c) =>
    '#${c.map((v) => v.toRadixString(16).padLeft(2, '0')).join()}';

int _fill(
  int seed,
  List<int> mask,
  List<bool> blocked,
  List<bool> visited,
  int w,
  int h, {
  void Function(int index)? onVisit,
}) {
  final queue = <int>[seed];
  visited[seed] = true;
  var count = 0;
  var head = 0;
  while (head < queue.length) {
    final index = queue[head++];
    count++;
    onVisit?.call(index);
    final x = index % w;
    final y = index ~/ w;
    if (x > 0 && !blocked[index - 1] && !visited[index - 1] && mask[index - 1] > 8) {
      visited[index - 1] = true;
      queue.add(index - 1);
    }
    if (x < w - 1 && !blocked[index + 1] && !visited[index + 1] && mask[index + 1] > 8) {
      visited[index + 1] = true;
      queue.add(index + 1);
    }
    if (y > 0 && !blocked[index - w] && !visited[index - w] && mask[index - w] > 8) {
      visited[index - w] = true;
      queue.add(index - w);
    }
    if (y < h - 1 && !blocked[index + w] && !visited[index + w] && mask[index + w] > 8) {
      visited[index + w] = true;
      queue.add(index + w);
    }
  }
  return count;
}

void main() {
  final source = File('assets/icon/app_icon.png');
  final decoded = img.decodeImage(source.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode ${source.path}');
    exit(2);
  }
  final src = decoded.convert(numChannels: 4);
  final w = src.width;
  final h = src.height;

  final mask = List<int>.filled(w * h, 0);
  final bgCounts = <int, int>{};
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = src.getPixel(x, y);
      final ink = _inkAlpha(p);
      mask[y * w + x] = ink;
      if (ink > 8) continue;
      final key = ((p.r.toInt() >> 4) << 8) |
          ((p.g.toInt() >> 4) << 4) |
          (p.b.toInt() >> 4);
      bgCounts[key] = (bgCounts[key] ?? 0) + 1;
    }
  }

  var bgKey = -1;
  var bgBest = -1;
  bgCounts.forEach((k, c) {
    if (c > bgBest) {
      bgBest = c;
      bgKey = k;
    }
  });
  final List<int> bgColor = bgKey < 0
      ? <int>[
          (kFallbackBackground >> 16) & 0xFF,
          (kFallbackBackground >> 8) & 0xFF,
          kFallbackBackground & 0xFF,
        ]
      : <int>[
          ((bgKey >> 8) & 0xF) * 17,
          ((bgKey >> 4) & 0xF) * 17,
          (bgKey & 0xF) * 17,
        ];

  final surround = List<bool>.filled(w * h, false);
  final seen = List<bool>.filled(w * h, false);
  var surroundCount = 0;
  void addBorder(int index) {
    if (mask[index] > 8 && !seen[index]) {
      surroundCount += _fill(index, mask, surround, seen, w, h, onVisit: (i) {
        surround[i] = true;
      });
    }
  }
  for (var x = 0; x < w; x++) {
    addBorder(x);
    addBorder((h - 1) * w + x);
  }
  for (var y = 0; y < h; y++) {
    addBorder(y * w);
    addBorder(y * w + w - 1);
  }

  final visited = List<bool>.filled(w * h, false);
  for (var i = 0; i < w * h; i++) {
    if (surround[i]) visited[i] = true;
  }
  var bestSeed = -1;
  var bestSize = 0;
  var islands = 0;
  for (var i = 0; i < w * h; i++) {
    if (mask[i] <= 8 || visited[i]) continue;
    final size = _fill(i, mask, surround, visited, w, h);
    islands++;
    if (size > bestSize) {
      bestSize = size;
      bestSeed = i;
    }
  }
  if (bestSeed < 0) {
    stderr.writeln('No artwork found outside border ink');
    exit(3);
  }

  final islandVisited = List<bool>.filled(w * h, false);
  var minX = w, minY = h, maxX = -1, maxY = -1;
  _fill(bestSeed, mask, surround, islandVisited, w, h, onVisit: (i) {
    final x = i % w;
    final y = i ~/ w;
    if (x < minX) minX = x;
    if (y < minY) minY = y;
    if (x > maxX) maxX = x;
    if (y > maxY) maxY = y;
  });

  final background = img.Image(width: kCanvas, height: kCanvas, numChannels: 3);
  for (var y = 0; y < kCanvas; y++) {
    for (var x = 0; x < kCanvas; x++) {
      background.setPixelRgb(x, y, bgColor[0], bgColor[1], bgColor[2]);
    }
  }
  File('assets/icon/ic_background.png')
      .writeAsBytesSync(img.encodePng(background));

  final bw = maxX - minX + 1;
  final bh = maxY - minY + 1;
  final bleedScale = kCanvas / math.max(w, h);
  final limitScale = (kCanvas * kArtworkFill) / math.max(bw, bh);
  final scale = math.min(bleedScale, limitScale);
  final dw = math.max(1, (bw * scale).round());
  final dh = math.max(1, (bh * scale).round());

  final ink = img.Image(width: bw, height: bh, numChannels: 4);
  for (var y = 0; y < bh; y++) {
    for (var x = 0; x < bw; x++) {
      final idx = (minY + y) * w + (minX + x);
      ink.setPixelRgba(x, y, 0, 0, 0, surround[idx] ? 0 : mask[idx]);
    }
  }
  final scaled = img.copyResize(ink, width: dw, height: dh, interpolation: img.Interpolation.cubic);
  final foreground = img.Image(width: kCanvas, height: kCanvas, numChannels: 4);
  final dx = ((kCanvas - dw) / 2).round();
  final dy = ((kCanvas - dh) / 2).round();
  for (var y = 0; y < dh; y++) {
    for (var x = 0; x < dw; x++) {
      final a = scaled.getPixel(x, y).a.toInt();
      if (a > 0) {
        foreground.setPixelRgba(dx + x, dy + y, 0, 0, 0, a);
      }
    }
  }
  File('assets/icon/ic_foreground.png').writeAsBytesSync(img.encodePng(foreground));
  File('assets/icon/ic_monochrome.png').writeAsBytesSync(img.encodePng(foreground));

  final log = StringBuffer();
  void logLine(String s) {
    stdout.writeln(s);
    log.writeln(s);
  }
  logLine('source: ${w}x$h');
  logLine('background: ${_hex(bgColor)}');
  logLine('border-ink pixels removed: $surroundCount');
  logLine('islands outside border: $islands; artwork island size $bestSize px');
  logLine('artwork bounds: $minX,$minY..$maxX,$maxY (${bw}x$bh)');
  logLine('scale: ${scale.toStringAsFixed(4)}; size ${dw}x$dh at $dx,$dy');
  logLine('cover: ${((math.max(dw, dh) / kCanvas) * 100).toStringAsFixed(1)}% of 108dp canvas '
      '(safe <= ${kSafeZone * 100}%)');
  File('build/icon_report.txt').parent.createSync(recursive: true);
  File('build/icon_report.txt').writeAsStringSync(log.toString());
}
