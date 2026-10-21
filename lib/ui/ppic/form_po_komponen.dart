import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormPoKomponenScreen extends StatefulWidget {
  final String parentPoId;
  final String parentPoName;
  final String? docId; // Null jika baru, Ada jika edit
  final Map<String, dynamic>? currentData;

  const FormPoKomponenScreen({
    super.key,
    required this.parentPoId,
    required this.parentPoName,
    this.docId,
    this.currentData,
  });

  @override
  State<FormPoKomponenScreen> createState() => _FormPoKomponenScreenState();
}

class _FormPoKomponenScreenState extends State<FormPoKomponenScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaKomponenCtrl = TextEditingController();
  final _noPoKomponenCtrl = TextEditingController();

  // Field Optional
  final _baseQtyCtrl = TextEditingController();
  final _planningQtyCtrl = TextEditingController();
  final _stockSisaCtrl = TextEditingController();
  final _orderCetakCtrl = TextEditingController();

  // Detail Teknis
  final _noMesinCtrl = TextEditingController();
  final _beratStdCtrl = TextEditingController();
  final _pesananPcsCtrl = TextEditingController();
  final _targetProdCtrl = TextEditingController();
  final _cycletimeStdCtrl = TextEditingController();
  final _cavityCtrl = TextEditingController();
  final _warnaBarangCtrl = TextEditingController();
  final _namaBahanCtrl = TextEditingController();
  final _mintaBahanCtrl = TextEditingController(); // Kg

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi data jika mode edit
    if (widget.currentData != null) {
      var d = widget.currentData!;
      _namaKomponenCtrl.text = d['nama_komponen'];
      _noPoKomponenCtrl.text = d['no_po_komponen'];
      _baseQtyCtrl.text = (d['base_qty_dus'] ?? 0).toString();
      _planningQtyCtrl.text = (d['planning_qty_pcs'] ?? 0).toString();
      _stockSisaCtrl.text = (d['stock_sisa_packing_pcs'] ?? 0).toString();
      _orderCetakCtrl.text = (d['order_cetak_po_pcs'] ?? 0).toString();

      _noMesinCtrl.text = d['nomor_mesin'];
      _beratStdCtrl.text = (d['berat_std_gr'] ?? 0).toString();
      _pesananPcsCtrl.text = (d['pesanan_pcs'] ?? 0).toString();
      _targetProdCtrl.text = (d['target_produksi_pcs'] ?? 0).toString();
      _cycletimeStdCtrl.text = (d['cycletime_std_detik'] ?? 0).toString();
      _cavityCtrl.text = (d['cavity_pcs'] ?? 0).toString();
      _warnaBarangCtrl.text = d['warna_barang'];
      _namaBahanCtrl.text = d['nama_bahan'];
      _mintaBahanCtrl.text = (d['minta_bahan_kg'] ?? 0).toString();
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> data = {
        'nama_komponen': _namaKomponenCtrl.text.toUpperCase(),
        'no_po_komponen': _noPoKomponenCtrl.text.toUpperCase(),

        // Field Optional (Jika kosong dianggap 0)
        'base_dus_qty': int.tryParse(_baseQtyCtrl.text) ?? 0,
        'planning_qty_pcs': int.tryParse(_planningQtyCtrl.text) ?? 0,
        'stock_sisa_packing_pcs': int.tryParse(_stockSisaCtrl.text) ?? 0,
        'order_cetak_po_pcs': int.tryParse(_orderCetakCtrl.text) ?? 0,

        // Detail Teknis
        'nomor_mesin': _noMesinCtrl.text.toUpperCase(),
        'berat_std_gr': double.tryParse(_beratStdCtrl.text) ?? 0.0,
        'pesanan_gr': double.tryParse(_pesananPcsCtrl.text) ?? 0.0,
        'target_produksi_pcs': int.tryParse(_targetProdCtrl.text) ?? 0,
        'cycletime_std_detik': double.tryParse(_cycletimeStdCtrl.text) ?? 0.0,
        'cavity_pcs': int.tryParse(_cavityCtrl.text) ?? 0,
        'warna_barang': _warnaBarangCtrl.text.toUpperCase(),
        'nama_bahan': _namaBahanCtrl.text.toUpperCase(),
        'minta_bahan_kg': double.tryParse(_mintaBahanCtrl.text) ?? 0.0,
      };

      if (widget.docId == null) {
        // Mode Tambah
        data['parent_po_id'] = widget.parentPoId;
        data['parent_po_name'] = widget.parentPoName;
        data['tanggal_po_komponen'] = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());
        data['status'] = 'Open';
        data['created_at'] = FieldValue.serverTimestamp();
        // Inisialisasi Counter
        data['total_hasil_produksi_pcs'] = 0;
        data['total_pemakaian_bahan_kg'] = 0.0;
        data['total_kirim_bahan_kg'] = 0.0;
        data['total_tambahan_pcs'] = 0;
        data['total_berat_hasil_kg'] = 0.0;
        data['total_bs_pcs'] = 0;
        data['total_berat_bs_kg'] = 0.0;
        data['total_berat_cc_kg'] = 0.0;
        data['total_runner_kg'] = 0.0;

        await FirebaseFirestore.instance
            .collection('master_po_komponen')
            .add(data);
      } else {
        // Mode Edit
        await FirebaseFirestore.instance
            .collection('master_po_komponen')
            .doc(widget.docId)
            .update(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.docId == null
                  ? "Komponen Ditambahkan!"
                  : "Komponen Diupdate!",
            ),
          ),
        );
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
    bool isEdit = widget.docId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Komponen" : "Tambah Komponen"),
        backgroundColor: Colors.indigo,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (isEdit)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(10),
                color: Colors.orange.shade50,
                child: const Text(
                  "⚠️ Mode Edit: Pastikan data benar sebelum disimpan.",
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            _section("Info Utama Komponen"),
            _input(_namaKomponenCtrl, "Nama Komponen"),
            _input(_noPoKomponenCtrl, "No. PO Komponen"),

            // FIELD OPTIONAL
            Row(
              children: [
                Expanded(
                  child: _input(
                    _baseQtyCtrl,
                    "Base Qty (Pcs)",
                    isNum: true,
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _input(
                    _planningQtyCtrl,
                    "Planning Qty (Pcs)",
                    isNum: true,
                    isRequired: false,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _input(
                    _stockSisaCtrl,
                    "Stock Sisa Packing",
                    isNum: true,
                    isRequired: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _input(
                    _orderCetakCtrl,
                    "Order Cetak PO",
                    isNum: true,
                    isRequired: false,
                  ),
                ),
              ],
            ),

            _section("Detail Teknis & Mesin"),
            Row(
              children: [
                Expanded(child: _input(_noMesinCtrl, "Nomor Mesin")),
                const SizedBox(width: 10),
                Expanded(child: _input(_warnaBarangCtrl, "Warna Barang")),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _input(
                    _beratStdCtrl,
                    "Berat Standar (Gr)",
                    isNum: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _input(_pesananPcsCtrl, "Pesanan (Pcs)", isNum: true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _input(
                    _targetProdCtrl,
                    "Target Produksi(Pcs)",
                    isNum: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _input(
                    _cycletimeStdCtrl,
                    "Cycletime Standar (Detik)",
                    isNum: true,
                  ),
                ),
              ],
            ),
            _input(_cavityCtrl, "Cavity (Pcs)", isNum: true),

            _section("Bahan Baku"),
            _input(_namaBahanCtrl, "Nama Bahan"),
            _input(_mintaBahanCtrl, "Minta Bahan (Kg)", isNum: true),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _simpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.all(15),
              ),
              child: Text(isEdit ? "UPDATE KOMPONEN" : "SIMPAN KOMPONEN"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.indigo,
        ),
      ),
    );
  }

  // UPDATED HELPER: Mendukung Auto Kapital & Optional
  Widget _input(
    TextEditingController ctrl,
    String label, {
    bool isNum = false,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        // === LOGIKA AUTO KAPITAL ===
        textCapitalization: isNum
            ? TextCapitalization.none
            : TextCapitalization.characters,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label + (isRequired ? "*" : ""),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (v) {
          if (!isRequired) return null;
          return (v == null || v.isEmpty) ? "Wajib diisi" : null;
        },
      ),
    );
  }
}
