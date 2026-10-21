import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // FIX: Tambahkan Import Ini

class UpdateService {
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentBuildNumber = int.parse(packageInfo.buildNumber);

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('android_update')
          .get();

      if (!doc.exists) return;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      int latestBuildNumber = data['latest_build_number'] ?? 0;
      bool isForceUpdate = data['force_update'] ?? false;
      String url = data['download_url'] ?? "";
      String changelog = data['changelog'] ?? "- Perbaikan sistem";
      String versionName = data['latest_version_name'] ?? "New Version";

      if (latestBuildNumber > currentBuildNumber) {
        if (context.mounted) {
          _showUpdateDialog(
            context,
            versionName,
            changelog,
            url,
            isForceUpdate,
          );
        }
      }
    } catch (e) {
      print("Gagal cek update: $e");
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String version,
    String changelog,
    String url,
    bool force,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Tersedia! 🚀"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Versi Baru: $version",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(changelog),
            ),
          ],
        ),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Nanti Saja"),
            ),

          ElevatedButton(
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              // FIX: Method launchUrl dan LaunchMode sekarang dikenali
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal membuka link")),
                );
              }
            },
            child: const Text("DOWNLOAD"),
          ),
        ],
      ),
    );
  }
}
