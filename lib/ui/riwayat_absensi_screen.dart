// lib/ui/riwayat_absensi_screen.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class RiwayatAbsensiScreen extends StatelessWidget {
  const RiwayatAbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;

    // Jika user belum login/data null
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Absensi Saya"),
        backgroundColor: Colors.blue[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data dari collection 'absensi' khusus user yang login
        stream: FirebaseFirestore.instance
            .collection('absensi')
            .where('uid', isEqualTo: user['uid'])
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Belum ada riwayat absensi.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Parsing Data
              String tanggal = _formatTanggalIndo(
                data['tanggal'] ?? "2024-01-01",
              );
              String jamMasuk = data['jam_masuk'] ?? "--:--";
              String jamPulang = data['jam_pulang'] ?? "--:--";

              // === PERBAIKAN DI SINI ===
              // Variabel status sekarang dipakai untuk menentukan warna & label Chip
              String status = data['status_kehadiran'] ?? "Alpha";
              Color statusColor = status == 'Hadir'
                  ? Colors.green
                  : Colors.orange;

              // Foto (Base64 String)
              String? fotoMasukBase64 = data['foto_wajah_masuk'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FOTO WAJAH (KIRI) ---
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          image:
                              fotoMasukBase64 != null &&
                                  fotoMasukBase64.isNotEmpty
                              ? DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(fotoMasukBase64),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            fotoMasukBase64 == null || fotoMasukBase64.isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),

                      const SizedBox(width: 15),

                      // --- DATA JAM (TENGAH) ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tanggal,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                // Menampilkan Status di UI agar variabel terpakai
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTimeChip("Masuk", jamMasuk, Colors.green),
                                const SizedBox(width: 10),
                                _buildTimeChip("Pulang", jamPulang, Colors.red),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (data['jam_istirahat_mulai'] != null)
                              Text(
                                "Istirahat: ${data['jam_istirahat_mulai']} - ${data['jam_istirahat_selesai'] ?? '...'}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget Kecil untuk Tampilan Jam
  Widget _buildTimeChip(String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            "$label: $time",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Format Tanggal (yyyy-MM-dd -> Senin, 12 Jan 2025)
  String _formatTanggalIndo(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return rawDate;
    }
  }
}
