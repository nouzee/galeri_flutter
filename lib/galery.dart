import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<dynamic> galleryItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchGalleryItems();
  }

  Future<void> fetchGalleryItems() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/webalbums'));
      
      if (response.statusCode == 200) {
        setState(() {
          galleryItems = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load gallery items';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to server: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchAlbumPhotos(String albumId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/webalbums/$albumId/webfotos')
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (e) {
      throw Exception('Error connecting to server: ${e.toString()}');
    }
  }

  void showPhotosModal(BuildContext context, String albumId, String albumName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: FutureBuilder(
            future: fetchAlbumPhotos(albumId),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Container(
                  height: 200,
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  height: 200,
                  child: Center(child: Text('No photos found in this album')),
                );
              }

              return Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    // Modal header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            albumName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // Photos grid
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final photo = snapshot.data![index];
                            return GestureDetector(
                              onTap: () {
                                // Show full screen image when tapped
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Container(
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: photo['gambar'],
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) => 
                                                Center(child: CircularProgressIndicator()),
                                              errorWidget: (context, url, error) => 
                                                Icon(Icons.error),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close, color: Colors.white),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: photo['gambar'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => 
                                      Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => 
                                      Icon(Icons.error),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 600 ? 4 : 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gallery',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.withOpacity(0.5),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.5),
              Colors.cyan.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : galleryItems.isEmpty
                    ? Center(child: Text('No gallery items found'))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: galleryItems.length,
                          itemBuilder: (context, index) {
                            final item = galleryItems[index];
                            return GestureDetector(
                              onTap: () {
                                showPhotosModal(context, item['id'].toString(), item['nama']);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: CachedNetworkImage(
                                          imageUrl: item['gambar'],
                                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        item['nama'] ?? 'Unnamed',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}