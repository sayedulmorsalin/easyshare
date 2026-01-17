import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class SendFile extends StatefulWidget {
  const SendFile({super.key});

  @override
  State<SendFile> createState() => _SendFileState();
}

class _SendFileState extends State<SendFile> {
  List<AssetEntity> images = [];
  bool isLoading = true;

  Future<void> initGallery() async {
    final PermissionState ps =
    await PhotoManager.requestPermissionExtend();

    if (!ps.isAuth) {
      setState(() => isLoading = false);
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    final imageList = await albums.first.getAssetListPaged(
      page: 0,
      size: 200,
    );

    setState(() {
      images = imageList;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initGallery();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Send files",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.lightBlueAccent,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Image", icon: Icon(Icons.image)),
              Tab(text: "Video", icon: Icon(Icons.smart_display_outlined)),
              Tab(text: "APPs", icon: Icon(Icons.android)),
              Tab(text: "Files", icon: Icon(Icons.file_copy_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // IMAGE TAB (Gallery)
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(2),
              itemCount: images.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return AssetEntityImage(
                  images[index],
                  fit: BoxFit.cover,
                  isOriginal: false,
                );
              },
            ),

            // VIDEO TAB
            const Center(child: Text("Video")),

            // APPS TAB
            const Center(child: Text("Apps")),

            // FILES TAB
            const Center(child: Text("Files")),
          ],
        ),
      ),
    );
  }
}
