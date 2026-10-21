// lib/ui/gudang/gudang_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinpo_app/ui/gudang/gudang_kardus_screen.dart';
import 'package:shinpo_app/ui/gudang/monitoring_pengiriman_screen.dart';

import '../../providers/auth_provider.dart';
import 'form_surat_jalan_screen.dart';

class GudangDashboardScreen extends StatelessWidget {
  const GudangDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final roles = auth.userData?['role'] ?? [];

    // === LOGIKA PEMISAHAN ROLE ===
    bool isKardus = roles.contains('Admin Gudang Kardus');
    bool isLogistik = roles.any(
      (r) => ['Gudang Jadi', 'Gudang Langsir', 'Admin Gudang'].contains(r),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Gudang"),
        backgroundColor: isKardus ? Colors.brown : Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(auth.userData?['nama'] ?? "Admin"),
            const SizedBox(height: 20),

            // TAMPILKAN MENU SESUAI ROLE
            if (isKardus) _buildMenuKardus(context),
            if (isLogistik) _buildMenuLogistik(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String nama) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            child: Icon(Icons.warehouse, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $nama",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Selamat Bekerja",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === MENU KHUSUS GUDANG KARDUS (INVENTORY ONLY) ===
  Widget _buildMenuKardus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Manajemen Stok Kardus",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 10),
        _buildLargeButton(
          context,
          "Stok Keluar / Masuk",
          "Catat barang masuk & pemakaian",
          Icons.inventory_2, // Ikon Kardus
          Colors.brown,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GudangKardusScreen()),
          ),
        ),
      ],
    );
  }

  // === MENU KHUSUS GUDANG JADI / LANGSIR (PENGIRIMAN) ===
  Widget _buildMenuLogistik(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Logistik & Pengiriman",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 10),

        _buildLargeButton(
          context,
          "Buat Surat Jalan",
          "Input pengiriman baru",
          Icons.note_add,
          Colors.teal,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormSuratJalanScreen()),
          ),
        ),

        const SizedBox(height: 15),

        _buildLargeButton(
          context,
          "Pantau Pengiriman",
          "Lacak Supir, Rute, & Status",
          Icons.map,
          Colors.orange[800]!,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MonitoringPengirimanScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLargeButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
