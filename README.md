<div align="center">

# 🏭 Shinpo App

### 🇮🇩 Sistem Informasi Operasional Pabrik & Manajemen Terpadu Berbasis Mobile
### 🇬🇧 Integrated Factory Operations & Workforce Management Mobile App

<br/>

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Firestore-Database-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![ML Kit](https://img.shields.io/badge/ML%20Kit-Face%20Detection-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Geolocator](https://img.shields.io/badge/GPS-Geofencing-34A853?style=for-the-badge&logo=googlemaps&logoColor=white)
![Security](https://img.shields.io/badge/SafeDevice-Anti%20Root%20%26%20Mock-EA4335?style=for-the-badge&logo=shield&logoColor=white)

</div>

---

## 🇮🇩 Deskripsi Proyek

**Shinpo App** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mengintegrasikan seluruh alur operasional manufaktur dan manajemen tenaga kerja di PT Shinpo ke dalam satu platform digital terpadu secara *real-time*.

Aplikasi ini mencakup alur multi-divisi yang komprehensif mulai dari **PPIC (Production Planning and Inventory Control)**, **Operator Produksi**, **Gudang (Warehouse)**, **Supir & Logistik Pengiriman**, **HRD & Penggajian**, **Admin**, hingga **Manager Dashboard**. Dilengkapi dengan sistem presensi berkeamanan tinggi menggunakan **Google ML Kit Face Detection**, verifikasi koordinat **GPS Geofencing**, serta sistem proteksi multi-lapis terhadap **Fake GPS, Perangkat Root/Jailbreak, dan Emulator**.

---

## 🇬🇧 Project Description

**Shinpo App** is an enterprise-grade Flutter mobile application designed to streamline and unify factory manufacturing workflows and workforce management for Shinpo into a single, real-time integrated platform.

The system connects cross-divisional operations including **PPIC (Production Planning & Inventory Control)**, **Production Floor Operators**, **Warehouse & Stock Management**, **Delivery Logistics & Drivers**, **HRD & Payroll**, **Administration**, and **Executive Management Dashboards**. It features an enterprise-level attendance verification system powered by **Google ML Kit Face Detection**, precision **GPS Geofencing radius validation**, and multi-tiered security defense against **Fake GPS mock locations, Root/Jailbreak tampering, and Emulator environments**.

---

## ✨ Fitur Utama & Struktur Aplikasi (Core Features & App Structure)

---

### 🇮🇩 Bahasa Indonesia

**A. Presensi Biometrik & Keamanan Tingkat Tinggi**

- 👤 **Face ID & Deteksi Wajah Otomatis:** Deteksi wajah presisi tinggi secara langsung menggunakan Google ML Kit sebelum absensi diterima.
- 📍 **Validasi Radius GPS:** Memvalidasi jarak aktual pengguna terhadap koordinat GPS pabrik/kantor secara otomatis (maksimal toleransi radius yang ditentukan).
- 🚫 **Anti-Fake GPS:** Mendeteksi penggunaan aplikasi Fake GPS / Mock Location dengan sistem pencatatan pelanggaran bertingkat (Counter 1-3) yang terhubung langsung ke log pelanggaran HRD.
- 🛡️ **Deteksi Root, Jailbreak & Emulator:** Memblokir perangkat yang telah di-root atau emulator virtual demi menjaga integritas data perusahaan.
- 📸 **Bukti Foto Wajah & Lingkungan:** Menyimpan foto verifikasi wajah dan foto kondisi area saat absensi dalam bentuk terenkripsi.

**B. PPIC (Perencanaan & Pengendalian Produksi)**

- 📑 **Form PO Induk & PO Komponen:** Pembuatan dan pencatatan Purchase Order induk maupun rincian kebutuhan komponen material.
- 📊 **Form Rencana Produksi:** Penyusunan target dan jadwal alur produksi pabrik secara terstruktur.
- 🔍 **Detail & Laporan PO:** Pemantauan status pengerjaan setiap PO komponen dan rekapitulasi laporan PPIC secara terpadu.

**C. Operator Lantai Produksi**

- ⏱️ **Operator Dashboard:** Antarmuka khusus operator mesin/lini produksi untuk mencatat output pekerjaan harian.
- 📈 **Kalkulasi Kinerja Otomatis:** Perhitungan performa dan pencapaian target kerja operator secara otomatis dan transparan.
- 📋 **Laporan Produksi Real-Time:** Sinkronisasi langsung data hasil produksi ke database pusat.

**D. Gudang & Manajemen Stok**

- 📦 **Gudang Kardus & Komponen:** Monitoring ketersediaan stok kardus pembungkus dan bahan baku.
- 🚚 **Form Surat Jalan Digital:** Pembuatan surat jalan resmi untuk pengiriman barang keluar secara akurat dan terdokumentasi.
- 📦 **Monitoring Pengiriman Barang:** Status pengiriman barang keluar dari gudang secara real-time.

**E. Supir & Pelacakan Pengiriman**

- 🗺️ **Tracking Pengiriman GPS:** Pelacakan rute dan lokasi armada pengiriman dari gudang ke alamat tujuan.
- 🚛 **Sopir Delivery Screen:** Tampilan khusus supir untuk memverifikasi surat jalan, alamat bongkar muat, dan update status pengantaran barang.

**F. HRD & Penggajian (Payroll)**

- 👥 **Monitoring Absensi Karyawan:** Pemantauan kehadiran, keterlambatan, dan riwayat absensi seluruh staf dan operator secara harian/bulanan.
- 💵 **Kelola Gaji Karyawan:** Kalkulasi gaji berdasarkan kehadiran dan kinerja secara akurat.
- 📊 **Pengaturan Kriteria Kinerja:** Konfigurasi bobot kriteria evaluasi kinerja karyawan.

**G. Panel Admin & Manajemen Akun**

- ➕ **Tambah & Kelola Karyawan:** Pembuatan akun karyawan baru dengan penugasan divisi/role yang spesifik.
- 🔐 **Autentikasi Fleksibel:** Mendukung login menggunakan Nomor Induk Absensi maupun Alamat Email resmi.
- 📊 **Ekspor Laporan ke Excel:** Mengunduh rekapitulasi data absensi, produksi, dan penggajian langsung ke file format Microsoft Excel (.xlsx).
- 📸 **Fitur Screenshot Laporan:** Kemudahan membagikan bukti laporan digital via service screenshot bawaan.

**H. Komunikasi Internal & Leaderboard**

- 💬 **Pesan Internal:** Ruang komunikasi dan instruksi kerja antar karyawan dan manajemen.
- 🏆 **Leaderboard Kinerja:** Menampilkan peringkat karyawan terbaik berdasarkan pencapaian produktivitas dan kedisiplinan.
- 🔄 **Sistem Auto-Update:** Layanan pengecekan pembaruan versi aplikasi (*force update/optional update*) langsung dari Firestore.

---

### 🇬🇧 English

**A. Biometric Attendance & Enterprise Security**

- 👤 **Face ID & Auto Face Detection:** High-precision facial detection via Google ML Kit before attendance submission.
- 📍 **GPS Geofencing Radius:** Automatic distance calculation against factory coordinates ensuring presence within allowed office premises.
- 🚫 **Anti-Fake GPS Protection:** Mock location detection with a 3-strike violation logging system directly reported to HRD violations database.
- 🛡️ **Anti-Root, Jailbreak & Emulator Shield:** Enforces strict execution policies preventing compromised or emulated devices.
- 📸 **Photo Verification:** Securely captures and archives facial validation and area proof alongside geolocation coordinates.

**B. PPIC (Production Planning & Inventory Control)**

- 📑 **Master PO & Component PO:** Creation and lifecycle tracking for master purchase orders and auxiliary component requests.
- 📊 **Production Scheduling Form:** Systematic production target definition and timeline workflow.
- 🔍 **PO Monitoring & Reports:** Real-time visibility into component delivery progress and comprehensive PPIC analytical reporting.

**C. Production Floor Operators**

- ⏱️ **Operator Dashboard:** Dedicated interface for machine and line operators to submit daily output counts.
- 📈 **Automated Performance Calculation:** Objective, metrics-driven operator productivity calculations.
- 📋 **Live Production Logs:** Immediate synchronization of production output to central Firestore storage.

**D. Warehouse & Inventory Management**

- 📦 **Packaging & Material Stock:** Real-time tracking of carton packaging and raw component stock.
- 🚚 **Digital Waybills (Surat Jalan):** Generation and management of verified delivery dispatch notes.
- 📦 **Outbound Shipment Monitoring:** Live status updates for goods departing warehouse docks.

**E. Drivers & Fleet Delivery Tracking**

- 🗺️ **GPS Delivery Tracking:** Live route updates and geolocation verification for logistics fleets.
- 🚛 **Driver Delivery Portal:** Tailored interface for delivery drivers to review waybills, verify drop points, and update delivery completion.

**F. HRD & Automated Payroll**

- 👥 **Workforce Attendance Monitoring:** Daily and monthly presence audit trail with timestamp verification.
- 💵 **Payroll Management:** Structured compensation calculations aligned with verified attendance and performance metrics.
- 📊 **Performance Criteria Matrix:** Configurable multi-criteria evaluation standards.

**G. Administration & Workforce Control**

- ➕ **Employee Account Provisioning:** User onboarding with division-specific role-based access control (RBAC).
- 🔐 **Flexible Identifier Login:** Seamless authentication using either Employee ID / Badge Number or Corporate Email.
- 📊 **Microsoft Excel Export:** One-click export for attendance, production logs, and payroll summaries into `.xlsx` spreadsheets.
- 📸 **In-App Report Capture:** Native screenshot capture utility for prompt report sharing across divisions.

**H. Internal Messaging & Gamified Leaderboard**

- 💬 **Inter-departmental Chat:** Internal communication hub for operational notices and shift handovers.
- 🏆 **Productivity Leaderboard:** Performance ranking highlighting top-performing operators and staff.
- 🔄 **Over-the-Air Update Engine:** Configurable in-app version update notifier supporting both mandatory and optional updates.

---

## 🧰 Tech Stack

- **Framework:** Flutter 3.x / Dart 3.x
- **Architecture & State Management:** Provider (`MultiProvider` architecture)
- **Backend & Cloud Services:** Cloud Firestore, Firebase Core
- **Computer Vision & Hardware:** Google ML Kit Face Detection, Camera, Local Auth
- **Location & Sensors:** Geolocator (GPS Geofencing & Mock Location Detection)
- **Security & Integrity:** Safe Device (Root/Jailbreak Detection, Emulator Detection)
- **Office & Documents:** Excel (`excel`), Share Plus, Screenshot
- **Storage & Networking:** SharedPreferences, URL Launcher, Package Info Plus

---

## ⚙️ Setup Firebase (Wajib / Required)

File konfigurasi Firebase **tidak disertakan** di repository publik ini demi menjaga keamanan API Key dan kredensial sensitif.  
*Firebase configuration files are **excluded** from this repository to protect secret keys and cloud credentials.*

**1. Buat project Firebase / Create a Firebase Project**
- Buka / Open: [https://console.firebase.google.com/](https://console.firebase.google.com/)
- Aktifkan / Enable: **Cloud Firestore**

**2. Setup `lib/firebase_options.dart`**
```bash
cp lib/firebase_options.dart.example lib/firebase_options.dart
# Isi dengan nilai konfigurasi Firebase project Anda
# Fill it with your Firebase project configurations
```
> Atau jalankan / Or run: `flutterfire configure`

**3. Setup `android/app/google-services.json`**
```bash
cp android/app/google-services.json.example android/app/google-services.json
# Unduh file asli dari Firebase Console → Project Settings → Android App
```

**4. Setup `firebase.json`**
```bash
cp firebase.json.example firebase.json
```

---

## 🚀 Menjalankan Aplikasi / Running the App

```bash
# 1. Unduh seluruh dependensi paket
flutter pub get

# 2. Jalankan aplikasi pada perangkat/emulator yang terhubung
flutter run
```

---

## 📁 Struktur Proyek / Project Structure

```
lib/
├── core/
│   ├── constants.dart                  # Titik koordinat GPS kantor & toleransi jarak
│   ├── excel_service.dart              # Ekspor data absensi/kinerja ke Microsoft Excel (.xlsx)
│   ├── screenshot_service.dart         # Pengambilan tangkapan layar laporan
│   ├── services/
│   │   ├── security_service.dart       # Deteksi Root, Jailbreak, Emulator, & Fake GPS
│   │   └── update_service.dart         # Remote app update checker via Firestore
│   └── utils/
│       └── kinerja_calculator.dart     # Algoritma perhitungan evaluasi kinerja karyawan
├── data/
│   ├── models/
│   │   ├── kriteria_model.dart         # Model kriteria penilaian kinerja HRD
│   │   └── produksi_model.dart         # Model pencatatan hasil produksi harian
│   └── repositories/
│       ├── absensi_repository.dart     # Pengolahan presensi, encoding foto base64, & Firestore
│       └── produksi_repository.dart    # Stream & penyimpanan transaksi produksi
├── providers/
│   ├── admin_provider.dart             # State management user, karyawan, & kriteria
│   ├── auth_provider.dart              # Autentikasi sesi multi-login (Email / No. Absensi)
│   ├── logistik_provider.dart          # State management pengiriman, surat jalan, & stok gudang
│   └── produksi_provider.dart          # State management alur produksi & PO komponen
├── ui/
│   ├── admin/
│   │   ├── laporan_ppic_screen.dart
│   │   ├── pengaturan_kriteria_screen.dart
│   │   └── tambah_karyawan_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   ├── gudang/
│   │   ├── form_surat_jalan_screen.dart
│   │   ├── gudang_dashboard_screen.dart
│   │   ├── gudang_kardus_screen.dart
│   │   ├── monitoring_pengiriman_screen.dart
│   │   └── sopir_delivery_screen.dart
│   ├── hrd/
│   │   ├── hrd_dashboard_screen.dart
│   │   ├── kelola_gaji_screen.dart
│   │   └── monitoring_absensi_screen.dart
│   ├── operator/
│   │   └── operator_dashboard.dart
│   ├── pesan/
│   │   └── pesan_screen.dart
│   ├── ppic/
│   │   ├── detail_po_komponen_screen.dart
│   │   ├── form_po_induk.dart
│   │   ├── form_po_komponen.dart
│   │   ├── form_rencana_produksi.dart
│   │   └── ppic_dashboard_screen.dart
│   ├── shared/
│   │   └── leaderboard_screen.dart
│   ├── supir/
│   │   └── tracking_pengiriman_screen.dart
│   ├── dashboard_screen.dart
│   ├── face_id_screen.dart
│   ├── manager_dashboard_screen.dart
│   └── riwayat_absensi_screen.dart
├── firebase_options.dart.example
└── main.dart
```

---

<div align="center">

**© 2026 Shinpo App - Muhammad Dicky Adicandra**

</div>
