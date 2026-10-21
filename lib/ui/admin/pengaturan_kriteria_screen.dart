// lib/ui/admin/pengaturan_kriteria_screen.dart
import 'package:flutter/material.dart';

class PengaturanKriteriaScreen extends StatefulWidget {
  const PengaturanKriteriaScreen({super.key});

  @override
  _PengaturanKriteriaScreenState createState() =>
      _PengaturanKriteriaScreenState();
}

class _PengaturanKriteriaScreenState extends State<PengaturanKriteriaScreen> {
  double _absensi = 30;
  double _produksi = 40;
  double _kualitas = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Atur Kriteria Penilaian")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Total Bobot: ${_absensi + _produksi + _kualitas}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: (_absensi + _produksi + _kualitas == 100)
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            _buildSlider(
              "Bobot Absensi",
              _absensi,
              (val) => setState(() => _absensi = val),
            ),
            _buildSlider(
              "Bobot Produksi",
              _produksi,
              (val) => setState(() => _produksi = val),
            ),
            _buildSlider(
              "Bobot Kualitas (BS)",
              _kualitas,
              (val) => setState(() => _kualitas = val),
            ),

            Spacer(),
            ElevatedButton(
              onPressed: (_absensi + _produksi + _kualitas == 100)
                  ? () {
                      // Simpan ke Firestore
                    }
                  : null,
              child: Text("SIMPAN KRITERIA"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()}%"),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
