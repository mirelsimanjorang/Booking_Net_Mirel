import 'dart:io';
import 'package:flutter/material.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                /// Gambar header full
                Stack(
                  children: [
                    _buildImage(booking['image']),

                    /// Tombol back di atas gambar
                    Positioned(
                      top: 16,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                /// Konten putih di bawah gambar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Nama GOR
                      Text(
                        booking['gorName'] ?? '-',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Lokasi
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.teal, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking['location'] ?? '-',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${booking['rating'] ?? '0'} (reviews)',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// Deskripsi Singkat
                      const Text(
                        'Ini aktivitas digelar rutin setiap akhir atau awal semester.',
                        style: TextStyle(fontSize: 13),
                      ),

                      const SizedBox(height: 24),

                      /// Informasi Aktivitas
                      const Text(
                        'Informasi Aktivitas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _infoRow('Tanggal Main', booking['date']),
                            _infoRow('Jam Main', booking['time']),
                            _infoRow('Harga', 'Rp ${booking['price'] ?? '-'}'),
                            _infoRow('Catatan', booking['note']),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Fasilitas
                      const Text(
                        'Fasilitas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFacility(booking['facility']),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Tombol SELESAI
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // kembali ke halaman sebelumnya
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SELESAI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Text(': '),
          Text(
            (value?.isNotEmpty ?? false) ? value! : '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacility(String? facilityStr) {
    if (facilityStr == null || facilityStr.isEmpty) {
      return const Text('-');
    }

    final facilities = facilityStr.split(',').map((f) => f.trim()).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: facilities.map((item) {
        return Chip(
          label: Text(item),
          backgroundColor: Colors.grey[200],
          labelStyle: const TextStyle(fontSize: 12),
        );
      }).toList(),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 100)),
      );
    } else if (path.startsWith('/')) {
      return Image.file(
        File(path),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        path,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 100),
      );
    }
  }
}
