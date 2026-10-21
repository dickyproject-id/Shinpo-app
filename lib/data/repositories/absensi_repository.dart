// lib/data/repositories/absensi_repository.dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class AbsensiRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mengubah File gambar ke String Base64
  Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> kirimAbsensi({
    required String uid,
    required String base64Wajah,
    required String base64Area,
    required double lat,
    required double lng,
  }) async {
    String docId = "${uid}_${DateTime.now().toString().substring(0, 10)}";

    await _db.collection('absensi').doc(docId).set({
      'uid': uid,
      'jam_masuk': FieldValue.serverTimestamp(),
      'foto_wajah': base64Wajah,
      'foto_area': base64Area,
      'lokasi': GeoPoint(lat, lng),
      'status': 'Hadir',
    });
  }
}
