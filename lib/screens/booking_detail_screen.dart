import 'dart:io';
import 'package:flutter/material.dart';

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(booking['image']),
            const SizedBox(height: 20),
            _buildInfoRow('Nama GOR', booking['gorName']),
            _buildInfoRow('Lokasi', booking['location']),
            _buildInfoRow('Tanggal', booking['date']),
            _buildInfoRow('Waktu', booking['time']),
            _buildInfoRow('Harga', 'Rp ${booking['price']}'),
            _buildInfoRow('Rating', '${booking['rating']} ⭐'),
            _buildInfoRow('Fasilitas', booking['facility']),
            _buildInfoRow('Catatan', booking['note']),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 120, color: Colors.grey),
      );
    } else if (path.startsWith('/')) {
      // Gambar lokal
      final file = File(path);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
        ),
      );
    } else {
      // Gambar dari internet
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          path,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
        ),
      );
    }
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value?.isNotEmpty == true ? value! : '-', maxLines: 3),
          ),
        ],
      ),
    );
  }
}
