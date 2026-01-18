import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:photo_manager/photo_manager.dart';

class FileSenderService {
  static const int port = 4040;

  static Future<String?> _getLocalSubnet() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip == null) return null;
    return ip.substring(0, ip.lastIndexOf('.'));
  }

  static Future<String?> findReceiverIPFast() async {
    final subnet = await _getLocalSubnet();
    if (subnet == null) return null;

    const batchSize = 25;
    const timeout = Duration(milliseconds: 300);

    for (int start = 1; start <= 254; start += batchSize) {
      final futures = <Future<String?>>[];

      for (int i = start; i < start + batchSize && i <= 254; i++) {
        final ip = "$subnet.$i";
        futures.add(() async {
          try {
            final socket =
            await Socket.connect(ip, port, timeout: timeout);
            socket.destroy();
            return ip;
          } catch (_) {
            return null;
          }
        }());
      }

      final results = await Future.wait(futures);
      for (final ip in results) {
        if (ip != null) return ip;
      }
    }
    return null;
  }

  static Future<void> sendAssets(
      Set<AssetEntity> assets,
      ) async {
    if (assets.isEmpty) return;

    final receiverIP = await findReceiverIPFast();
    if (receiverIP == null) {
      throw Exception("Receiver not found");
    }

    final socket = await Socket.connect(receiverIP, port);

    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) continue;

      final bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final nameBytes = utf8.encode(fileName);

      final nameLenBuffer = ByteData(2)
        ..setUint16(0, nameBytes.length, Endian.big);
      socket.add(nameLenBuffer.buffer.asUint8List());

      socket.add(nameBytes);

      final sizeBuffer = ByteData(8)
        ..setInt64(0, bytes.length, Endian.big);
      socket.add(sizeBuffer.buffer.asUint8List());

      socket.add(bytes);
      await socket.flush();
    }

    socket.close();
  }
}
