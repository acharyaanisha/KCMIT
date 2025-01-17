import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kcmit/service/config.dart';
import 'package:kcmit/view/studentScreen/pdfScreen.dart';
import 'package:path_provider/path_provider.dart';

class Resource extends StatefulWidget {
  const Resource({super.key});

  @override
  State<Resource> createState() => _ResourceState();
}

class _ResourceState extends State<Resource> {
  String errorMessage = '';
  bool isLoading = true;
  List<dynamic> resourceData = [];
  bool isDownloading = false;
  String downloadProgress = '';
  List<bool> _isExpandedList = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    fetchResourceData();
    checkConnection();
  }


  Future<void> _refreshData() async {

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fetchResourceData();
    });
  }

  Future<void> checkConnection() async {
    ConnectivityResult connectivityResult = (await Connectivity().checkConnectivity()) as ConnectivityResult;
    if (connectivityResult == ConnectivityResult.wifi) {

      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() {
            message =  'assets/no_internet.png';
          });
        } else {
          setState(() {
            message =  'assets/no_internet.png';
          });
        }
      } on SocketException catch (_) {
        setState(() {
          message = 'assets/no_internet.png';
        });
      }
    } else {
      setState(() {
        message = 'assets/no_internet.png';
      });
    }
  }

  Future<void> fetchResourceData() async {
    final url = Config.getStudentResourcesPassword();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("URL: $url");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          resourceData = jsonResponse['resources'];
          _isExpandedList = List.filled(resourceData.length, false);
          errorMessage = 'assets/no_data.png';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'assets/no_data.png';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'assets/no_data.png';
        isLoading = false;
      });
    }
  }

  Future<void> downloadPdf(String url, String customPath) async {
    double progress = 0.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Downloading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: progress > 0 ? progress : null,
              ),
              const SizedBox(height: 20),
              Text('${(progress * 100).toStringAsFixed(1)}%'),
            ],
          ),
        );
      },
    );

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        final file = File(customPath);
        final bytes = <int>[];

        for (int i = 0; i < response.bodyBytes.length; i++) {
          bytes.add(response.bodyBytes[i]);

          progress = bytes.length / totalBytes;
          setState(() {});
        }

        await file.writeAsBytes(bytes);

        Navigator.of(context).pop();

        print("PDF downloaded successfully and saved to path: $customPath");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Download completed'),
        )
        );
      } else {
        throw Exception("Failed to download PDF. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading PDFeeee: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download PDF')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _openPDF(String url, String resourceName) async {
    double progress = 0.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Loading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: progress > 0 ? progress : null,
              ),
              const SizedBox(height: 20),
              Text('${(progress * 100).toStringAsFixed(1)}%'),
            ],
          ),
        );
      },
    );

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        final bytes = <int>[];

        for (int i = 0; i < response.bodyBytes.length; i++) {
          bytes.add(response.bodyBytes[i]);
          if (totalBytes > 0) {
            progress = bytes.length / totalBytes;
            setState(() {});
          }
        }

        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(bytes);

        Navigator.of(context).pop();

        if (await file.exists()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFScreen(file.path, resourceName),
            ),
          );
        } else {
          throw Exception("PDF file was not created.");
        }
      } else {
        throw Exception("Failed to fetch PDF. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error opening PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load PDF')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Resources"),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Padding(
          padding: const EdgeInsets.all(100.0),
          child: const Center(child: CircularProgressIndicator()),
        )
            : resourceData.isEmpty
            ? Center(
          child: errorMessage.isNotEmpty
              ? (errorMessage.contains('no_data.png')
              ? Image.asset(errorMessage)
              : Image.asset(errorMessage))
              : Image.asset(errorMessage),
        )
            : Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: resourceData.length,
            itemBuilder: (context, index) {
              final resource = resourceData[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _isExpandedList[index] = !_isExpandedList[index];
                  });
                },
                child: Card(
                  color: Colors.grey.shade50,
                  elevation: 4.0,
                  margin: const EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.label_important_outline),
                            Text(
                              resource['tags'] ?? 'No Tags',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isExpandedList[index]
                              ? resource['desc']
                              : resource['desc'],
                          maxLines: _isExpandedList[index] ? null : 2,
                          overflow: _isExpandedList[index]
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: 350,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final fileUrl =
                                          "http://kcmit-api.kcmit.edu.np:5000/${resource['url']}";
                                      print("URL: $fileUrl");
                                      _openPDF(fileUrl, resource['title']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xff323465),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.picture_as_pdf_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'View',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final fileUrl =
                                          "http://kcmit-api.kcmit.edu.np:5000/${resource['url']}";
                                      final customPath =
                                          "/storage/emulated/0/Download/${resource['url']}";
                                      print('Download URL: $fileUrl');
                                      downloadPdf(fileUrl, customPath);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10),
                                      backgroundColor:
                                      const Color(0xff323465),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.file_download_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Download',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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