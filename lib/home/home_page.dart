import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/image_downloader.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:lazy_loading_list/lazy_loading_list.dart';
import 'package:shimmer/shimmer.dart';

// ignore: camel_case_types
class Home_Wallpaper extends StatefulWidget {
  const Home_Wallpaper({Key? key}) : super(key: key);

  @override
  _Home_WallpaperState createState() => _Home_WallpaperState();
}

// ignore: camel_case_types
class _Home_WallpaperState extends State<Home_Wallpaper> {
  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File? _imageFile;

  ScrollController _scrollController = ScrollController();
  List images = [];
  int page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEffect();
    fetchapi();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadmore();
      }
    });
  }

  getEffect() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 3), () {});
    setState(() {
      isLoading = false;
    });
  }

  fetchapi() async {
    await http.get(Uri.parse("https://api.pexels.com/v1/curated?per_page=80"),
        headers: {
          'Authorization':
              '563492ad6f91700001000001e072df694c994979acd56783ee913ea5'
        }).then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        images = result['photos'];
      });
    });
  }

  loadmore() async {
    setState(() {
      page = page + 1;
    });
    String url =
        'https://api.pexels.com/v1/curated?per_page=80&page=' + page.toString();
    await http.get(Uri.parse(url), headers: {
      'Authorization':
          '563492ad6f91700001000001e072df694c994979acd56783ee913ea5'
    }).then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        images.addAll(result['photos']);
      });
    });
  }

  bool isLoading = false;

  Widget buildEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.grey,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.grey,
                size: 20,
              ),
              actions: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("asset/unnamed.jpg"),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5, left: 15, right: 15),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                        child: Text(
                      "Follow",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 15, left: 50, right: 50),
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 45,
                    width: 80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: Text(
                        "Activity",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    "Community",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Shop",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40), topLeft: Radius.circular(40)),
              child: ListView(
                children: [
                  Container(
                      color: Colors.white,
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                        'All Products',
                        style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w500),
                      ),
                          ))),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Container(
                        child: StaggeredGridView.countBuilder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          crossAxisCount: 4,
                          itemCount: images.length + 1,
                          itemBuilder: (context, index) {
                            if (index == images.length) {
                              return CupertinoActivityIndicator(
                                radius: 15,
                                animating: true,
                              );
                            }
                            if (isLoading) {
                              return buildEffect();
                            } else {
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: InkWell(
                                        onTap: () {
                                          _downloadImage(
                                            images[index]['src']['original']
                                                .toString(),
                                            outputMimeType: "image/png",
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            images[index]['src']['tiny']
                                                .toString(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                      images[index]['photographer'].toString()),
                                ],
                              );
                            }
                          },
                          staggeredTileBuilder: (index) =>
                              StaggeredTile.count(2, index.isEven ? 3 : 2),
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 60, right: 60, bottom: 40),
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white60,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                              'https://pngimg.com/uploads/pinterest/pinterest_PNG62.png'),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.search,
                              size: 30,
                              color: Colors.black54,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.notifications,
                                size: 30, color: Colors.black54)),
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                              'https://th.bing.com/th/id/OIP.uZQdLXEgBEvR2OkcVVbBMQHaFj?w=226&h=180&c=7&o=5&dpr=1.25&pid=1.7'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadImage(
    String url, {
    AndroidDestinationType? destination,
    bool whenError = false,
    String? outputMimeType,
  }) async {
    Fluttertoast.showToast(
        msg: "Downloaded Sucessfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.green,
        fontSize: 25.0);
    String? fileName;
    String? path;
    int? size;
    String? mimeType;
    try {
      String? imageId;

      if (whenError) {
        imageId = await ImageDownloader.downloadImage(url,
                outputMimeType: outputMimeType)
            .catchError((error) {
          if (error is PlatformException) {
            String? path = "";
            if (error.code == "404") {
            } else if (error.code == "unsupported_file") {
              path = error.details["unsupported_file_path"];
            }
            setState(() {
              _message = error.toString();
              _path = path ?? '';
            });
          }

          print(error);
        }).timeout(Duration(seconds: 10), onTimeout: () {
          return;
        });
      } else {
        if (destination == null) {
          imageId = await ImageDownloader.downloadImage(
            url,
            outputMimeType: outputMimeType,
          );
        } else {
          imageId = await ImageDownloader.downloadImage(
            url,
            destination: destination,
            outputMimeType: outputMimeType,
          );
        }
      }

      if (imageId == null) {
        return;
      }
      fileName = await ImageDownloader.findName(imageId);
      path = await ImageDownloader.findPath(imageId);
      size = await ImageDownloader.findByteSize(imageId);
      mimeType = await ImageDownloader.findMimeType(imageId);
    } on PlatformException catch (error) {
      setState(() {
        _message = error.message ?? '';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      var location = Platform.isAndroid ? "Directory" : "Photo Library";
      _message = 'Saved as "$fileName" in $location.\n';
      _size = 'size:     $size';
      _mimeType = 'mimeType: $mimeType';
      _path = path ?? '';

      if (!_mimeType.contains("video")) {
        _imageFile = File(path!);
      }
      return;
    });
  }
}
