// lib/ui/dashboard_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/services/update_service.dart';
// === IMPORT PROVIDER & SERVICE ===
import '../../providers/auth_provider.dart';
import 'admin/tambah_karyawan_screen.dart';
// === IMPORT SCREEN MODULAR ===
import 'face_id_screen.dart';
import 'gudang/gudang_dashboard_screen.dart';
import 'manager_dashboard_screen.dart';
import 'operator/operator_dashboard.dart';
import 'pesan/pesan_screen.dart';
import 'ppic/ppic_dashboard_screen.dart';
import 'riwayat_absensi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _versionText = "Memuat...";
  String _currentDivisiView = "Loading...";
  List<dynamic> _aksesDivisi = [];

  String _jamSekarang = "00:00";
  Timer? _timer;
  bool _isLoadingAbsen = false;
  bool _isChecking = false;

  final List<String> _roleWajibLaporan = [
    'Operator Produksi',
    'Packing',
    'Borongan',
    'Anggota Gudang Langsir',
    'Anggota Gudang Jadi',
    'Trolly',
    'Supir',
    'Kenek',
    'Teknisi',
    'Security',
    'Anggota Gudang Return',
    'Adukan',
    'Anggota Gudang Kardus',
  ];

  @override
  void initState() {
    super.initState();
    _initAppVersion();
    _cekUpdateOtomatis();
    _startJamDigital();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.userData != null) {
        setState(() {
          _aksesDivisi = auth.userData!['akses_divisi'] ?? ['Umum'];
          _currentDivisiView = _aksesDivisi.isNotEmpty
              ? _aksesDivisi.first.toString()
              : "Umum";
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startJamDigital() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(
          () => _jamSekarang = DateFormat('HH:mm').format(DateTime.now()),
        );
      }
    });
  }

  void _initAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(
        () => _versionText = "v${info.version} (Build ${info.buildNumber})",
      );
    }
  }

  void _cekUpdateOtomatis() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => UpdateService().checkForUpdate(context),
    );
  }

  // === LOGIKA ABSENSI ===
  Future<void> _kirimDataAbsen(
    String tipe, {
    String? pathWajah,
    String? pathArea,
  }) async {
    // 1. Cek Izin Dulu Sebelum Loading
    bool izinAman = await _cekIzinLokasi();
    if (!izinAman) return;

    setState(() => _isLoadingAbsen = true);
    final auth = context.read<AuthProvider>();
    final user = auth.userData;
    if (user == null) return;

    String uid = user['uid'];
    String nama = user['nama'];
    String nomorAbsen = user['nomor_absensi'];
    String tanggalHariIni = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String jamSekarang = DateFormat('HH:mm:ss').format(DateTime.now());
    String docId = "${uid}_$tanggalHariIni";

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      GeoPoint lokasiGeo = GeoPoint(position.latitude, position.longitude);
      Map<String, dynamic> dataUpdate = {};

      if (tipe == "Masuk") {
        if (pathWajah == null || pathArea == null) {
          throw "Foto Wajah & Area Wajib!";
        }
        String base64Wajah = await _convertToBase64(pathWajah);
        String base64Area = await _convertToBase64(pathArea);
        dataUpdate = {
          'uid': uid,
          'nama': nama,
          'nomor_absensi': nomorAbsen,
          'tanggal': tanggalHariIni,
          'jam_masuk': jamSekarang,
          'foto_wajah_masuk': base64Wajah,
          'foto_area_masuk': base64Area,
          'lokasi_masuk': lokasiGeo,
          'status_kehadiran': 'Hadir',
          'created_at': FieldValue.serverTimestamp(),
        };
      } else if (tipe == "Mulai Istirahat") {
        dataUpdate = {
          'jam_istirahat_mulai': jamSekarang,
          'lokasi_istirahat_mulai': lokasiGeo,
        };
      } else if (tipe == "Selesai Istirahat") {
        dataUpdate = {
          'jam_istirahat_selesai': jamSekarang,
          'lokasi_istirahat_selesai': lokasiGeo,
        };
      } else if (tipe == "Pulang") {
        dataUpdate = {
          'jam_pulang': jamSekarang,
          'lokasi_pulang': lokasiGeo,
          'status_pulang': 'Selesai',
        };
      }

      await FirebaseFirestore.instance
          .collection('absensi')
          .doc(docId)
          .set(dataUpdate, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Absen $tipe Berhasil!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAbsen = false);
    }
  }

  Future<String> _convertToBase64(String path) async {
    File file = File(path);
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> _bukaKameraAbsenMasuk() async {
    bool izinAman = await _cekIzinLokasi();
    if (!izinAman) return;
    if (!mounted) return;
    final String? pathFotoWajah = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FaceIdScreen(tipe: "Masuk")),
    );
    if (pathFotoWajah != null) await _mintaFotoAreaKerja(pathFotoWajah);
  }

  Future<void> _mintaFotoAreaKerja(String pathWajah) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photoArea = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 25,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (photoArea != null) {
      _kirimDataAbsen("Masuk", pathWajah: pathWajah, pathArea: photoArea.path);
    }
  }

  Future<void> _prosesAbsenCepat(String tipe) async {
    bool izinAman = await _cekIzinLokasi();
    if (!izinAman) return;
    if (!mounted) return;
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Konfirmasi $tipe"),
            content: Text("Absen $tipe sekarang?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Ya"),
              ),
            ],
          ),
        ) ??
        false;
    if (confirm) _kirimDataAbsen(tipe);
  }

  // === PERBAIKAN UTAMA: LOGIKA CEK IZIN ===
  Future<bool> _cekIzinLokasi() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah GPS Nyala
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("GPS Mati! Harap nyalakan GPS di panel atas."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    // 2. Cek Status Izin Aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Minta Izin
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Izin Lokasi Ditolak. Absen butuh lokasi."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }

    // 3. Jika Ditolak Permanen (User pernah klik 'Dont ask again')
    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showDialogBukaSetting();
      return false;
    }

    return true;
  }

  void _showDialogBukaSetting() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Izin Lokasi Diperlukan"),
        content: const Text(
          "Sistem mendeteksi izin lokasi diblokir permanen. Harap buka pengaturan dan izinkan Lokasi untuk aplikasi ini agar bisa absen.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings(); // Buka menu setting HP otomatis
            },
            child: const Text("Buka Pengaturan"),
          ),
        ],
      ),
    );
  }

  Future<void> _onTapPulang(String uid, List<dynamic> userRoles) async {
    bool isWajibLaporan = userRoles.any((r) => _roleWajibLaporan.contains(r));
    if (!isWajibLaporan) {
      _prosesAbsenCepat("Pulang");
      return;
    }

    setState(() => _isChecking = true);
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var query = await FirebaseFirestore.instance
          .collection('laporan_kerja')
          .where('uid', isEqualTo: uid)
          .where('tanggal', isEqualTo: today)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        if (mounted) _showWarningDialog();
      } else {
        _prosesAbsenCepat("Pulang");
      }
    } catch (e) {
      /* handle */
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Laporan Belum Ada"),
        content: const Text("Isi laporan kerja dulu."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userData = auth.userData;
    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<dynamic> roles = userData['role'] ?? [];
    final String nama = userData['nama'] ?? "User";
    final String nomorAbsen = userData['nomor_absensi'] ?? "-";
    final String uid = userData['uid'] ?? "";

    bool canAccessHR = roles.any(
      (r) =>
          ['Admin Data Entry', 'Data Entry', 'HRD', 'Super Admin'].contains(r),
    );
    bool canAccessPPIC = roles.any(
      (r) => ['Admin PPIC', 'PPIC', 'Super Admin'].contains(r),
    );
    bool canAccessGudang = roles.any(
      (r) => r.toString().contains('Gudang') || r == 'Super Admin',
    );
    bool canAccessProduksi = roles.any(
      (r) => [
        'Operator Produksi',
        'Packing',
        'Borongan',
        'Trolly',
        'Super Admin',
      ].contains(r),
    );
    bool canAccessManager = roles.any(
      (r) => ['Manager', 'HRD', 'Super Admin'].contains(r),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(context, auth),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(nama, nomorAbsen, roles, uid),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Aktivitas Saya",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPersonalMenuGrid(context),
                  const SizedBox(height: 30),

                  if (roles.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Area Kerja & Tugas",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Expanded(child: Divider(indent: 10)),
                      ],
                    ),
                  const SizedBox(height: 15),

                  if (canAccessHR) ...[
                    _buildRoleSectionTitle(
                      "Kelola Karyawan (HR/Data Entry)",
                      Colors.redAccent,
                    ),
                    _buildMenuGrid([
                      _MenuData(
                        "Buat Akun",
                        Icons.person_add_alt_1,
                        Colors.blue[800]!,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TambahKaryawanScreen(),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  if (canAccessPPIC) ...[
                    _buildRoleSectionTitle(
                      "Perencanaan Produksi",
                      Colors.indigo,
                    ),
                    _buildLargeButton(
                      title: "DASHBOARD PPIC",
                      subtitle: "Jadwal, SPK, & Material",
                      icon: Icons.calendar_month,
                      color: Colors.indigo,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PpicDashboardScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (canAccessGudang) ...[
                    _buildRoleSectionTitle("Logistik & Gudang", Colors.teal),
                    _buildLargeButton(
                      title: "DASHBOARD GUDANG",
                      subtitle: "Stok, Surat Jalan, Barang Masuk",
                      icon: Icons.inventory_2,
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GudangDashboardScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (canAccessProduksi) ...[
                    _buildRoleSectionTitle("Produksi", Colors.orange),
                    _buildLargeButton(
                      title: "MODE KERJA OPERATOR",
                      subtitle: "Laporan Hasil Produksi",
                      icon: Icons.factory,
                      color: Colors.orange[800]!,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OperatorDashboard(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (canAccessManager) ...[
                    _buildRoleSectionTitle("Management", Colors.blueGrey),
                    _buildLargeButton(
                      title: "DASHBOARD MANAGER",
                      subtitle: "Laporan, KPI, & Leaderboard",
                      icon: Icons.pie_chart,
                      color: Colors.blueGrey,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManagerDashboardScreen(),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "PT Sahabat Intim Plasindo\n$_versionText",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGET HELPERS ===
  Widget _buildPersonalMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.8,
      children: [
        _buildIconMenu(
          Icons.history,
          "Riwayat",
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RiwayatAbsensiScreen()),
          ),
        ),
        _buildIconMenu(Icons.event_note, "Izin/Cuti", Colors.orange, () {}),
        _buildIconMenu(Icons.payments, "Slip Gaji", Colors.green, () {}),
        _buildIconMenu(Icons.person, "Profil", Colors.purple, () {}),
      ],
    );
  }

  PreferredSizeWidget _buildModernAppBar(
    BuildContext context,
    AuthProvider auth,
  ) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      elevation: 0,
      title: _aksesDivisi.length > 1
          ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.blue[900],
                value: _currentDivisiView,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (val) => setState(() => _currentDivisiView = val!),
                items: _aksesDivisi
                    .map<DropdownMenuItem<String>>(
                      (v) => DropdownMenuItem(value: v, child: Text(v)),
                    )
                    .toList(),
              ),
            )
          : const Text("Dashboard Utama", style: TextStyle(fontSize: 16)),
      actions: [
        IconButton(
          icon: const Icon(Icons.mail_outline),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PesanScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: () => _showLogoutDialog(context, auth),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(
    String nama,
    String nomorAbsen,
    List roles,
    String uid,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Text(
                  nama.isNotEmpty ? nama[0] : "U",
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, $nama",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: $nomorAbsen",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status Hari Ini",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Siap Absen",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _jamSekarang,
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAbsenButton(
                      label: "Masuk",
                      icon: Icons.login_rounded,
                      color: Colors.green,
                      isLoading: _isLoadingAbsen,
                      onTap: () => _bukaKameraAbsenMasuk(),
                    ),
                    _buildAbsenButton(
                      label: "Istirahat",
                      icon: Icons.coffee_rounded,
                      color: Colors.orange,
                      isLoading: _isLoadingAbsen,
                      onTap: () => _prosesAbsenCepat("Mulai Istirahat"),
                    ),
                    _buildAbsenButton(
                      label: "Lanjut",
                      icon: Icons.play_circle_fill_rounded,
                      color: Colors.blue,
                      isLoading: _isLoadingAbsen,
                      onTap: () => _prosesAbsenCepat("Selesai Istirahat"),
                    ),
                    _buildAbsenButton(
                      label: "Pulang",
                      icon: Icons.logout_rounded,
                      color: Colors.red,
                      isLoading: _isLoadingAbsen || _isChecking,
                      onTap: () => _onTapPulang(uid, roles),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconMenu(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSectionTitle(String title, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMenuGrid(List<_MenuData> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.white,
          elevation: 1,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLargeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}

class _MenuData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _MenuData(this.title, this.icon, this.color, this.onTap);
}
