import 'package:easyshare/controllers/selection_controller.dart';
import 'package:easyshare/services/file_sender_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class SendFile extends StatefulWidget {
  const SendFile({super.key});

  @override
  State<SendFile> createState() => _SendFileState();
}

class _SendFileState extends State<SendFile> {
  final SelectionController selectionController =
  Get.put(SelectionController());

  bool isSending = false;
  String status = "";

  Future<void> sendSelectedFiles() async {
    try {
      setState(() {
        isSending = true;
        status = "Searching receiver…";
      });

      await FileSenderService.sendAssets(
        selectionController.selectedImages.toSet(),
      );

      selectionController.clear();

      setState(() {
        status = "Files sent successfully";
      });
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sending Files",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child:
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selected count
                Obx(() => Text(
                  "Selected: ${selectionController.selectedImages.length}",
                  style: const TextStyle(fontSize: 16),
                )),

                const SizedBox(height: 12),

                Obx(() {
                  final images =
                  selectionController.selectedImages.toList();

                  if (images.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return SizedBox(
                    height: 500,
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: images.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final asset = images[index];

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AssetEntityImage(
                                asset,
                                fit: BoxFit.cover,
                                isOriginal: false,
                              ),

                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    selectionController.toggle(asset);
                                  },
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed:
                  selectionController.selectedImages.isEmpty ||
                      isSending
                      ? null
                      : sendSelectedFiles,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(140, 48),
                  ),
                  child: isSending
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text("Send"),
                ),

                const SizedBox(height: 12),

                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                    status.startsWith("Error") ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
