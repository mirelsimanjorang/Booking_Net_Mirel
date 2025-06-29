class Booking {
  final int? id;
  final String name;
  final String time;
  final String price;

  Booking({this.id, required this.name, required this.time, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'price': price,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      name: map['name'],
      time: map['time'],
      price: map['price'],
    );
  }
}
