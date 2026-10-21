// lib/providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  // ==========================================================
  // 1. LOGIN UTAMA (Support Email ATAU Nomor Absensi)
  // ==========================================================
  Future<bool> login({
    // UPDATE: Nama parameter diubah menjadi 'identifier' agar sesuai dengan LoginScreen
    required String identifier,
    required String password,
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot query;

      // LOGIKA DETEKSI INPUT:
      // Jika input mengandung '@', kita anggap itu Email.
      // Jika tidak, kita anggap itu Nomor Absensi.
      if (identifier.contains('@')) {
        // Cari berdasarkan Email
        query = await _db
            .collection('users')
            .where('email', isEqualTo: identifier)
            .limit(1)
            .get();
      } else {
        // Cari berdasarkan Nomor Absensi
        query = await _db
            .collection('users')
            .where('nomor_absensi', isEqualTo: identifier)
            .limit(1)
            .get();
      }

      // 1. Cek User Ditemukan atau Tidak
      if (query.docs.isEmpty) {
        throw "User tidak ditemukan. Periksa Nomor Absensi atau Email Anda.";
      }

      var userDoc = query.docs.first;
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      // 2. Validasi Password
      if (data['password'] != password) {
        throw "Kata sandi salah.";
      }

      // 3. Cek Status Aktif Akun
      if (data['is_active'] == false) {
        throw "Akun ini telah dinonaktifkan oleh Admin.";
      }

      // 4. Login Sukses -> Simpan Sesi
      await _saveSession(userDoc.id, data);

      _isLoading = false;
      notifyListeners();
      return true; // Beri tahu UI bahwa login sukses
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      // Tampilkan error jika context ada
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false; // Beri tahu UI bahwa login gagal
    }
  }

  // ==========================================================
  // 2. SIMPAN SESSION (SharedPreferences + Memory)
  // ==========================================================
  Future<void> _saveSession(String uid, Map<String, dynamic> data) async {
    // 1. Simpan ke Variable Memory (Untuk akses cepat di app)
    _userData = {
      'uid': uid,
      'nama': data['nama'] ?? 'User',
      'nomor_absensi': data['nomor_absensi'] ?? '-',
      'email': data['email'] ?? '-',
      'role': data['role'] ?? ['Karyawan'], // Array Role
      'status': data['status'] ?? 'Aktif',
      'divisi': data['divisi'] ?? 'Umum',
      // Penting untuk Dashboard Multi-Divisi:
      'akses_divisi': data['akses_divisi'] ?? [data['divisi'] ?? 'Umum'],
      'foto_profil': data['foto_profil'],
    };

    // 2. Simpan ke Penyimpanan HP
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', uid);
  }

  // ==========================================================
  // 3. CEK SESSION (Dipanggil di main.dart)
  // ==========================================================
  Future<void> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('user_uid');

      if (uid != null) {
        // Ambil data terbaru dari Firestore
        DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (data['is_active'] == false) {
            await logout();
            return;
          }

          _userData = {
            'uid': uid,
            'nama': data['nama'] ?? 'User',
            'nomor_absensi': data['nomor_absensi'] ?? '-',
            'email': data['email'] ?? '-',
            'role': data['role'] ?? [],
            'status': data['status'] ?? 'Aktif',
            'divisi': data['divisi'] ?? 'Umum',
            'akses_divisi': data['akses_divisi'] ?? [data['divisi'] ?? 'Umum'],
            'foto_profil': data['foto_profil'],
          };
          notifyListeners();
        } else {
          await logout();
        }
      }
    } catch (e) {
      debugPrint("Error checking session: $e");
    }
  }

  // ==========================================================
  // 4. LOGOUT
  // ==========================================================
  Future<void> logout() async {
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
