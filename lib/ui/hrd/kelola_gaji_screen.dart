import 'package:flutter/material.dart';

class KelolaGajiScreen extends StatefulWidget {
  const KelolaGajiScreen({super.key});

  @override
  State<KelolaGajiScreen> createState() => _KelolaGajiScreenState();
}

class _KelolaGajiScreenState extends State<KelolaGajiScreen> {
  // Simulasi List Karyawan (Nanti ambil dari Firebase)
  final List<Map<String, String>> _karyawan = [
    {"nama": "Budi Santoso", "divisi": "Operator"},
    {"nama": "Siti Aminah", "divisi": "Packing"},
    {"nama": "Joko Anwar", "divisi": "Supir"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Slip Gaji"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _karyawan.length,
        itemBuilder: (context, index) {
          final k = _karyawan[index];
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.grey,
              ),
              title: Text(k['nama']!),
              subtitle: Text(k['divisi']!),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.send, size: 16),
                label: const Text("Kirim Slip"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _showInputGajiDialog(context, k['nama']!),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInputGajiDialog(BuildContext context, String nama) {
    final TextEditingController gajiPokok = TextEditingController();
    final TextEditingController lembur = TextEditingController();
    final TextEditingController potongan = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Slip Gaji: $nama"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gajiPokok,
              decoration: const InputDecoration(
                labelText: "Gaji Pokok",
                prefixText: "Rp ",
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lembur,
              decoration: const InputDecoration(
                labelText: "Uang Lembur",
                prefixText: "Rp ",
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: potongan,
              decoration: const InputDecoration(
                labelText: "Potongan",
                prefixText: "Rp ",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Simpan ke Firebase collection 'slip_gaji'
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Slip Gaji Berhasil Dikirim!")),
              );
            },
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }
}
