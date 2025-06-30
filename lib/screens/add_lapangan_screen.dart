import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../services/db_helper.dart';
import 'home_screen.dart';

class AddLapanganScreen extends StatefulWidget {
  const AddLapanganScreen({super.key});

  @override
  State<AddLapanganScreen> createState() => _AddLapanganScreenState();
}

class _AddLapanganScreenState extends State<AddLapanganScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final ratingController = TextEditingController();
  final facilityController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _pickLocation() async {
    final location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi tidak aktif')),
        );
        return;
      }
    }

    var permission = await location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != loc.PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak')),
        );
        return;
      }
    }

    try {
      final data = await location.getLocation();
      final lat = data.latitude;
      final lon = data.longitude;

      if (lat == null || lon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi tidak ditemukan')),
        );
        return;
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
        setState(() => locationController.text = address);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alamat berhasil ditemukan: $address')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan alamat')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error lokasi: $e')),
      );
    }
  }

  Future<void> _saveLapangan() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data dan pilih gambar.')),
      );
      return;
    }

    try {
      await DatabaseHelper().insertLapangan({
        'name': nameController.text,
        'location': locationController.text,
        'price': priceController.text,
        'rating': double.parse(ratingController.text),
        'facility': facilityController.text,
        'image': _selectedImage!.path,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lapangan berhasil ditambahkan!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF003366), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFF003366),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          title: const Text(
            'Tambah Lapangan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Gambar Lapangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text("Ambil dari Kamera"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF003366),
                    ),
                  ),
                ),
                const Divider(height: 32),
                const Text(
                  'Detail Lapangan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(nameController, 'Nama Lapangan', Icons.title),
                const SizedBox(height: 12),
                _buildTextField(priceController, 'Harga per Jam (Rp)', Icons.monetization_on,
                    type: TextInputType.number),
                const SizedBox(height: 12),
                _buildTextField(ratingController, 'Rating (0-5)', Icons.star,
                    type: TextInputType.number),
                const SizedBox(height: 12),
                _buildTextField(facilityController, 'Fasilitas', Icons.sports_tennis),
                const SizedBox(height: 12),
                const Text(
                  'Lokasi Otomatis',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(locationController, 'Lokasi', Icons.location_on),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      color: const Color(0xFF003366),
                      tooltip: 'Deteksi Lokasi',
                      onPressed: _pickLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Simpan Lapangan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _saveLapangan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

