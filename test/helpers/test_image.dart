import 'dart:convert';
import 'dart:io';

/// A valid 1x1 transparent PNG, base64-encoded — used wherever a widget
/// under test renders `Image.file`, so decoding succeeds instead of
/// throwing on a bogus path.
const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

/// Writes the tiny PNG to a temp file and returns its path. Call the
/// returned cleanup function in `addTearDown` to remove it.
(String path, void Function() cleanup) createTestImageFile() {
  final file = File(
    '${Directory.systemTemp.path}/framee_test_${DateTime.now().microsecondsSinceEpoch}.png',
  );
  file.writeAsBytesSync(base64Decode(_tinyPngBase64));
  return (file.path, () {
    if (file.existsSync()) file.deleteSync();
  });
}
