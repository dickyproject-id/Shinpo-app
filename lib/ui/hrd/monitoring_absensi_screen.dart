import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonitoringAbsensiScreen extends StatefulWidget {
  const MonitoringAbsensiScreen({super.key});

  @override
  State<MonitoringAbsensiScreen> createState() =>
      _MonitoringAbsensiScreenState();
}

class _MonitoringAbsensiScreenState extends State<MonitoringAbsensiScreen> {
  String _tanggalDipilih = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoring Jam Kerja"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pilihTanggal,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('absensi')
            .where('tanggal', isEqualTo: _tanggalDipilih)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("Tidak ada data absen pada $_tanggalDipilih"),
            );
          }

          var data = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var item = data[index].data() as Map<String, dynamic>;

              // HITUNG JAM KERJA & LEMBUR
              String jamMasuk = item['jam_masuk'] ?? "--:--";
              String jamPulang = item['jam_pulang'] ?? "--:--";

              String durasiKerja = "-";
              bool isLembur = false;
              String jamLembur = "0";

              if (jamMasuk != "--:--" && jamPulang != "--:--") {
                // Logika Sederhana Hitung Durasi
                try {
                  DateTime d1 = DateFormat("HH:mm:ss").parse(jamMasuk);
                  DateTime d2 = DateFormat("HH:mm:ss").parse(jamPulang);
                  Duration diff = d2.difference(d1);
                  int jam = diff.inHours;
                  int menit = diff.inMinutes.remainder(60);
                  durasiKerja = "${jam}h ${menit}m";

                  // Logika Lembur: Jika kerja > 8 Jam (Contoh aturan)
                  if (jam > 8) {
                    isLembur = true;
                    jamLembur = "${jam - 8} Jam";
                  }
                } catch (e) {
                  durasiKerja = "Error";
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      item['nama'][0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    item['nama'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.login, size: 14, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text("Masuk: $jamMasuk"),
                          const SizedBox(width: 15),
                          Icon(Icons.logout, size: 14, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text("Pulang: $jamPulang"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Durasi: $durasiKerja",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          if (isLembur) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Lembur: $jamLembur",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  void _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _tanggalDipilih = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
