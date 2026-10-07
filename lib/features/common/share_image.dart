import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Renders the widget under [key] (wrapped in a [RepaintBoundary]) to a PNG
/// and opens the platform share sheet. Returns false if capture failed.
Future<bool> shareBoundaryAsImage(GlobalKey key, {String name = 'hydra-recap'}) async {
  try {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return false;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return false;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name.png');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    return true;
  } catch (_) {
    return false;
  }
}
