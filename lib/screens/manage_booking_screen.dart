import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import 'home_screen.dart'; // ⬅️ Tambahkan ini

class ManageBookingScreen extends StatefulWidget {
  const ManageBookingScreen({Key? key}) : super(key: key);

  @override
  _ManageBookingScreenState createState() => _ManageBookingScreenState();
}

class _ManageBookingScreenState extends State<ManageBookingScreen> {
  late Future<List<Map<String, dynamic>>> bookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    bookings = DatabaseHelper().getBookings();
  }

  void _delete(int id) async {
    await DatabaseHelper().deleteBooking(id);
    setState(_loadBookings);
  }

  Future<void> _editBooking(Map<String, dynamic> booking) async {
    final nameController = TextEditingController(text: booking['gorName']);
    final locationController = TextEditingController(text: booking['location']);
    final priceController = TextEditingController(text: booking['price']);
    final facilityController = TextEditingController(text: booking['facility']);
    final noteController = TextEditingController(text: booking['note']);

    DateTime? selectedDate = DateTime.tryParse(booking['date']);
    TimeOfDay? selectedTime = TimeOfDay(
      hour: int.tryParse(booking['time'].split(":")[0]) ?? 0,
      minute: int.tryParse(booking['time'].split(":")[1]) ?? 0,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Edit Booking'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lapangan'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: facilityController,
                decoration: const InputDecoration(labelText: 'Fasilitas'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Tanggal'),
                subtitle: Text(
                  selectedDate != null
                      ? selectedDate!.toLocal().toString().split(' ')[0]
                      : 'Pilih tanggal',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('Waktu'),
                subtitle: Text(selectedTime?.format(context) ?? 'Pilih waktu'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDate != null && selectedTime != null) {
                  final newDate = selectedDate!.toIso8601String().split('T')[0];
                  final newTime = selectedTime!.format(context);

                  await DatabaseHelper().updateBookingAndLapangan(
                    id: booking['id'],
                    gorName: nameController.text,
                    location: locationController.text,
                    date: newDate,
                    time: newTime,
                    facility: facilityController.text,
                  );

                  final db = await DatabaseHelper().database;
                  await db.update(
                    'bookings',
                    {
                      'price': priceController.text,
                      'note': noteController.text,
                    },
                    where: 'id = ?',
                    whereArgs: [booking['id']],
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking berhasil diperbarui')),
                  );
                  setState(_loadBookings);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
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
        appBar: AppBar(
          title: const Text(
            'Kelola Booking',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF003366),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: bookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('Belum ada data booking'));
            }

            final data = snapshot.data as List<Map<String, dynamic>>;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (_, i) {
                final item = data[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['gorName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['location'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Tanggal: ${item['date']}'),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Jam: ${item['time']}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _editBooking(item),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _delete(item['id']),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
