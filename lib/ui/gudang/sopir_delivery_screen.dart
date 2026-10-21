// lib/ui/gudang/supir_delivery_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SupirDeliveryScreen extends StatefulWidget {
  const SupirDeliveryScreen({super.key});

  @override
  State<SupirDeliveryScreen> createState() => _SupirDeliveryScreenState();
}

class _SupirDeliveryScreenState extends State<SupirDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mode Supir / Jalan"),
        backgroundColor: Colors.blueAccent[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Menampilkan Surat Jalan yang statusnya masih 'Dalam Pengiriman'
        stream: FirebaseFirestore.instance
            .collection('surat_jalan')
            .where('status', isEqualTo: 'Dalam Pengiriman')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Tidak ada tugas pengiriman aktif."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Kartu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              data['nomor_surat'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          Text(
                            data['tanggal'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Info Tujuan
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(child: Icon(Icons.store)),
                        title: Text(
                          data['tujuan_toko'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "Alamat: ${data['alamat_tujuan'] ?? '-'}",
                        ),
                      ),
                      const Divider(),

                      const Text(
                        "Barang yang harus diturunkan:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // List Barang (Preview)
                      ...List<dynamic>.from(data['items'] ?? []).map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama_barang'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Kode: ${item['kode_barang']} | Warna: ${item['warna']}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "${item['qty']} Pcs",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("BARANG SAMPAI / KONFIRMASI"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () => _showKonfirmasiDialog(
                            context,
                            doc.id,
                            data['items'],
                          ),
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

  // Dialog untuk Supir Konfirmasi Jumlah Aktual
  void _showKonfirmasiDialog(
    BuildContext context,
    String docId,
    List<dynamic> items,
  ) {
    // Kita buat copy items agar bisa diedit qty-nya (jika ada barang rusak/ditolak)
    List<Map<String, dynamic>> itemsConfirm = List<Map<String, dynamic>>.from(
      items.map((e) => Map<String, dynamic>.from(e)),
    );
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Penerimaan"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Silakan cek jumlah barang yang diterima toko:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                // Form Edit Qty per Item
                ...itemsConfirm.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_barang'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "${item['kode_barang']} - ${item['warna']}",
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              initialValue: item['qty'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Qty Trm",
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                // Update jumlah diterima
                                itemsConfirm[idx]['qty_diterima'] =
                                    int.tryParse(val) ?? 0;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: "Catatan Supir / Toko",
                    hintText: "Misal: Penerima Pak Budi",
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Update Status jadi 'Selesai Terkirim'
              // 2. Simpan Qty Aktual yang diterima toko
              await FirebaseFirestore.instance
                  .collection('surat_jalan')
                  .doc(docId)
                  .update({
                    'status': 'Selesai Terkirim',
                    'items_aktual':
                        itemsConfirm, // Data barang yang sudah dicek supir
                    'catatan_supir': noteCtrl.text,
                    'waktu_sampai': FieldValue.serverTimestamp(),
                  });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Laporan Terkirim!")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Selesai Kirim"),
          ),
        ],
      ),
    );
  }
}
