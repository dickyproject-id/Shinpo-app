import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class GudangKardusScreen extends StatefulWidget {
  const GudangKardusScreen({super.key});

  @override
  State<GudangKardusScreen> createState() => _GudangKardusScreenState();
}

class _GudangKardusScreenState extends State<GudangKardusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _ketController = TextEditingController();

  String _jenisMutasi = 'Masuk';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _simpanMutasi() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().userData;
    String namaBarang = _namaBarangController.text.toUpperCase();
    int qtyInput = int.parse(_qtyController.text);

    try {
      final batch = FirebaseFirestore.instance.batch();
      DocumentReference stokRef = FirebaseFirestore.instance
          .collection('stok_kardus')
          .doc(namaBarang);

      var docSnapshot = await stokRef.get();
      int stokLama = 0;
      if (docSnapshot.exists) {
        stokLama =
            (docSnapshot.data() as Map<String, dynamic>)['qty_sisa'] ?? 0;
      }

      if (_jenisMutasi == 'Keluar' && stokLama < qtyInput) {
        throw "Stok tidak cukup! Sisa: $stokLama";
      }

      int stokBaru = (_jenisMutasi == 'Masuk')
          ? (stokLama + qtyInput)
          : (stokLama - qtyInput);

      batch.set(stokRef, {
        'nama_barang': namaBarang,
        'qty_sisa': stokBaru,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      DocumentReference riwayatRef = FirebaseFirestore.instance
          .collection('riwayat_stok_kardus')
          .doc();
      batch.set(riwayatRef, {
        'nama_barang': namaBarang,
        'jenis': _jenisMutasi,
        'qty': qtyInput,
        'sisa_stok': stokBaru,
        'keterangan': _ketController.text,
        'admin': user?['nama'],
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'created_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Stok Berhasil Diupdate!"),
            backgroundColor: Colors.green,
          ),
        );
        _namaBarangController.clear();
        _qtyController.clear();
        _ketController.clear();
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Stok Kardus"),
        backgroundColor: Colors.brown,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Sisa Stok"),
            Tab(text: "Input Data"),
            Tab(text: "Riwayat"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: SISA STOK
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stok_kardus')
                .orderBy('nama_barang')
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: snap.data!.docs.length,
                itemBuilder: (ctx, i) {
                  var d = snap.data!.docs[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.brown),
                      title: Text(d['nama_barang']),
                      trailing: Text(
                        "${d['qty_sisa']} Pcs",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // TAB 2: INPUT
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Masuk"),
                          value: 'Masuk',
                          groupValue: _jenisMutasi,
                          onChanged: (v) =>
                              setState(() => _jenisMutasi = v.toString()),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Keluar"),
                          value: 'Keluar',
                          groupValue: _jenisMutasi,
                          onChanged: (v) =>
                              setState(() => _jenisMutasi = v.toString()),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _namaBarangController,
                    decoration: const InputDecoration(
                      labelText: "Tipe Kardus / Nama Barang",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Jumlah (Qty)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _ketController,
                    decoration: const InputDecoration(
                      labelText: "Keterangan",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _simpanMutasi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SIMPAN",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAB 3: RIWAYAT
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('riwayat_stok_kardus')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: snap.data!.docs.length,
                itemBuilder: (ctx, i) {
                  var d = snap.data!.docs[i];
                  bool masuk = d['jenis'] == 'Masuk';
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        masuk ? Icons.arrow_downward : Icons.arrow_upward,
                        color: masuk ? Colors.green : Colors.red,
                      ),
                      title: Text(d['nama_barang']),
                      subtitle: Text(
                        "${d['tanggal']} | Ket: ${d['keterangan']}",
                      ),
                      trailing: Text(
                        "${masuk ? '+' : '-'}${d['qty']}",
                        style: TextStyle(
                          color: masuk ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
