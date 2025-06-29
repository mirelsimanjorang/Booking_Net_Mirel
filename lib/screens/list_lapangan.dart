import 'dart:io';
import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/lapangan_model.dart';
import 'booking_screen.dart';
import 'home_screen.dart'; 

class ListLapanganScreen extends StatefulWidget {
  const ListLapanganScreen({Key? key}) : super(key: key);

  @override
  State<ListLapanganScreen> createState() => _ListLapanganScreenState();
}

class _ListLapanganScreenState extends State<ListLapanganScreen> {
  late Future<List<Map<String, dynamic>>> lapanganList;

  @override
  void initState() {
    super.initState();
    _loadLapangan();
  }

  void _loadLapangan() {
    lapanganList = DatabaseHelper().getAllLapanganBelumDibooking();
  }

  Future<void> _refreshAfterBooking() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _loadLapangan();
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Daftar Lapangan', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF003366),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: lapanganList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada lapangan tersedia untuk dibooking.'));
            }

            final lapangan = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lapangan.length,
              itemBuilder: (_, i) {
                final item = lapangan[i];
                final isLocalImage =
                    item['image'] != null && item['image'].toString().startsWith('/');

                return Card(
                  color: Colors.white,
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: item['image'] != null
                            ? (isLocalImage
                                ? Image.file(
                                    File(item['image']),
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    item['image'],
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ))
                            : Container(
                                height: 160,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child:
                                    const Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003366),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['location'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                const Icon(Icons.star, size: 16, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text('${item['rating'] ?? 0.0}',
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                getFacilityIcon(item['facility']),
                                const SizedBox(width: 6),
                                Text(item['facility'] ?? 'Tidak tersedia',
                                    style: const TextStyle(fontSize: 13)),
                                const Spacer(),
                                Text(
                                  'Rp ${item['price']} /Jam',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF003366),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingScreen(
                                        gor: Gor(
                                          id: item['id'],
                                          name: item['name'],
                                          location: item['location'],
                                          price: item['price'],
                                          rating: double.tryParse(
                                                  item['rating'].toString()) ??
                                              0.0,
                                          image: item['image'],
                                          facility: item['facility'] ?? '',
                                        ),
                                      ),
                                    ),
                                  );
                                  _refreshAfterBooking();
                                },
                                icon: const Icon(Icons.sports_tennis,
                                    size: 18, color: Colors.white),
                                label: const Text("Booking Sekarang",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget getFacilityIcon(String? facility) {
    switch (facility?.toLowerCase()) {
      case 'wifi':
        return const Icon(Icons.wifi, size: 18, color: Colors.blueAccent);
      case 'kantin':
        return const Icon(Icons.restaurant, size: 18, color: Colors.orange);
      case 'parkir':
        return const Icon(Icons.local_parking, size: 18, color: Colors.green);
      case 'toilet':
        return const Icon(Icons.wc, size: 18, color: Colors.purple);
      case 'ac':
        return const Icon(Icons.ac_unit, size: 18, color: Colors.cyan);
      default:
        return const Icon(Icons.category, size: 18, color: Colors.grey);
    }
  }
}
