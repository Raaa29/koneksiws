import 'package:flutter/material.dart'; // Mengimpor library Flutter Material untuk komponen UI
import 'package:http/http.dart'
    as http; // Mengimpor library http untuk melakukan HTTP requests
import 'dart:convert'; // Mengimpor library dart:convert untuk pemrosesan JSON
import 'package:url_launcher/url_launcher.dart'; // Mengimpor library url_launcher untuk membuka URL

// Class Universitas untuk menampung data universitas
class Universitas {
  final String nama; // Variabel untuk nama universitas
  final String situs; // Variabel untuk situs web universitas

  // Constructor Universitas dengan parameter wajib
  Universitas({required this.nama, required this.situs});

  // Factory method untuk mengonversi JSON menjadi objek Universitas
  factory Universitas.fromJson(Map<String, dynamic> json) {
    return Universitas(
      // Mengambil data nama universitas, atau memberikan default jika tidak tersedia
      nama: json['name'] ?? 'Nama Tidak Tersedia',
      // Mengambil situs web pertama dari daftar web_pages, atau memberikan default jika tidak tersedia
      situs: json['web_pages'] != null && json['web_pages'].isNotEmpty
          ? json['web_pages'][0]
          : 'Website Tidak Tersedia',
    );
  }
}

// Class UniversitasList sebagai Stateful Widget untuk menampilkan daftar universitas
class UniversitasList extends StatefulWidget {
  @override
  _UniversitasListState createState() => _UniversitasListState();
}

class _UniversitasListState extends State<UniversitasList> {
  late Future<List<Universitas>> _universitasListFuture;

  @override
  void initState() {
    super.initState();
    _universitasListFuture =
        _fetchUniversitasList(); // Memanggil method untuk mengambil daftar universitas
  }

  // Method async untuk mengambil daftar universitas dari API
  Future<List<Universitas>> _fetchUniversitasList() async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=Indonesia'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Mengonversi data JSON menjadi list objek Universitas
      return data.map((json) => Universitas.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch universitas'); // Melempar exception jika gagal mengambil data
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Universitas>>(
      future: _universitasListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child:
                CircularProgressIndicator(), // Menampilkan loading indicator saat data sedang diambil
          );
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Menampilkan pesan error jika terjadi kesalahan
        } else if (snapshot.hasData) {
          final universitasList = snapshot.data!;
          // Menampilkan daftar universitas dalam ListView.builder
          return ListView.builder(
            itemCount: universitasList.length,
            itemBuilder: (context, index) {
              final universitas = universitasList[index];
              // Menampilkan data universitas dalam ListTile
              return ListTile(
                title: Text(universitas.nama), // Judul: Nama universitas
                subtitle:
                    Text(universitas.situs), // Subjudul: Situs web universitas
                onTap: () {
                  launch(universitas
                      .situs); // Membuka situs web universitas saat ListTile ditekan
                },
              );
            },
          );
        } else {
          return Text(
              'No data found'); // Menampilkan pesan jika tidak ada data yang ditemukan
        }
      },
    );
  }
}

// Fungsi main untuk menjalankan aplikasi Flutter
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas'), // Judul AppBar
      ),
      body:
          UniversitasList(), // Menampilkan UniversitasList sebagai body aplikasi
    ),
  ));
}
