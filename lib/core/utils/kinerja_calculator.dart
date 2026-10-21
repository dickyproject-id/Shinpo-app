// lib/core/utils/kinerja_calculator.dart
class KinerjaCalculator {
  static double hitungSkorAkhir({
    required int hasilProduksi,
    required int targetProduksi,
    required int jumlahHadir,
    required int totalHariKerja,
    required int poinPelanggaran,
  }) {
    // Persentase Produksi (Bobot 40%)
    double skorProduksi = (hasilProduksi / targetProduksi) * 40;

    // Persentase Absensi (Bobot 30%)
    double skorAbsensi = (jumlahHadir / totalHariKerja) * 30;

    // Kualitas/Kedisiplinan (Bobot 30% - dikurangi pelanggaran)
    double skorKedisiplinan = 30 - poinPelanggaran.toDouble();

    return skorProduksi + skorAbsensi + skorKedisiplinan;
  }
}
