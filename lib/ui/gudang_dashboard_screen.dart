import 'package:flutter/material.dart';
import 'package:shinpo_app/ui/gudang/form_surat_jalan_screen.dart';

class GudangDashboardScreen extends StatelessWidget {
  const GudangDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Gudang"),
        backgroundColor: Colors.teal,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        children: [
          _buildGridItem(
            context,
            "Surat Jalan",
            Icons.local_shipping,
            Colors.teal,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormSuratJalanScreen()),
            ),
          ),
          _buildGridItem(
            context,
            "Cek Stok",
            Icons.inventory_2,
            Colors.teal[700]!,
            () {},
          ),
          _buildGridItem(
            context,
            "Barang Masuk",
            Icons.move_to_inbox,
            Colors.green[700]!,
            () {},
          ),
          _buildGridItem(
            context,
            "Opname",
            Icons.fact_check,
            Colors.orange,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
