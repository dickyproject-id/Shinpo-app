import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProduksiProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Variabel untuk menampung hasil perhitungan sementara
  int _counterMesin = 0;
  int get counterMesin => _counterMesin;

  // === 1. LOGIKA HITUNG COUNTER OTOMATIS ===
  // Fungsi ini dipanggil setiap kali Operator mengetik angka di Form
  void hitungCounter({
    required int hasil,
    required int bs,
    required int cucian,
  }) {
    _counterMesin = hasil + bs + cucian;
    // notifyListeners() memberitahu UI untuk update tampilan angka Counter
    notifyListeners();
  }

  // === 2. KIRIM LAPORAN KE FIREBASE ===
  Future<void> submitLaporan({
    required String uidOperator,
    required String namaOperator,
    required String noPo,
    required int shift,
    required String kodeBarang,
    required String noMesin,
    required int hasil,
    required int bs,
    required int cucian,
    required double beratActual,
    String? keterangan,
  }) async {
    _isLoading = true;
    notifyListeners(); // UI jadi Loading

    try {
      // Validasi sederhana
      if (noPo.isEmpty) throw "Nomor PO tidak boleh kosong";
      if (hasil == 0 && bs == 0) throw "Hasil produksi belum diisi";

      // Hitung ulang untuk memastikan data akurat sebelum kirim
      int finalCounter = hasil + bs + cucian;

      // Simpan ke Firestore
      await _db.collection('laporan_kerja').add({
        'uid_operator': uidOperator,
        'nama_operator': namaOperator,
        'no_po_komponen': noPo,
        'shift': shift,
        'kode_barang': kodeBarang,
        'no_mesin': noMesin,
        'hasil_produksi': hasil,
        'bs_produksi': bs,
        'cucian': cucian,
        'counter_mesin': finalCounter,
        'berat_actual': beratActual,
        'keterangan': keterangan ?? '-',
        'timestamp': FieldValue.serverTimestamp(), // Jam server (anti curang)
        'tanggal_laporan': DateTime.now().toIso8601String().substring(
          0,
          10,
        ), // Format YYYY-MM-DD
        'status': 'Submitted', // Bisa 'Draft' jika fitur draft aktif
      });

      // Update progress PO di Master PO (Optional: Mengurangi target)
      // await _updateProgressPO(noPo, hasil);
    } catch (e) {
      // Lempar error agar bisa ditangkap di UI (muncul SnackBar merah)
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); // UI selesai Loading
    }
  }

  // (Optional) Fungsi Reset Form setelah kirim
  void resetForm() {
    _counterMesin = 0;
    notifyListeners();
  }
}
