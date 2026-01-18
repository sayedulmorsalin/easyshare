import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ReceiveFile extends StatefulWidget {
  const ReceiveFile({super.key});

  @override
  State<ReceiveFile> createState() => _ReceiveFileState();
}

class _ReceiveFileState extends State<ReceiveFile> {
  String status = "Choose a folder to save files";
  Directory? saveDir;
  int count = 0;
  ServerSocket? server;

  Future<void> chooseFolder() async {
    final path = await getDirectoryPath();
    if (path == null) return;

    saveDir = Directory(path);

    setState(() {
      status = "Folder selected:\n$path\nWaiting for sender…";
    });

    startServer();
  }

  Future<void> startServer() async {
    if (saveDir == null) return;

    server = await ServerSocket.bind(InternetAddress.anyIPv4, 4040);

    server!.listen((socket) {
      setState(() => status = "Sender connected");

      List<int> buffer = [];

      socket.listen(
            (data) async {
          buffer.addAll(data);

          while (true) {
            if (buffer.length < 2) return;

            final nameLen = ByteData.sublistView(
              Uint8List.fromList(buffer.sublist(0, 2)),
            ).getUint16(0, Endian.big);

            if (buffer.length < 2 + nameLen + 8) return;

            final nameStart = 2;
            final nameEnd = nameStart + nameLen;
            final fileName = utf8.decode(buffer.sublist(nameStart, nameEnd));

            final sizeStart = nameEnd;
            final sizeEnd = sizeStart + 8;
            final fileSize = ByteData.sublistView(
              Uint8List.fromList(buffer.sublist(sizeStart, sizeEnd)),
            ).getInt64(0, Endian.big);

            if (buffer.length < sizeEnd + fileSize) return;

            final fileBytes = buffer.sublist(sizeEnd, sizeEnd + fileSize);

            buffer = buffer.sublist(sizeEnd + fileSize);

            final file = File('${saveDir!.path}/$fileName');
            await file.writeAsBytes(fileBytes, flush: true);

            count++;
            setState(() {
              status = "Received $count file(s)";
            });
          }
        },
        onDone: () {
          setState(() => status = "Sender disconnected");
        },
        onError: (e) {
          setState(() => status = "Error: $e");
        },
      );
    });

    setState(() => status = "Listening on port 4040");
  }

  @override
  void dispose() {
    server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Receive Files",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: chooseFolder,
                child: const Text("Choose Save Folder"),
              ),
              const SizedBox(height: 20),
              Text(status, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
