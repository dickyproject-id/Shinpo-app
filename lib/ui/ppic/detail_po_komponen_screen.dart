import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPoKomponenScreen extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const DetailPoKomponenScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(data['no_po_komponen'] ?? "Detail Komponen"),
          backgroundColor: Colors.indigo,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Laporan Operator"),
              Tab(text: "Gudang Bahan"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: DATA PRODUKSI (Kanan Gambar)
            _buildTabProduksi(),

            // TAB 2: DATA BAHAN (Kiri Gambar)
            _buildTabBahan(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabProduksi() {
    return Column(
      children: [
        // Header Summary (Totalan Realtime)
        Container(
          padding: const EdgeInsets.all(15),
          color: Colors.indigo.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoBox(
                "Target Produksi",
                "${data['target_produksi_pcs']}",
                "Pcs",
              ),
              _infoBox(
                "Hasil Produksi",
                "${data['total_hasil_produksi_pcs']}",
                "Pcs",
              ),
              _infoBox("Barang Bs", "${data['total_bs_pcs']}", "Pcs"),
              _infoBox(
                "Sisa Bahan",
                "${data['total_pemakaian_bahan_kg']}",
                "Kg",
              ), // Placeholder logic
            ],
          ),
        ),
        const Divider(height: 1),

        // List Laporan Harian Operator
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('laporan_produksi')
                .where('po_komponen_id', isEqualTo: docId)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Belum ada data produksi."));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  var item =
                      snapshot.data!.docs[i].data() as Map<String, dynamic>;

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.indigo,
                      child: Text(
                        item['shift'] ?? "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      "${item['nama_operator']} (${item['tanggal']})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _miniTag(Colors.green, "OK: ${item['hasil_pcs']}"),
                            const SizedBox(width: 5),
                            _miniTag(Colors.red, "BS: ${item['bs_pcs']}"),
                            const SizedBox(width: 5),
                            _miniTag(
                              Colors.blue,
                              "CT: ${item['cycle_time_act']}",
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mat: Pakai ${item['pemakaian_shift_kg']}kg | Sisa ${item['sisa_bahan_kg']}kg",
                          style: const TextStyle(fontSize: 11),
                        ),
                        if (item['keterangan'] != null &&
                            item['keterangan'].isNotEmpty)
                          Text(
                            "Note: ${item['keterangan']}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabBahan(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text("Input Kedatangan Bahan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () => _showDialogTambahBahan(context),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('master_po_komponen')
                .doc(docId)
                .collection('log_bahan_masuk')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Belum ada pengiriman bahan."));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, i) {
                  var item =
                      snapshot.data!.docs[i].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(
                      Icons.local_shipping,
                      color: Colors.orange,
                    ),
                    title: Text("${item['jumlah_kg']} Kg"),
                    subtitle: Text("Tgl: ${item['tanggal_terima']}"),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDialogTambahBahan(BuildContext context) {
    final qtyCtrl = TextEditingController();
    final dateCtrl = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Input Bahan Masuk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah (Kg)"),
            ),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(
                labelText: "Tanggal (YYYY-MM-DD)",
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
              double qty = double.tryParse(qtyCtrl.text) ?? 0.0;
              if (qty > 0) {
                // 1. Tambah Log Bahan
                await FirebaseFirestore.instance
                    .collection('master_po_komponen')
                    .doc(docId)
                    .collection('log_bahan_masuk')
                    .add({
                      'jumlah_kg': qty,
                      'tanggal_terima': dateCtrl.text,
                      'created_at': FieldValue.serverTimestamp(),
                    });

                // 2. Update Total Bahan di Header Komponen
                await FirebaseFirestore.instance
                    .collection('master_po_komponen')
                    .doc(docId)
                    .update({
                      'total_kirim_bahan_kg': FieldValue.increment(qty),
                    });

                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String val, String unit) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.indigo,
          ),
        ),
        Text(
          "$label ($unit)",
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _miniTag(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
