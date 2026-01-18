import 'package:easyshare/controllers/selection_controller.dart';
import 'package:easyshare/views/send_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class SelectFile extends StatefulWidget {
  const SelectFile({super.key});

  @override
  State<SelectFile> createState() => _SelectFileState();
}

class _SelectFileState extends State<SelectFile> {
  final SelectionController selectionController = Get.put(
    SelectionController(),
  );

  List<AssetEntity> images = [];

  bool isLoading = true;
  bool isFetchingMore = false;
  bool hasMore = true;

  int currentPage = 0;
  final int pageSize = 200;

  late AssetPathEntity imageAlbum;

  Future<void> initGallery() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!ps.isAuth) {
      setState(() => isLoading = false);
      return;
    }

    final filterOption = FilterOptionGroup(
      orders: const [OrderOption(type: OrderOptionType.createDate, asc: false)],
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

    final List<AssetEntity> newImages = await imageAlbum.getAssetListPaged(
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
            "Select files",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (scroll.metrics.pixels >=
                      scroll.metrics.maxScrollExtent - 300) {
                    loadMoreImages();
                  }
                  return false;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(2),
                  itemCount: hasMore ? images.length + 1 : images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    if (index == images.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final asset = images[index];

                    return Obx(() {
                      final isSelected = selectionController.selectedImages
                          .contains(asset);
                      final selectedIndex = selectionController.selectedImages
                          .toList()
                          .indexOf(asset);

                      return GestureDetector(
                        onTap: () {
                          selectionController.toggle(asset);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AssetEntityImage(
                              asset,
                              fit: BoxFit.cover,
                              isOriginal: false,
                            ),

                            if (isSelected)
                              Container(color: Colors.blue.withOpacity(0.4)),

                            if (isSelected)
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
                    });
                  },
                ),
              ),

            const Center(child: Text("Video")),
            const Center(child: Text("Apps")),
            const Center(child: Text("Files")),
          ],
        ),

        bottomNavigationBar: Obx(() {
          return selectionController.selectedImages.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(blurRadius: 6, color: Colors.black12),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${selectionController.selectedImages.length} selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          selectionController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          minimumSize: const Size(70, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Unselect all",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SendFile(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(120, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Send",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }
}
