import 'package:cloud_firestore/cloud_firestore.dart'; // FIX: Tambahkan Import Ini

class ProduksiModel {
  final String id;
  final String noPo;
  final String operatorName;
  final int hasil;
  final int bs;
  final DateTime timestamp;

  ProduksiModel({
    required this.id,
    required this.noPo,
    required this.operatorName,
    required this.hasil,
    required this.bs,
    required this.timestamp,
  });

  factory ProduksiModel.fromMap(Map<String, dynamic> data, String id) {
    return ProduksiModel(
      id: id,
      noPo: data['noPo'] ?? '',
      operatorName: data['operatorName'] ?? '',
      hasil: data['hasil'] ?? 0,
      bs: data['bs'] ?? 0,
      // FIX: Sekarang Timestamp sudah dikenali
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'noPo': noPo,
      'operatorName': operatorName,
      'hasil': hasil,
      'bs': bs,
      'counterMesin': hasil + bs,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
