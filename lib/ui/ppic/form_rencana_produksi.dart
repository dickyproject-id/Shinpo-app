import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FormRencanaProduksiScreen extends StatefulWidget {
  const FormRencanaProduksiScreen({super.key});

  @override
  State<FormRencanaProduksiScreen> createState() =>
      _FormRencanaProduksiScreenState();
}

class _FormRencanaProduksiScreenState extends State<FormRencanaProduksiScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // === CONTROLLERS (SESUAI GAMBAR BAGIAN KIRI/PPIC) ===
  final _noPoController = TextEditingController(); // No PO Induk
  final _noPoKomponenController = TextEditingController(); // PO Komponen (Unik)
  final _namaBarangController = TextEditingController(); // Nama Barang Jadi
  final _namaKomponenController = TextEditingController(); // Nama Komponen
  final _warnaController = TextEditingController();
  final _planQtyController = TextEditingController(); // Target Produksi (Pcs)
  final _mesinController = TextEditingController(); // Planning Mesin

  Future<void> _simpanRencana() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Simpan ke collection 'master_po'
      // Ini adalah "Header" yang nanti dipilih Operator
      await FirebaseFirestore.instance.collection('master_po').add({
        'no_po': _noPoController.text.toUpperCase(),
        'no_po_komponen': _noPoKomponenController.text.toUpperCase(),
        'nama_barang': _namaBarangController.text.toUpperCase(),
        'nama_komponen': _namaKomponenController.text.toUpperCase(),
        'warna': _warnaController.text.toUpperCase(),
        'target_produksi': int.parse(_planQtyController.text),
        'kode_mesin': _mesinController.text.toUpperCase(),
        'status': 'Open', // Status Open agar muncul di HP Operator
        'created_at': FieldValue.serverTimestamp(),

        // Counter untuk Progress Bar (Diupdate otomatis oleh Operator nanti)
        'total_hasil_bagus': 0,
        'total_bs': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PO Berhasil Diterbitkan!"),
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
        title: const Text("Input Plan PPIC"),
        backgroundColor: Colors.indigo,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Header PO (Data PPIC)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 15),

            // Baris 1: PO Induk & PO Komponen
            Row(
              children: [
                Expanded(child: _buildInput(_noPoController, "No. PO Induk")),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInput(
                    _noPoKomponenController,
                    "No. PO Komponen",
                  ),
                ),
              ],
            ),

            // Baris 2: Nama Barang & Komponen
            _buildInput(_namaBarangController, "Nama Barang Jadi"),
            _buildInput(_namaKomponenController, "Nama Komponen"),

            // Baris 3: Warna & Mesin
            Row(
              children: [
                Expanded(child: _buildInput(_warnaController, "Warna")),
                const SizedBox(width: 10),
                Expanded(child: _buildInput(_mesinController, "Plan Mesin")),
              ],
            ),

            // Baris 4: Target
            _buildInput(_planQtyController, "Target Qty (Pcs)", isNumber: true),

            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _simpanRencana,
                icon: const Icon(Icons.save),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("TERBITKAN PO"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
      ),
    );
  }
}
