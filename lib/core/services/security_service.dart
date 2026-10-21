import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart'; // Deteksi Lokasi & Mock Location
import 'package:safe_device/safe_device.dart'; // Deteksi Root & Emulator

class SecurityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fungsi Utama Pengecekan Keamanan
  /// Mengembalikan true jika AMAN, false jika BERMASALAH.
  Future<bool> checkDeviceSecurity(BuildContext context, String uid) async {
    bool isJailBroken = false;
    bool isRealDevice = true;
    bool isMockLocation = false;

    try {
      // 1. Cek Root / Jailbreak (Menggunakan SafeDevice)
      isJailBroken = await SafeDevice.isJailBroken;

      // 2. Cek Apakah HP Asli atau Emulator (Menggunakan SafeDevice)
      isRealDevice = await SafeDevice.isRealDevice;

      // 3. Cek Fake GPS (Menggunakan Geolocator)
      // Fitur .isMocked hanya akurat di Android. iOS sangat sulit di-fake tanpa komputer.
      try {
        // Pastikan GPS nyala dulu
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (context.mounted) {
            _showSecurityDialog(
              context,
              "GPS Mati",
              "Mohon nyalakan GPS Anda untuk melanjutkan.",
            );
          }
          return false;
        }

        // Ambil lokasi saat ini dengan akurasi tinggi untuk mengecek flag isMocked
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Cek apakah lokasi ini hasil suntikan aplikasi Fake GPS
        isMockLocation = position.isMocked;
      } catch (e) {
        print("Gagal cek Fake GPS: $e");
        // Jika gagal cek (misal sinyal hilang), kita anggap false dulu agar tidak memblokir user
        // atau return false jika ingin strict (ketat).
        isMockLocation = false;
      }
    } catch (e) {
      print("Security Check Error: $e");
      return false; // Jika error parah, anggap tidak aman
    }

    // === EKSEKUSI BLOKIR ===

    // A. Blokir HP Root/Jailbreak (Wajib Blokir)
    if (isJailBroken) {
      if (context.mounted) {
        _showSecurityDialog(
          context,
          "Perangkat Terlarang",
          "HP Anda terdeteksi Root/Jailbreak. Aplikasi tidak dapat dijalankan demi keamanan data perusahaan.",
        );
      }
      return false;
    }

    // B. Blokir Emulator (Kecuali debugging di Windows saat development)
    if (!isRealDevice && !Platform.isWindows) {
      if (context.mounted) {
        _showSecurityDialog(
          context,
          "Emulator Terdeteksi",
          "Dilarang menggunakan Emulator. Harap gunakan HP fisik (Asli).",
        );
      }
      return false;
    }

    // C. Blokir Fake GPS (Sistem Peringatan Bertingkat)
    if (isMockLocation) {
      if (context.mounted) await _handleFakeGPSDetected(uid, context);
      return false;
    }

    return true; // Lulus semua tes keamanan
  }

  /// Logika Penanganan Fake GPS (Counter 1-3)
  Future<void> _handleFakeGPSDetected(String uid, BuildContext context) async {
    try {
      DocumentReference userRef = _db.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userRef.get();

      int fakeCount = 0;
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        fakeCount = data['fake_gps_count'] ?? 0;
      }

      // Tambah Counter Pelanggaran
      fakeCount++;
      await userRef.update({'fake_gps_count': fakeCount});

      // Logika Hukuman
      if (fakeCount >= 3) {
        // Pelanggaran Berat
        if (context.mounted) {
          _showSecurityDialog(
            context,
            "PERINGATAN KERAS! (Pelanggaran #$fakeCount)",
            "Sistem mendeteksi penggunaan Fake GPS berulang kali. Akun Anda telah dilaporkan ke Admin dan Manager sebagai Pelanggaran Berat.",
          );
        }

        // Catat ke database 'pelanggaran' untuk Admin
        await _db.collection('pelanggaran').add({
          'uid': uid,
          'jenis': 'Fake GPS (Berulang)',
          'keterangan': 'Percobaan ke-$fakeCount. Terdeteksi oleh Geolocator.',
          'tanggal': FieldValue.serverTimestamp(),
          'status': 'Menunggu Sanksi',
        });
      } else {
        // Peringatan Ringan
        if (context.mounted) {
          _showSecurityDialog(
            context,
            "Lokasi Palsu Terdeteksi",
            "Mohon matikan aplikasi Fake GPS / Mock Location di HP Anda.\n\nPercobaan curang: $fakeCount dari 3.",
          );
        }
      }
    } catch (e) {
      print("Error handling fake GPS: $e");
    }
  }

  void _showSecurityDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User GABISA tutup dialog dengan klik di luar
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              // Opsional: SystemNavigator.pop(); // Tutup aplikasi paksa
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("SAYA MENGERTI"),
          ),
        ],
      ),
    );
  }
}
