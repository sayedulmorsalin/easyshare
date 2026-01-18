import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectionController extends GetxController {
  final RxSet<AssetEntity> selectedImages = <AssetEntity>{}.obs;

  void toggle(AssetEntity asset) {
    selectedImages.contains(asset)
        ? selectedImages.remove(asset)
        : selectedImages.add(asset);
  }

  void clear() {
    selectedImages.clear();
  }

}
