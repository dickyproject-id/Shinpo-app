// lib/data/repositories/produksi_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/produksi_model.dart';

class ProduksiRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> simpanProduksi(ProduksiModel data) async {
    await _db.collection('laporan_produksi').add(data.toMap());
  }

  Stream<List<ProduksiModel>> getLaporanByOperator(String name) {
    return _db
        .collection('laporan_produksi')
        .where('operatorName', isEqualTo: name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProduksiModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
