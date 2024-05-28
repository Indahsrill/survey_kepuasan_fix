import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  String message = "";
  bool onLoading = false;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> fileRecords = [];

  Future<void> getImageGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> getImageCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> upload(File imageFile) async {
    DateTime now = DateTime.now();
    String formatWaktu = DateFormat('yyyyMMddHHmmss').format(now);
    String kodeDaerah = '1234';
    int length = await imageFile.length();
    Uri uri = Uri.parse("http://10.200.30.161:3000/upload");

    var stream = http.ByteStream(imageFile.openRead().cast());
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile(
      "image",
      stream,
      length,
      filename: '$kodeDaerah$formatWaktu.jpg',
    );

    request.files.add(multipartFile);
    setState(() {
      onLoading = true;
      message = "Uploading...";
    });
    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        message = "Survey uploaded successfully!";
      } else {
        message = "Survey upload failed with status: ${response.statusCode}";
      }
    } catch (error) {
      message = error.toString();
    }

    setState(() {
      onLoading = false;
    });
  }

  Future<void> fetchFileRecords() async {
    setState(() {
      onLoading = true;
      message = "Fetching records...";
    });

    try {
      final response =
          await http.get(Uri.parse("http://10.200.39.31:5000/file_records/"));
      print("strt");
      if (response.statusCode == 200) {
        setState(() {
          fileRecords = json.decode(response.body);
          message = "Records fetched successfully!";
          print("dia $fileRecords");
        });
      } else {
        setState(() {
          message = "Failed to fetch records: ${response.statusCode}";
        });
      }
    } catch (error) {
      setState(() {
        message = error.toString();
      });
    }

    setState(() {
      onLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFileRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: onLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Text(message),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(message),
                  _imageFile != null
                      ? Expanded(child: Image.file(_imageFile!))
                      : Expanded(
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: getImageGallery,
                                  child: const Icon(Icons.image),
                                ),
                                ElevatedButton(
                                  onPressed: getImageCamera,
                                  child: const Icon(Icons.camera_alt),
                                ),
                              ],
                            ),
                          ),
                        ),
                  _imageFile != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                });
                              },
                              child: const Text("Change Image"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await upload(_imageFile!);
                                setState(() {
                                  _imageFile = null;
                                });
                              },
                              child: const Text("Send Survey"),
                            ),
                          ],
                        )
                      : const Text("Please Select The Image"),
                  const SizedBox(height: 20),
                  fileRecords.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: fileRecords.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('ID: ${fileRecords[index]['id']}'),
                                subtitle:
                                    Text('File: ${fileRecords[index]['file']}'),
                              );
                            },
                          ),
                        )
                      : const Text("No records available"),
                ],
              ),
            ),
    );
  }
}
