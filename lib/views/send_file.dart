import 'package:flutter/material.dart';
class SendFile extends StatefulWidget {
  const SendFile({super.key});

  @override
  State<SendFile> createState() => _SendFileState();
}

class _SendFileState extends State<SendFile> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child:
        Scaffold(
          appBar: AppBar(
            title: Text("Send files",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
            backgroundColor: Colors.lightBlueAccent,
            bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: "Image", icon: Icon(Icons.image,),),
                  Tab(text: "Video", icon: Icon(Icons.smart_display_outlined,),),
                  Tab(text: "APPs", icon: Icon(Icons.android,),),
                  Tab(text: "Files", icon: Icon(Icons.file_copy_outlined, ),),
            ]),
          ),
          body: TabBarView(children: [
            Center(child: Text("Image"),),
            Center(child: Text("video"),),
            Center(child: Text("app"),),
            Center(child: Text("file"),),
          ]),
        ),
    );
  }
}
