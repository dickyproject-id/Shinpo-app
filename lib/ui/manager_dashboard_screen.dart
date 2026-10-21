import 'package:flutter/material.dart';
import 'package:shinpo_app/ui/shared/leaderboard_screen.dart';

import '../../core/excel_service.dart'; // Pastikan file service ini ada

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Dashboard Manager"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER SUMMARY (Kartu Ringkasan)
            _buildHeaderSummary(),

            const SizedBox(height: 25),
            const Text(
              "Menu Laporan & Analisa",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // 2. GRID MENU
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1, // Agar kotak tidak terlalu tinggi
              children: [
                _buildManagerMenu(
                  context,
                  "Export Excel",
                  "Unduh Laporan Produksi",
                  Icons.file_download,
                  Colors.green,
                  () {
                    // Panggil Service Export Excel
                    ExcelService().exportLaporanProduksi();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Sedang mengunduh laporan..."),
                      ),
                    );
                  },
                ),
                _buildManagerMenu(
                  context,
                  "Leaderboard",
                  "Ranking Kinerja Karyawan",
                  Icons.emoji_events,
                  Colors.amber[800]!,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ),
                _buildManagerMenu(
                  context,
                  "Analisa KPI",
                  "Grafik Performa & Target",
                  Icons.pie_chart,
                  Colors.blueAccent,
                  () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => KpiChartScreen()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fitur Analisa KPI (Coming Soon)"),
                      ),
                    );
                  },
                ),
                _buildManagerMenu(
                  context,
                  "Approval Izin",
                  "Cuti & Sakit",
                  Icons.approval,
                  Colors.purple,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fitur Approval (Coming Soon)"),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 3. STATISTIK SINGKAT (Opsional)
            const Text(
              "Statistik Hari Ini",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: "Hadir", value: "45", color: Colors.green),
                  _StatItem(label: "Telat", value: "3", color: Colors.orange),
                  _StatItem(label: "Alpha", value: "1", color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: HEADER SUMMARY
  Widget _buildHeaderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey.shade50,
            child: const Icon(
              Icons.analytics,
              color: Colors.blueGrey,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Management Panel",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Pantau performa dan unduh laporan harian.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: MENU CARD
  Widget _buildManagerMenu(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// WIDGET: STATISTIK ITEM KECIL
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
