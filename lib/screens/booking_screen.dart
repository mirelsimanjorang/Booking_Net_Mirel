import 'package:flutter/material.dart';
import '../models/lapangan_model.dart';
import '../services/db_helper.dart';

class BookingScreen extends StatefulWidget {
  final Gor gor;

  const BookingScreen({Key? key, required this.gor}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController catatanController = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal dan waktu harus dipilih')),
      );
      return;
    }

    final newDate = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    final newTime = selectedTime!.format(context);

    await DatabaseHelper().addBooking(
      gorName: widget.gor.name,
      location: widget.gor.location,
      date: newDate,
      time: newTime,
      price: widget.gor.price.toString(),
      image: widget.gor.image ?? '',
      rating: widget.gor.rating.toString(),
      facility: widget.gor.facility ?? '',
      note: catatanController.text,
    );

    // ✅ Update status booking hanya jika ID tersedia
    if (widget.gor.id != null) {
      await DatabaseHelper().updateLapanganBookingStatus(widget.gor.id!, 1);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking berhasil')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Booking', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.gor.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Pilih Tanggal'),
              subtitle: Text(
                selectedDate != null
                    ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                    : 'Belum dipilih',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              title: const Text('Pilih Waktu'),
              subtitle: Text(selectedTime?.format(context) ?? 'Belum dipilih'),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(labelText: 'Catatan (Opsional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Konfirmasi Booking', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
