// lib/ui/admin/tambah_karyawan_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TambahKaryawanScreen extends StatefulWidget {
  const TambahKaryawanScreen({super.key});

  @override
  State<TambahKaryawanScreen> createState() => _TambahKaryawanScreenState();
}

class _TambahKaryawanScreenState extends State<TambahKaryawanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // === 1. CONTROLLER MANUAL ===
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noAbsenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // === 2. DATA UTAMA ===
  String? _selectedRole;
  String? _selectedDivisiKaryawan;
  List<String> _selectedAksesDivisiAdmin = [];

  // === 3. MASTER DATA DIVISI ===
  List<String> _listDivisi = [
    'Gudang',
    'Produksi',
    'Packing',
    'HRD',
    'Security',
    'Supir',
    'Kenek',
    'PPIC',
    'Management',
    'Umum',
  ];

  // === LIST ROLE LENGKAP ===
  final List<String> _listRole = [
    // Operasional
    'Operator Produksi',
    'Packing',
    'Borongan',
    'Gudang Jadi',
    'Gudang Langsir',
    'Supir',
    'Kenek',
    'Trolly',
    'Security',
    'Cleaning Service',
    'Teknisi',
    // Administrasi & Management
    'Admin PPIC',
    'Admin Gudang',
    'Admin Data Entry',
    'HRD',
    'Manager',
    'Super Admin',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDivisiDariDatabase();
  }

  Future<void> _fetchDivisiDariDatabase() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('master_data')
          .doc('divisi')
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _listDivisi = List<String>.from(doc.data()!['list'] ?? _listDivisi);
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil master divisi: $e");
    }
  }

  void _tambahDivisiBaru() {
    TextEditingController divisiBaruController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Divisi Baru"),
        content: TextField(
          controller: divisiBaruController,
          decoration: const InputDecoration(hintText: "Contoh: Marketing"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (divisiBaruController.text.isNotEmpty) {
                String baru = divisiBaruController.text.trim();
                setState(() {
                  _listDivisi.add(baru);
                  _selectedDivisiKaryawan = baru;
                });
                await FirebaseFirestore.instance
                    .collection('master_data')
                    .doc('divisi')
                    .set({'list': _listDivisi}, SetOptions(merge: true));
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDivisiKaryawan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih Divisi Karyawan!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> finalRoles = [_selectedRole ?? 'Karyawan'];

      // Tentukan akses divisi
      List<String> aksesDivisiSimpan = [];
      if (_selectedRole!.contains('Admin') ||
          _selectedRole == 'Data Entry' ||
          _selectedRole == 'Manager') {
        aksesDivisiSimpan = _selectedAksesDivisiAdmin.isNotEmpty
            ? _selectedAksesDivisiAdmin
            : [_selectedDivisiKaryawan!];
      } else {
        aksesDivisiSimpan = [_selectedDivisiKaryawan!];
      }

      await FirebaseFirestore.instance.collection('users').add({
        'nama': _namaController.text.trim(),
        'nomor_absensi': _noAbsenController.text.trim().toUpperCase(),
        'password': _passwordController.text.trim(),
        'role': finalRoles,
        'divisi': _selectedDivisiKaryawan,
        'akses_divisi': aksesDivisiSimpan,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil membuat akun!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdminRole =
        _selectedRole != null &&
        (_selectedRole!.contains('Admin') ||
            _selectedRole == 'Data Entry' ||
            _selectedRole == 'Manager');

    return Scaffold(
      appBar: AppBar(title: const Text("Buat Akun Karyawan/Admin")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Akun",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecor("Nama Lengkap", Icons.person),
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _noAbsenController,
                decoration: _inputDecor("Nomor Absensi / ID", Icons.badge),
                validator: (val) => val!.isEmpty ? "ID wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                decoration: _inputDecor("Password Akun", Icons.lock),
                validator: (val) =>
                    val!.isEmpty ? "Password wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: _inputDecor("Jabatan / Role", Icons.work),
                hint: const Text("Pilih Jabatan"),
                items: _listRole
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedRole = val;
                    _selectedAksesDivisiAdmin = [];
                  });
                },
                validator: (val) => val == null ? "Wajib pilih jabatan" : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDivisiKaryawan,
                      decoration: _inputDecor(
                        "Divisi Penempatan",
                        Icons.business,
                      ),
                      hint: const Text("Pilih Divisi"),
                      items: _listDivisi
                          .map(
                            (div) =>
                                DropdownMenuItem(value: div, child: Text(div)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedDivisiKaryawan = val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    tooltip: "Tambah Divisi Baru",
                    onPressed: _tambahDivisiBaru,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                "*Klik (+) jika divisi belum ada di list",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 25),
              const Divider(thickness: 1),

              if (isAdminRole) ...[
                const SizedBox(height: 10),
                const Text(
                  "Hak Akses Admin (Opsional)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Text(
                  "Divisi mana saja yang boleh dikelola admin ini?",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurple.withOpacity(0.05),
                  ),
                  child: Wrap(
                    spacing: 8,
                    children: _listDivisi.map((divisi) {
                      final isSelected = _selectedAksesDivisiAdmin.contains(
                        divisi,
                      );
                      return FilterChip(
                        label: Text(divisi),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedAksesDivisiAdmin.add(divisi);
                            } else {
                              _selectedAksesDivisiAdmin.remove(divisi);
                            }
                          });
                        },
                        selectedColor: Colors.deepPurple.shade100,
                        checkmarkColor: Colors.deepPurple,
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "BUAT AKUN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
