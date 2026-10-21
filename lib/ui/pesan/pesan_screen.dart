// lib/ui/pesan/pesan_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class PesanScreen extends StatefulWidget {
  const PesanScreen({super.key});

  @override
  State<PesanScreen> createState() => _PesanScreenState();
}

class _PesanScreenState extends State<PesanScreen> {
  final _pesanController = TextEditingController();
  final _judulController = TextEditingController();

  void _kirimPesan() async {
    final auth = context.read<AuthProvider>();
    if (_pesanController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('pesan').add({
      'judul': _judulController.text,
      'isi': _pesanController.text,
      'pengirim': auth.userData!['nama'],
      'role_pengirim': auth.userData!['role'][0],
      'tanggal': FieldValue.serverTimestamp(),
      'target': 'Semua', // Bisa diubah jadi 'Produksi Only' dll
    });

    _pesanController.clear();
    _judulController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Papan Pesan & Pengumuman")),
      body: Column(
        children: [
          // === LIST PESAN MASUK ===
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesan')
                  .orderBy('tanggal', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("Belum ada pesan."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(data['pengirim'][0])),
                        title: Text(
                          data['judul'] ?? "Pesan",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['isi']),
                            Text(
                              "Oleh: ${data['pengirim']} (${data['role_pengirim']})",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // === FORM KIRIM PESAN ===
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    hintText: "Judul Pengumuman (Opsional)",
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pesanController,
                        decoration: const InputDecoration(
                          hintText: "Tulis pesan untuk tim...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _kirimPesan,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
