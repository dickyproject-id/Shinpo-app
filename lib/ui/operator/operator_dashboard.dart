import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({super.key});

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPoKomponenId;
  Map<String, dynamic>? _poData;

  // === CONTROLLERS INPUT LENGKAP ===
  final _shiftCtrl = TextEditingController();
  final _ctActualCtrl = TextEditingController(); // Cycle Time
  final _beratActualCtrl = TextEditingController(); // Berat (Gr)

  // Hasil
  final _hasilPcsCtrl = TextEditingController();
  final _tambahanPcsCtrl = TextEditingController(); // NEW
  final _beratHasilKgCtrl = TextEditingController(); // NEW (Berat Hasil KG)

  // Reject & Waste
  final _bsPcsCtrl = TextEditingController();
  final _beratBsKgCtrl = TextEditingController();
  final _beratCcKgCtrl = TextEditingController(); // NEW (Cucian)
  final _runnerKgCtrl = TextEditingController();

  // Material
  final _pemakaianShiftCtrl = TextEditingController(); // Pershift
  final _pemakaianHariCtrl = TextEditingController(); // Hari (Opsional)
  final _bkbKgCtrl = TextEditingController(); // NEW
  final _sisaBahanKgCtrl = TextEditingController();

  final _ketCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _kirimLaporan() async {
    if (_selectedPoKomponenId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih PO Komponen Dulu!")));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().userData;

    try {
      // Helper Parser
      double toDouble(String s) => double.tryParse(s) ?? 0.0;
      int toInt(String s) => int.tryParse(s) ?? 0;

      // Ambil Value
      int hasilPcs = toInt(_hasilPcsCtrl.text);
      int tambahanPcs = toInt(_tambahanPcsCtrl.text);
      double beratHasilKg = toDouble(_beratHasilKgCtrl.text);
      int bsPcs = toInt(_bsPcsCtrl.text);
      double beratBsKg = toDouble(_beratBsKgCtrl.text);
      double beratCcKg = toDouble(_beratCcKgCtrl.text);
      double runnerKg = toDouble(_runnerKgCtrl.text);
      double pakaiShiftKg = toDouble(_pemakaianShiftCtrl.text);

      // 1. Simpan ke Laporan Produksi
      await FirebaseFirestore.instance.collection('laporan_produksi').add({
        'po_komponen_id': _selectedPoKomponenId,
        'nama_komponen': _poData?['nama_komponen'],

        'uid_operator': user?['uid'],
        'nama_operator': user?['nama'],
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'jam_input': DateFormat('HH:mm').format(DateTime.now()),

        'shift': _shiftCtrl.text,
        'cycle_time_act': toDouble(_ctActualCtrl.text),
        'berat_act_gr': toDouble(_beratActualCtrl.text),

        'hasil_pcs': hasilPcs,
        'tambahan_pcs': tambahanPcs,
        'berat_hasil_kg': beratHasilKg,

        'bs_pcs': bsPcs,
        'berat_bs_kg': beratBsKg,
        'berat_cc_kg': beratCcKg,
        'runner_kg': runnerKg,

        'pemakaian_shift_kg': pakaiShiftKg,
        'pemakaian_hari_kg': toDouble(_pemakaianHariCtrl.text),
        'bkb_kg': toDouble(_bkbKgCtrl.text),
        'sisa_bahan_kg': toDouble(_sisaBahanKgCtrl.text),
        'keterangan': _ketCtrl.text,

        'created_at': FieldValue.serverTimestamp(),
      });

      // 2. Update AKUMULASI OTOMATIS di PO Komponen
      await FirebaseFirestore.instance
          .collection('master_po_komponen')
          .doc(_selectedPoKomponenId)
          .update({
            'total_hasil_produksi_pcs': FieldValue.increment(hasilPcs),
            'total_tambahan_pcs': FieldValue.increment(tambahanPcs),
            'total_berat_hasil_kg': FieldValue.increment(beratHasilKg),
            'total_bs_pcs': FieldValue.increment(bsPcs),
            'total_berat_bs_kg': FieldValue.increment(beratBsKg),
            'total_berat_cc_kg': FieldValue.increment(beratCcKg),
            'total_runner_kg': FieldValue.increment(runnerKg),
            'total_pemakaian_bahan_kg': FieldValue.increment(pakaiShiftKg),
          });

      // 3. Update Laporan Kerja Harian
      await FirebaseFirestore.instance.collection('laporan_kerja').add({
        'uid': user?['uid'],
        'nama': user?['nama'],
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Laporan Terkirim!"),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _shiftCtrl.clear();
    _ctActualCtrl.clear();
    _beratActualCtrl.clear();
    _hasilPcsCtrl.clear();
    _tambahanPcsCtrl.clear();
    _beratHasilKgCtrl.clear();
    _bsPcsCtrl.clear();
    _beratBsKgCtrl.clear();
    _beratCcKgCtrl.clear();
    _runnerKgCtrl.clear();
    _pemakaianShiftCtrl.clear();
    _pemakaianHariCtrl.clear();
    _bkbKgCtrl.clear();
    _sisaBahanKgCtrl.clear();
    _ketCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Produksi Operator"),
        backgroundColor: Colors.orange[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Komponen Aktif (PO):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('master_po_komponen')
                    .where('status', isEqualTo: 'Open')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();

                  var items = snapshot.data!.docs.map((doc) {
                    var d = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(
                        "${d['no_po_komponen']} - ${d['nama_komponen']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => setState(() => _poData = d),
                    );
                  }).toList();

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedPoKomponenId,
                    isExpanded: true,
                    items: items,
                    onChanged: (val) =>
                        setState(() => _selectedPoKomponenId = val),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Cari Komponen...",
                    ),
                  );
                },
              ),

              if (_poData != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.orange.shade50,
                  width: double.infinity,
                  child: Text(
                    "Mesin: ${_poData!['nomor_mesin']} | Bahan: ${_poData!['nama_bahan']} | Warna: ${_poData!['warna']}",
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _inputGroup("1. Data Umum", [
                _input(_shiftCtrl, "Shift"),
                _input(_ctActualCtrl, "Cycle Time (Detik)", isNum: true),
                _input(_beratActualCtrl, "Berat Actual (Gr)", isNum: true),
              ]),

              _inputGroup("2. Hasil Produksi", [
                _input(_hasilPcsCtrl, "Hasil Produksi (Pcs)", isNum: true),
                _input(_tambahanPcsCtrl, "Tambahan (Pcs)", isNum: true),
                _input(_beratHasilKgCtrl, "Berat Hasil (Kg)", isNum: true),
              ]),

              _inputGroup("3. Reject & Waste", [
                Row(
                  children: [
                    Expanded(
                      child: _input(_bsPcsCtrl, "Barang BS (Pcs)", isNum: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _input(
                        _beratBsKgCtrl,
                        "Berat BS (Kg)",
                        isNum: true,
                      ),
                    ),
                  ],
                ),
                _input(_beratCcKgCtrl, "Berat Cucian/CC (Kg)", isNum: true),
                _input(_runnerKgCtrl, "Berat Runner (Kg)", isNum: true),
              ]),

              _inputGroup("4. Material Balance", [
                _input(
                  _pemakaianShiftCtrl,
                  "Pemakaian Shift (Kg)",
                  isNum: true,
                ),
                _input(_pemakaianHariCtrl, "Pemakaian Hari (Kg)", isNum: true),
                _input(_bkbKgCtrl, "BKB / Return (Kg)", isNum: true),
                _input(_sisaBahanKgCtrl, "Sisa Bahan (Kg)", isNum: true),
              ]),

              _input(_ketCtrl, "Keterangan"),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimLaporan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "KIRIM LAPORAN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange[900],
          ),
        ),
        const SizedBox(height: 10),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String label, {
    bool isNum = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
