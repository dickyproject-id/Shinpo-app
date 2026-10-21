// lib/data/models/kriteria_model.dart
class KriteriaModel {
  final String id;
  final String namaBagian; // Misal: Operator Produksi, Gudang, dll
  final double bobotAbsensi;
  final double bobotProduksi;
  final double bobotKualitas;

  KriteriaModel({
    required this.id,
    required this.namaBagian,
    this.bobotAbsensi = 0.3,
    this.bobotProduksi = 0.4,
    this.bobotKualitas = 0.3,
  });

  Map<String, dynamic> toMap() => {
    'namaBagian': namaBagian,
    'bobotAbsensi': bobotAbsensi,
    'bobotProduksi': bobotProduksi,
    'bobotKualitas': bobotKualitas,
  };
}
