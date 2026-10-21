import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MonitoringPengirimanScreen extends StatelessWidget {
  const MonitoringPengirimanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoring Pengiriman"),
        backgroundColor: Colors.orange[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('surat_jalan')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              bool isSelesai = data['status'] == 'Selesai';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelesai ? Colors.green : Colors.orange,
                    child: Icon(
                      isSelesai ? Icons.check : Icons.local_shipping,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['tujuan_toko'] ?? 'Tanpa Tujuan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${data['plat_nomor']} | Supir: ${data['supir']}",
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Detail Barang:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List<dynamic>.from(data['items'] ?? []).map(
                            (item) => Text(
                              "- ${item['nama_barang']} (${item['kode_barang']} - ${item['warna']}) : ${item['qty']} Pcs",
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Divider(),
                          if (isSelesai)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Realisasi Perjalanan:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                                Text(
                                  "Jarak Tempuh: ${data['jarak_tempuh_km']} KM",
                                ),
                                Text(
                                  "Bahan Bakar: ${data['bahan_bakar_liter']} Liter",
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text(
                                  "SELESAIKAN PENGIRIMAN & INPUT BBM",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () =>
                                    _showDialogSelesai(context, doc.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDialogSelesai(BuildContext context, String docId) {
    final jarakCtrl = TextEditingController();
    final bbmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Input Data Realisasi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jarakCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Jarak Tempuh (KM)",
              ),
            ),
            TextField(
              controller: bbmCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Bahan Bakar (Liter)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              double jarak = double.tryParse(jarakCtrl.text) ?? 0;
              double bbm = double.tryParse(bbmCtrl.text) ?? 0;

              await FirebaseFirestore.instance
                  .collection('surat_jalan')
                  .doc(docId)
                  .update({
                    'status': 'Selesai',
                    'jarak_tempuh_km': jarak,
                    'bahan_bakar_liter': bbm,
                    'waktu_selesai': FieldValue.serverTimestamp(),
                  });
              Navigator.pop(ctx);
            },
            child: const Text("Simpan & Selesai"),
          ),
        ],
      ),
    );
  }
}
