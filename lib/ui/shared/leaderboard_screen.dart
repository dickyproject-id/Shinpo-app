// lib/ui/shared/leaderboard_screen.dart
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peringkat Karyawan Terbaik"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Bagian (Dropdown)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "Pilih Bagian"),
              items: const [
                DropdownMenuItem(
                  value: "Operator Produksi",
                  child: Text("Operator Produksi"),
                ),
                DropdownMenuItem(value: "Gudang", child: Text("Bagian Gudang")),
                DropdownMenuItem(
                  value: "Packing",
                  child: Text("Borongan Packing"),
                ),
              ],
              onChanged: (v) {
                // Trigger refresh data berdasarkan bagian
              },
            ),
          ),

          // Tampilan 3 Besar (Podium)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPodium(
                  "Budi",
                  "92.5%",
                  Icons.military_tech,
                  Colors.grey,
                  80,
                ), // Juara 2
                _buildPodium(
                  "Andi",
                  "95.8%",
                  Icons.emoji_events,
                  Colors.amber,
                  110,
                ), // Juara 1
                _buildPodium(
                  "Siti",
                  "89.2%",
                  Icons.military_tech,
                  Colors.brown,
                  70,
                ), // Juara 3
              ],
            ),
          ),

          // List Peringkat Seterusnya
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text("${index + 4}")),
                  title: Text("Karyawan ${index + 4}"),
                  subtitle: const Text("Bagian Produksi"),
                  trailing: Text(
                    "${90 - index}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(
    String nama,
    String skor,
    IconData icon,
    Color color,
    double height,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 5),
        Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              skor,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
