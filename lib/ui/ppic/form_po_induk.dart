import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormPoIndukScreen extends StatefulWidget {
  final String? docId; // Jika null = Mode Tambah, Jika ada = Mode Edit
  final Map<String, dynamic>? currentData;

  const FormPoIndukScreen({super.key, this.docId, this.currentData});

  @override
  State<FormPoIndukScreen> createState() => _FormPoIndukScreenState();
}

class _FormPoIndukScreenState extends State<FormPoIndukScreen> {
  final _formKey = GlobalKey<FormState>();

  final _noPoIndukCtrl = TextEditingController();
  final _namaBarangCtrl = TextEditingController();
  final _planDusCtrl = TextEditingController();
  final _planPcsCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika Mode Edit, isi form dengan data lama
    if (widget.currentData != null) {
      _noPoIndukCtrl.text = widget.currentData!['no_po_induk'];
      _namaBarangCtrl.text = widget.currentData!['nama_barang'];
      _planDusCtrl.text = widget.currentData!['plan_qty_dus'].toString();
      _planPcsCtrl.text = widget.currentData!['plan_qty_pcs'].toString();
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> data = {
        'no_po_induk': _noPoIndukCtrl.text.toUpperCase(),
        'nama_barang': _namaBarangCtrl.text.toUpperCase(),
        'plan_qty_dus': int.parse(_planDusCtrl.text),
        'plan_qty_pcs': int.parse(_planPcsCtrl.text),
      };

      if (widget.docId == null) {
        // Mode Tambah Baru
        data['tanggal_po'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
        data['status'] = 'Open';
        data['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('master_po_induk')
            .add(data);
      } else {
        // Mode Edit (Update)
        await FirebaseFirestore.instance
            .collection('master_po_induk')
            .doc(widget.docId)
            .update(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.docId == null ? "PO Induk Dibuat!" : "PO Induk Diupdate!",
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
        title: Text(isEdit ? "Edit PO Induk" : "Buat PO Induk"),
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
                  "⚠️ Sedang dalam Mode Edit. Perubahan akan langsung tersimpan.",
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            TextFormField(
              controller: _noPoIndukCtrl,
              textCapitalization: TextCapitalization.characters, // Auto Kapital
              decoration: const InputDecoration(
                labelText: "Nomor PO Induk",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Wajib" : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _namaBarangCtrl,
              textCapitalization: TextCapitalization.characters, // Auto Kapital
              decoration: const InputDecoration(
                labelText: "Nama Barang",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Wajib" : null,
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _planDusCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Plan QTY (Dus)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Wajib" : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _planPcsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Plan QTY (Pcs)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Wajib" : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _simpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.all(15),
              ),
              child: Text(isEdit ? "UPDATE PO INDUK" : "SIMPAN PO INDUK"),
            ),
          ],
        ),
      ),
    );
  }
}
