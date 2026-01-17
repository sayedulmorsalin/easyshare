import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class SelectFile extends StatefulWidget {
  const SelectFile({super.key});

  @override
  State<SelectFile> createState() => _SelectFileState();
}

class _SelectFileState extends State<SelectFile> {
  List<AssetEntity> images = [];
  Set<AssetEntity> selectedImages = {};

  bool isLoading = true;
  bool isFetchingMore = false;
  bool hasMore = true;

  int currentPage = 0;
  final int pageSize = 200;

  late AssetPathEntity imageAlbum;

  Future<void> initGallery() async {
    final PermissionState ps =
    await PhotoManager.requestPermissionExtend();

    if (!ps.isAuth) {
      setState(() => isLoading = false);
      return;
    }

    final filterOption = FilterOptionGroup(
      orders: const [
        OrderOption(
          type: OrderOptionType.createDate,
          asc: false, // NEW → OLD
        ),
      ],
    );

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOption,
    );

    imageAlbum = albums.first;

    await loadMoreImages();
    setState(() => isLoading = false);
  }

  Future<void> loadMoreImages() async {
    if (isFetchingMore || !hasMore) return;

    isFetchingMore = true;

    final List<AssetEntity> newImages =
    await imageAlbum.getAssetListPaged(
      page: currentPage,
      size: pageSize,
    );

    if (newImages.isEmpty) {
      hasMore = false;
    } else {
      images.addAll(newImages);
      currentPage++;
    }

    isFetchingMore = false;
    setState(() {});
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
            // IMAGE TAB
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (scroll.metrics.pixels >=
                    scroll.metrics.maxScrollExtent - 300) {
                  loadMoreImages();
                }
                return false;
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                itemCount:
                hasMore ? images.length + 1 : images.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  if (index == images.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final asset = images[index];
                  final selectedIndex =
                  selectedImages.toList().indexOf(asset);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImages.contains(asset)
                            ? selectedImages.remove(asset)
                            : selectedImages.add(asset);
                      });
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AssetEntityImage(
                          asset,
                          fit: BoxFit.cover,
                          isOriginal: false,
                        ),

                        if (selectedImages.contains(asset))
                          Container(
                            color:
                            Colors.blue.withOpacity(0.4),
                          ),

                        if (selectedImages.contains(asset))
                          Positioned(
                            top: 6,
                            right: 6,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Text(
                                '${selectedIndex + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Center(child: Text("Video")),
            const Center(child: Text("Apps")),
            const Center(child: Text("Files")),
          ],
        ),

        bottomNavigationBar: selectedImages.isEmpty
            ? null
            : Container(
          height: 60,
          padding:
          const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black12,
              )
            ],
          ),
          child: Row(
            children: [
              Text(
                '${selectedImages.length} selected',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  debugPrint(
                      'Selected images: ${selectedImages.length}');
                },
                child: const Text("Send"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
