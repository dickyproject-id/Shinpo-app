// lib/ui/face_id_screen.dart
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceIdScreen extends StatefulWidget {
  final String tipe; // "Masuk", "Pulang", "Istirahat", dll
  const FaceIdScreen({super.key, required this.tipe});

  @override
  State<FaceIdScreen> createState() => _FaceIdScreenState();
}

// Tambahkan WidgetsBindingObserver untuk memantau aplikasi (Minimize/Resume)
class _FaceIdScreenState extends State<FaceIdScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isPictureTaken = false;

  late FaceDetector _faceDetector;

  String _statusText = "Mencari Wajah...";
  Color _statusColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Daftarkan observer

    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableLandmarks: false,
    );
    _faceDetector = FaceDetector(options: options);

    _initCamera();
  }

  // === FUNGSI LIFECYCLE (PENTING UNTUK MENCEGAH ERROR KAMERA) ===
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // Jika tidak ada controller, tidak perlu diproses
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Jika aplikasi diminimalisir/keluar sebentar -> MATIKAN KAMERA
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Jika aplikasi dibuka kembali -> NYALAKAN ULANG KAMERA
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    // Cek Izin Kamera
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Izin kamera ditolak")));
        Navigator.pop(context);
      }
      return;
    }

    // Ambil list kamera
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    // Pilih kamera depan
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // Setup Controller baru
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium, // Resolusi medium lebih stabil
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;

      // Set Zoom level ke 1.0 (Reset zoom)
      await _cameraController!.setZoomLevel(1.0);

      setState(() => _isCameraInitialized = true);
      _startImageStream();
    } catch (e) {
      debugPrint("Error inisialisasi kamera: $e");
      if (e is CameraException) {
        // Tangani error spesifik kamera
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    }
  }

  void _startImageStream() {
    if (_cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing || _isPictureTaken) return;
      _isProcessing = true;

      try {
        final inputImage = _convertCameraImageToInputImage(image);
        if (inputImage == null) return;

        final faces = await _faceDetector.processImage(inputImage);
        _processFaceResult(faces);
      } catch (e) {
        debugPrint("Error deteksi wajah: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  void _processFaceResult(List<Face> faces) {
    if (!mounted || _isPictureTaken) return;

    setState(() {
      if (faces.isEmpty) {
        _statusText = "Wajah tidak ditemukan";
        _statusColor = Colors.red;
      } else if (faces.length > 1) {
        _statusText = "Hanya 1 Orang yang diperbolehkan!";
        _statusColor = Colors.red;
      } else {
        // SUKSES DETEKSI
        _statusText = "Wajah Terdeteksi. Tahan...";
        _statusColor = Colors.green;
        _autoCapture();
      }
    });
  }

  Future<void> _autoCapture() async {
    if (_isPictureTaken || _cameraController == null) return;

    // Pastikan kamera masih aktif
    if (!_cameraController!.value.isInitialized) return;

    setState(() => _isPictureTaken = true); // Kunci biar gak double

    try {
      // Stop stream dulu agar tidak crash
      await _cameraController!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 300)); // Jeda sedikit

      XFile file = await _cameraController!.takePicture();

      if (!mounted) return;

      // Kembalikan path foto ke Dashboard
      Navigator.pop(context, file.path);
    } catch (e) {
      debugPrint("Gagal ambil foto: $e");
      // Jika gagal, reset state agar bisa coba lagi
      if (mounted) {
        setState(() {
          _isPictureTaken = false;
          _initCamera(); // Restart kamera jika crash
        });
      }
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Hapus observer
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan Loading jika kamera belum siap
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Menyiapkan Kamera...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Preview Kamera Full
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_cameraController!),
          ),

          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Absen ${widget.tipe}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusColor == Colors.green
                            ? Icons.check_circle
                            : Icons.warning_amber,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),

          // Tombol Back
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
