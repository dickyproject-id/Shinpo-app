import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'detail_po_komponen_screen.dart';
import 'form_po_induk.dart';
import 'form_po_komponen.dart';

class PpicDashboardScreen extends StatelessWidget {
  const PpicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard PPIC"),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text("PO Induk Baru"),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormPoIndukScreen()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('master_po_induk')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String tglBuat = _formatDate(data['created_at']);
              bool isOpen = data['status'] == 'Open';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: isOpen
                        ? Colors.indigo.shade100
                        : Colors.grey.shade300,
                    child: Icon(
                      Icons.folder,
                      color: isOpen ? Colors.indigo : Colors.grey,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['no_po_induk'] ?? "-",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.black : Colors.grey,
                        ),
                      ),
                      _buildStatusChip(isOpen),
                    ],
                  ),
                  subtitle: Text("${data['nama_barang']}\nDibuat: $tglBuat"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuInduk(context, value, doc.id, data),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status',
                        child: Row(
                          children: [
                            Icon(
                              isOpen ? Icons.lock : Icons.lock_open,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(isOpen ? "Close PO" : "Open PO"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Hapus", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    // LIST PO KOMPONEN
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('master_po_komponen')
                          .where('parent_po_id', isEqualTo: doc.id)
                          .snapshots(),
                      builder: (ctx, snapKomponen) {
                        if (!snapKomponen.hasData) {
                          return const LinearProgressIndicator();
                        }
                        var listKomp = snapKomponen.data!.docs;

                        return Column(
                          children: [
                            if (listKomp.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Belum ada komponen.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),

                            ...listKomp.map((kDoc) {
                              var kData = kDoc.data() as Map<String, dynamic>;
                              String tglKomp = _formatDate(kData['created_at']);
                              bool isKompOpen = kData['status'] == 'Open';

                              int target = kData['target_produksi_pcs'] ?? 1;
                              int actual =
                                  kData['total_hasil_produksi_pcs'] ?? 0;
                              double progress = (target > 0)
                                  ? (actual / target).clamp(0.0, 1.0)
                                  : 0.0;

                              return ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 20,
                                  right: 0,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        kData['nama_komponen'] ?? "-",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isKompOpen
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    if (!isKompOpen)
                                      const Icon(
                                        Icons.lock,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mesin: ${kData['nomor_mesin']} | Tgl: $tglKomp",
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[200],
                                      color: isKompOpen
                                          ? Colors.green
                                          : Colors.grey,
                                      minHeight: 4,
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FormPoKomponenScreen(
                                            parentPoId: doc.id,
                                            parentPoName: data['no_po_induk'],
                                            docId: kDoc.id,
                                            currentData: kData,
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 18,
                                      ),
                                      onSelected: (val) => _handleMenuKomponen(
                                        context,
                                        val,
                                        kDoc.id,
                                        kData,
                                      ),
                                      itemBuilder: (ctx) => [
                                        PopupMenuItem(
                                          value: 'status',
                                          child: Text(
                                            isKompOpen
                                                ? "Close Komponen"
                                                : "Open Komponen",
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            "Hapus",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailPoKomponenScreen(
                                      docId: kDoc.id,
                                      data: kData,
                                    ),
                                  ),
                                ),
                              );
                            }),

                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text("Tambah Komponen"),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FormPoKomponenScreen(
                                        parentPoId: doc.id,
                                        parentPoName: data['no_po_induk'],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
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

  // === HELPERS & LOGIC ===

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    if (timestamp is Timestamp) {
      return DateFormat('dd/MM/yy').format(timestamp.toDate());
    }
    return "-";
  }

  Widget _buildStatusChip(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isOpen ? "OPEN" : "CLOSED",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleMenuInduk(
    BuildContext context,
    String value,
    String docId,
    Map<String, dynamic> data,
  ) {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FormPoIndukScreen(docId: docId, currentData: data),
        ),
      );
    } else if (value == 'status') {
      bool newStatus = data['status'] == 'Open' ? false : true;
      FirebaseFirestore.instance
          .collection('master_po_induk')
          .doc(docId)
          .update({'status': newStatus ? 'Open' : 'Closed'});
    } else if (value == 'delete') {
      _confirmDelete(context, 'master_po_induk', docId);
    }
  }

  void _handleMenuKomponen(
    BuildContext context,
    String value,
    String docId,
    Map<String, dynamic> data,
  ) {
    if (value == 'status') {
      bool newStatus = data['status'] == 'Open' ? false : true;
      FirebaseFirestore.instance
          .collection('master_po_komponen')
          .doc(docId)
          .update({'status': newStatus ? 'Open' : 'Closed'});
    } else if (value == 'delete') {
      _confirmDelete(context, 'master_po_komponen', docId);
    }
  }

  void _confirmDelete(BuildContext context, String collection, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection(collection)
                  .doc(docId)
                  .delete();
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
