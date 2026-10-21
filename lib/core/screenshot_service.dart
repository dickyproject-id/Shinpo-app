import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart'; // Wajib import ini
import 'package:share_plus/share_plus.dart';

class ScreenshotService {
  // Mendefinisikan controller agar bisa diakses dari luar (public)
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> captureAndShare(String fileName) async {
    try {
      // Menangkap gambar
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File(
          '${directory.path}/$fileName.png',
        ).create();
        await imagePath.writeAsBytes(imageBytes);

        // Share file
        await Share.shareXFiles([
          XFile(imagePath.path),
        ], text: 'Laporan Monitoring');
      }
    } catch (e) {
      print("Error Screenshot: $e");
    }
  }
}
