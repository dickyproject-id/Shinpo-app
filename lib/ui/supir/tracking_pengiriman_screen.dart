import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../providers/logistik_provider.dart';

class TrackingPengirimanScreen extends StatefulWidget {
  final String docIdSuratJalan;
  const TrackingPengirimanScreen({required this.docIdSuratJalan, super.key});

  @override
  State<TrackingPengirimanScreen> createState() =>
      _TrackingPengirimanScreenState();
}

class _TrackingPengirimanScreenState extends State<TrackingPengirimanScreen> {
  final _bbmController = TextEditingController();

  // Fungsi saat supir sampai di Toko A/B/C
  void _sampaiDiToko(int index, Map<String, dynamic> ruteData) async {
    // FIX: Menggunakan variabel position yang sebelumnya error
    Position position = await Geolocator.getCurrentPosition();

    if (mounted) {
      // Mengirim koordinat Latitude & Longitude ke Provider
      await context.read<LogistikProvider>().updateKunjunganToko(
        widget.docIdSuratJalan,
        index,
        position.latitude,
        position.longitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sampai di ${ruteData['nama_toko']}")),
      );
    }
  }

  void _selesaiTugas() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Laporan Akhir"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _bbmController,
              decoration: const InputDecoration(
                labelText: "Total BBM Terpakai (Liter)",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const Text("Pastikan semua barang sudah diserahterimakan."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              double bbm = double.tryParse(_bbmController.text) ?? 0.0;
              // Panggil Provider selesaikanPengiriman(...)
              context.read<LogistikProvider>().selesaikanPengiriman(
                widget.docIdSuratJalan,
                bbm,
                [], // List update barang (kosongkan dulu jika belum ada logic retur)
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("SELESAI TUGAS"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mode Pengiriman")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pengiriman')
            .doc(widget.docIdSuratJalan)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List rute = data['rute'] ?? [];
          List barang = data['barang'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  title: Text("Plat: ${data['plat_nomor']}"),
                  subtitle: Text("Kenek: ${data['kenek_info']['nama']}"),
                  trailing: Text(
                    data['no_bkb'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Daftar Barang Bawaan:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...barang.map(
                (b) => ListTile(
                  title: Text(b['nama_barang']),
                  trailing: Text("Qty: ${b['qty_kirim']}"),
                  dense: true,
                ),
              ),
              const Divider(height: 40),
              const Text(
                "Rute Perjalanan:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...rute.asMap().entries.map((entry) {
                int idx = entry.key;
                Map toko = entry.value;
                bool isDone = toko['status_kunjungan'] == 'Selesai';

                return Card(
                  color: isDone ? Colors.green.shade100 : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      isDone ? Icons.check_circle : Icons.location_on,
                      color: isDone ? Colors.green : Colors.grey,
                    ),
                    title: Text(toko['nama_toko']),
                    subtitle: Text(toko['alamat']),
                    trailing: isDone
                        ? const Text("Selesai")
                        : ElevatedButton(
                            onPressed: () => _sampaiDiToko(
                              idx,
                              toko as Map<String, dynamic>,
                            ),
                            child: const Text("Sampai"),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 30),
              if (data['status'] != 'Selesai')
                ElevatedButton.icon(
                  onPressed: _selesaiTugas,
                  icon: const Icon(Icons.flag),
                  label: const Text("SELESAI PENGIRIMAN & ISI BBM"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
