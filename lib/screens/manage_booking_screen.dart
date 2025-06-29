import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_helper.dart';
import 'home_screen.dart';

class ManageBookingScreen extends StatefulWidget {
  const ManageBookingScreen({Key? key}) : super(key: key);

  @override
  State<ManageBookingScreen> createState() => _ManageBookingScreenState();
}

class _ManageBookingScreenState extends State<ManageBookingScreen> {
  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _filteredBookings = [];

  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
    final data = await DatabaseHelper().getBookings();
    setState(() {
      _allBookings = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredBookings = _allBookings.where((booking) {
        final matchName = booking['gorName']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        final matchDate = _selectedDate == null ||
            booking['date'] == DateFormat('yyyy-MM-dd').format(_selectedDate!);

        return matchName && matchDate;
      }).toList();
    });
  }

  void _delete(int id) async {
    await DatabaseHelper().deleteBooking(id);
    _loadBookings();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
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
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                if (selectedDate != null && selectedTime != null) {
                  final newDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _applyFilters();
      });
    }
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
          title: const Text(
            'Kelola Booking',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF003366),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                          _applyFilters();
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Cari berdasarkan nama lapangan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF003366)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _filteredBookings.isEmpty
                  ? const Center(child: Text('Data booking tidak ditemukan.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredBookings.length,
                      itemBuilder: (_, i) {
                        final item = _filteredBookings[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.black38, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['gorName'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003366),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.place, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(item['location'])),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Tanggal: ${item['date']}'),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Jam: ${item['time']}'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _editBooking(item),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _delete(item['id']),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'Hapus',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}