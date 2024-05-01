import 'package:flutter/material.dart'; // Mengimpor library Flutter Material untuk komponen UI
import 'package:http/http.dart'
    as http; // Mengimpor library http untuk melakukan HTTP requests
import 'dart:convert'; // Mengimpor library dart:convert untuk pemrosesan JSON

void main() {
  runApp(const MyApp()); // Menjalankan aplikasi Flutter dengan widget MyApp
}

// Class untuk menampung data hasil pemanggilan API
class Activity {
  String aktivitas;
  String jenis;

  Activity(
      {required this.aktivitas,
      required this.jenis}); // Constructor dengan parameter wajib

  // Factory method untuk mengonversi JSON menjadi objek Activity
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      aktivitas: json['activity'],
      jenis: json['type'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  late Future<Activity>
      futureActivity; // Variabel untuk menampung hasil future Activity
  String url = "https://www.boredapi.com/api/activity"; // URL endpoint API

  Future<Activity> init() async {
    return Activity(
        aktivitas: "",
        jenis: ""); // Mengembalikan objek Activity kosong sebagai default
  }

  // Method untuk melakukan HTTP GET request ke API dan mengembalikan objek Activity
  Future<Activity> fetchData() async {
    final response =
        await http.get(Uri.parse(url)); // Melakukan HTTP GET request
    if (response.statusCode == 200) {
      // Jika response status code adalah 200 OK (berhasil),
      // Parse JSON response dan kembalikan objek Activity
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      // Jika request gagal (bukan 200 OK),
      // Throw Exception dengan pesan 'Gagal load'
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futureActivity =
        init(); // Menginisialisasi futureActivity dengan Activity kosong
  }

  @override
  Widget build(Object context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      futureActivity =
                          fetchData(); // Memanggil fetchData untuk mengupdate futureActivity
                    });
                  },
                  child: Text("Saya bosan ..."),
                ),
              ),
              // Widget FutureBuilder untuk menampilkan data dari futureActivity
              FutureBuilder<Activity>(
                future: futureActivity,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Jika snapshot memiliki data,
                    // Tampilkan data aktivitas dan jenis
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              snapshot.data!.aktivitas), // Teks untuk aktivitas
                          Text(
                              "Jenis: ${snapshot.data!.jenis}") // Teks untuk jenis aktivitas
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Jika terjadi error saat fetching data,
                    // Tampilkan pesan error
                    return Text('${snapshot.error}');
                  }
                  // Jika data belum tersedia, tampilkan loading indicator
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
