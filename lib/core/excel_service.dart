import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelService {
  Future<void> exportLaporanProduksi() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Laporan Produksi'];

    // FIX: Menggunakan TextCellValue untuk header
    List<CellValue> headers = [
      TextCellValue("Tanggal"),
      TextCellValue("No PO"),
      TextCellValue("Operator"),
      TextCellValue("Hasil"),
      TextCellValue("BS"),
      TextCellValue("Counter"),
    ];
    sheetObject.appendRow(headers);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('laporan_kerja')
        .orderBy('timestamp', descending: true)
        .get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // FIX: Mengkonversi String/Int menjadi TextCellValue/IntCellValue
      List<CellValue> row = [
        TextCellValue(data['timestamp']?.toDate().toString() ?? ''),
        TextCellValue(data['no_po_komponen'] ?? ''),
        TextCellValue(data['uid_operator'] ?? ''),
        IntCellValue(data['hasil_produksi'] ?? 0),
        IntCellValue(data['bs_produksi'] ?? 0),
        IntCellValue(data['counter_mesin'] ?? 0),
      ];
      sheetObject.appendRow(row);
    }

    var fileBytes = excel.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Laporan_Produksi.xlsx');

    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Laporan Produksi');
    }
  }
}
