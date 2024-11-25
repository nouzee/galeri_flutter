import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoScreen extends StatelessWidget {
  Future<List<dynamic>> fetchInfo() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/webnews'));
    if (response.statusCode == 200) {
      return json.decode(response.body); // Mengembalikan list
    } else {
      throw Exception('Failed to load info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final infoList = snapshot.data!; // Ambil semua item dari list
          return ListView.builder(
            itemCount: infoList.length,
            itemBuilder: (context, index) {
              final info = infoList[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Icon info di sebelah kiri
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16),
                      // Konten di sebelah kanan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info['nama'], // Nama informasi
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              info['deskripsi'], // Deskripsi informasi
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tanggal di post: ${info['createdAt']}', // Tanggal dibuat
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: Text('No info found'));
        }
      },
    );
  }
}
