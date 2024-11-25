import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'galery.dart';
import 'info.dart';
import 'agenda.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> newsData = [];
  List<dynamic> eventsData = [];
  List<dynamic> albumsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final newsResponse = await http.get(Uri.parse('http://localhost:5000/api/webnews'));
      final eventsResponse = await http.get(Uri.parse('http://localhost:5000/api/webevents'));
      final albumsResponse = await http.get(Uri.parse('http://localhost:5000/api/webalbums'));

      if (newsResponse.statusCode == 200) {
        newsData = json.decode(newsResponse.body);
      }
      if (eventsResponse.statusCode == 200) {
        eventsData = json.decode(eventsResponse.body);
      }
      if (albumsResponse.statusCode == 200) {
        albumsData = json.decode(albumsResponse.body);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            children: [
              // Banner Section
              Stack(
                children: [
                  Image.asset(
                    'assets/banner.jpg',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Kami menghargai kunjungan Anda.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi
                    SectionTitle(title: 'Informasi'),
                    NewsPreview(
                      news: newsData.take(2).toList(),
                      onItemTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InfoScreen()),
                        );
                      },
                    ),

                    // Agenda
                    SectionTitle(title: 'Agenda'),
                    EventsPreview(
                      events: eventsData.take(2).toList(),
                      onItemTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AgendaScreen()),
                        );
                      },
                    ),

                    // Galeri
                    SectionTitle(title: 'Galeri'),
                    AlbumsPreview(
                      albums: albumsData.take(2).toList(),
                      onItemTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GalleryScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class NewsPreview extends StatelessWidget {
  final List<dynamic> news;
  final VoidCallback onItemTap;

  const NewsPreview({required this.news, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: news.map((item) {
        return GestureDetector(
          onTap: onItemTap,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(item['nama'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['deskripsi'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Dipost pada ${DateFormat.yMMMMd().format(DateTime.parse(item['createdAt']))}'),
                ],
              ),
              leading: Icon(Icons.info, color: Colors.teal),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class EventsPreview extends StatelessWidget {
  final List<dynamic> events;
  final VoidCallback onItemTap;

  const EventsPreview({required this.events, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.map((item) {
        return GestureDetector(
          onTap: onItemTap,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(item['nama'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['deskripsi'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Dipost pada ${DateFormat.yMMMMd().format(DateTime.parse(item['createdAt']))}'),
                ],
              ),
              leading: Icon(Icons.event, color: Colors.teal),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AlbumsPreview extends StatelessWidget {
  final List<dynamic> albums;
  final VoidCallback onItemTap;

  const AlbumsPreview({required this.albums, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return GestureDetector(
          onTap: onItemTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  album['gambar'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.error),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      album['nama'] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}