
import 'package:easyshare/views/image_receiver.dart';
import 'package:easyshare/views/image_sender.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome to easyshare",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {

                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ImageSender()));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.send,
                      size: 48,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {

                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImageReceiver()));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.get_app,
                      size: 48,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Receive',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
