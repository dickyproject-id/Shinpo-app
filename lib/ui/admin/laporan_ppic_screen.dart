import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart'; // FIX: Wajib Import ini agar widget Screenshot dikenali

import '../../core/screenshot_service.dart';

class LaporanPPICScreen extends StatelessWidget {
  // Inisialisasi Service
  final ScreenshotService _screenshotService = ScreenshotService();

  LaporanPPICScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Panjang PPIC"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            // Memanggil fungsi capture dari service
            onPressed: () =>
                _screenshotService.captureAndShare("Laporan_Produksi_Full"),
          ),
        ],
      ),
      // Widget Screenshot membungkus konten yang ingin difoto
      body: Screenshot(
        // Mengakses controller yang ada di dalam _screenshotService
        controller: _screenshotService.screenshotController,
        child: SingleChildScrollView(
          child: Container(
            color: Colors
                .white, // Penting: Background putih agar hasil foto tidak transparan/hitam
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "LAPORAN DETAIL PRODUKSI",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                // Contoh List Panjang
                ListView.builder(
                  shrinkWrap:
                      true, // Wajib true agar bisa discroll oleh SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Matikan scroll ListView, biar ikut scroll induknya
                  itemCount: 50,
                  itemBuilder: (context, index) => ListTile(
                    title: Text("Item Produksi Ke-$index"),
                    subtitle: Text("Status: Good | Mesin: A$index"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
