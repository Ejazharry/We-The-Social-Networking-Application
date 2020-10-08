import 'HomePage.dart';
import 'PostWidget.dart';

import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {

  final String  userId;
  final String postId;

  PostScreenPage({
    this.userId,
    this.postId,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference.doc(userId).collection("usersPosts").doc(postId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return Center(child:
          SizedBox( width: 30, height: 30, child: CircularProgressIndicator()));
        }
        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                  color: Colors.white
              ),
              title: Text(
                "Post",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),

              ),
              centerTitle: true,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back_ios, color: Colors.black,),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
