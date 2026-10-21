import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormSuratJalanScreen extends StatefulWidget {
  const FormSuratJalanScreen({super.key});

  @override
  State<FormSuratJalanScreen> createState() => _FormSuratJalanScreenState();
}

class _FormSuratJalanScreenState extends State<FormSuratJalanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noSurat = TextEditingController();
  final TextEditingController _tujuan = TextEditingController();
  final TextEditingController _alamat = TextEditingController();
  final TextEditingController _supir = TextEditingController();
  final TextEditingController _kenek = TextEditingController();
  final TextEditingController _plat = TextEditingController();

  final List<_ItemBarangRow> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _noSurat.text = "SJ-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}";
    _tambahItem();
  }

  void _tambahItem() {
    setState(() => _items.add(_ItemBarangRow()));
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> itemsData = _items
          .map(
            (e) => {
              'nama_barang': e.nama.text,
              'kode_barang': e.kode.text,
              'warna': e.warna.text,
              'qty': int.tryParse(e.qty.text) ?? 0,
            },
          )
          .toList();

      await FirebaseFirestore.instance.collection('surat_jalan').add({
        'nomor_surat': _noSurat.text,
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'tujuan_toko': _tujuan.text,
        'alamat': _alamat.text,
        'supir': _supir.text,
        'kenek': _kenek.text,
        'plat_nomor': _plat.text,
        'items': itemsData,
        'status': 'Dalam Pengiriman',
        'created_at': FieldValue.serverTimestamp(),
        // Field kosong untuk diisi nanti saat pulang
        'jarak_tempuh_km': 0.0,
        'bahan_bakar_liter': 0.0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Surat Jalan Terbit!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Surat Jalan"),
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection("Info Pengiriman"),
            TextFormField(
              controller: _noSurat,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "No Surat",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _tujuan,
              decoration: const InputDecoration(
                labelText: "Toko Tujuan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _alamat,
              decoration: const InputDecoration(
                labelText: "Alamat Lengkap",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            _buildSection("Armada & Kru"),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _supir,
                    decoration: const InputDecoration(
                      labelText: "Nama Supir",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _kenek,
                    decoration: const InputDecoration(
                      labelText: "Nama Kenek",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _plat,
              decoration: const InputDecoration(
                labelText: "Plat Nomor",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSection("Daftar Barang"),
                TextButton.icon(
                  onPressed: _tambahItem,
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Item"),
                ),
              ],
            ),

            ..._items.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return Card(
                color: Colors.grey[50],
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: item.nama,
                              decoration: const InputDecoration(
                                labelText: "Nama Barang",
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                setState(() => _items.removeAt(idx)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: item.kode,
                              decoration: const InputDecoration(
                                labelText: "Kode",
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextFormField(
                              controller: item.warna,
                              decoration: const InputDecoration(
                                labelText: "Warna",
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextFormField(
                              controller: item.qty,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Qty",
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "TERBITKAN SURAT JALAN",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) => Text(
    title,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.teal[800],
      fontSize: 16,
    ),
  );
}

class _ItemBarangRow {
  final TextEditingController nama = TextEditingController();
  final TextEditingController kode = TextEditingController();
  final TextEditingController warna = TextEditingController();
  final TextEditingController qty = TextEditingController();
}
