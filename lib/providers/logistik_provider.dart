// lib/providers/logistik_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LogistikProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. GUDANG: Buat Surat Jalan & BKB Baru
  Future<void> buatSuratJalan({
    required String noBkb,
    required String uidSupir,
    required String namaSupir,
    required String uidKenek,
    required String namaKenek,
    required String platNomor,
    required List<Map<String, dynamic>> barangList, // {nama, qty}
    required List<Map<String, dynamic>> ruteList, // {nama_toko, alamat}
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Kurangi Stok Gudang Langsir/Jadi (Opsional: Logic Inventory)
      // ... (Code update stok inventory di sini)

      await _db.collection('pengiriman').add({
        'no_bkb': noBkb,
        'driver_info': {'uid': uidSupir, 'nama': namaSupir},
        'kenek_info': {'uid': uidKenek, 'nama': namaKenek},
        'plat_nomor': platNomor,
        'tanggal_kirim': FieldValue.serverTimestamp(),
        'status': 'Loading', // Status Awal
        'barang': barangList
            .map(
              (e) => {
                ...e,
                'qty_diterima': 0, // Default 0 sebelum sampai
                'status_barang': 'Dikirim',
              },
            )
            .toList(),
        'rute': ruteList
            .map(
              (e) => {
                ...e,
                'status_kunjungan': 'Pending', // Pending, Sampai
                'waktu_sampai': null,
              },
            )
            .toList(),
        'total_bbm': 0.0,
        'total_jarak': 0.0,
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. SUPIR: Update Status Perjalanan (Tiba di Toko A, B, C)
  Future<void> updateKunjunganToko(
    String docId,
    int indexRute,
    double lat,
    double lng,
  ) async {
    // Update status toko spesifik menjadi 'Sampai'
    // Dan catat koordinat/waktu
    DocumentReference ref = _db.collection('pengiriman').doc(docId);

    // Logic update array firestore agak kompleks, kita tarik dulu datanya
    DocumentSnapshot doc = await ref.get();
    List rute = doc['rute'];
    rute[indexRute]['status_kunjungan'] = 'Selesai';
    rute[indexRute]['waktu_sampai'] = DateTime.now().toString();

    // Hitung jarak (Logic sederhana)
    // Di real app, gunakan Geolocator.distanceBetween() antara toko sebelumnya dan toko sekarang

    await ref.update({'rute': rute});
    notifyListeners();
  }

  // 3. SUPIR: Finalisasi Pengiriman (Input BBM & Selesai)
  Future<void> selesaikanPengiriman(
    String docId,
    double bbmPakai,
    List<dynamic> updateBarang,
  ) async {
    await _db.collection('pengiriman').doc(docId).update({
      'status': 'Selesai',
      'total_bbm': bbmPakai,
      'barang': updateBarang, // Update qty_diterima jika ada reject
    });
  }
}
