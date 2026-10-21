import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // === FITUR 1: TAMBAH KARYAWAN (Dengan Divisi) ===
  Future<void> tambahKaryawan({
    required String nama,
    required String noAbsen,
    required String password,
    required String role,
    required String status,
    required String divisi, // Karyawan terikat 1 divisi
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot cekNip = await _db
          .collection('users')
          .where('nomor_absensi', isEqualTo: noAbsen)
          .get();

      if (cekNip.docs.isNotEmpty) throw "Nomor Absensi sudah terdaftar.";

      await _db.collection('users').add({
        'nama': nama,
        'nomor_absensi': noAbsen,
        'password': password,
        'role': [role],
        'status': status,
        'divisi': divisi,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === FITUR 2: TAMBAH ADMIN (Multi Divisi) ===
  Future<void> tambahAdminBaru({
    required String nama,
    required String rolePilihan,
    required String kodeUnik,
    required List<String> aksesDivisi, // Admin bisa pegang banyak divisi
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Cek Kode Unik
      QuerySnapshot cekKode = await _db
          .collection('users')
          .where('access_code', isEqualTo: kodeUnik)
          .get();

      if (cekKode.docs.isNotEmpty) {
        throw "Kode Unik '$kodeUnik' sudah dipakai.";
      }

      // 2. Simpan Data
      await _db.collection('users').add({
        'nama': nama,
        'role': [rolePilihan],
        'access_code': kodeUnik,
        'nomor_absensi': 'ADMIN',
        'status': 'Staff Kantor',
        'akses_divisi': aksesDivisi, // List divisi disimpan
        'divisi_aktif': aksesDivisi.first, // Default view
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
