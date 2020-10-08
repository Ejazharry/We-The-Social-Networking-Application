

import 'file:///C:/Users/ejazh/AndroidStudioProjects/we-thesocialnetwork/lib/pages/user.dart';
import 'package:buddiesgram/pages/HangoutPage.dart';
import 'package:buddiesgram/pages/SearchPage.dart';
import 'UploadPage.dart';
import 'PostWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

class TimeLinePage extends StatefulWidget {
  final User gCurrentUser;
  TimeLinePage({this.gCurrentUser});
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timelineReference.doc(widget.gCurrentUser.id).collection("timelinePosts").orderBy("timestamp", descending: true)
        .get();
    List<Post> allPosts = querySnapshot.docs.map((document)=> Post.fromDocument(document)).toList();
    setState(() {
      this.posts = allPosts;
    });
  }
  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await followingReference.doc(currentUser.id).collection("userFollowing").get();
    setState(() {
      followingsList = querySnapshot.docs.map((document) => document.id).toList();
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveTimeLine();
    retrieveFollowings();
  }

  createUserTimeline(){
    if(posts == null ){
      return  Center(child:
      SizedBox( width: 30, height: 30, child: CircularProgressIndicator()));
    }
    else{
      return ListView(children: posts,);
    }
  }



  @override
  Widget build(context) {

    return Scaffold(

      key: _scaffoldKey,
      appBar: AppBar(

     iconTheme: IconThemeData(color: Colors.black),
        /*shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),*/
        toolbarHeight: 50.0,

        backgroundColor: Colors.white,
        title:  Center(
          child: Text(
            "We",
            style: TextStyle( color: Colors.black,fontSize: 38, fontFamily: 'Signatra', ),
          ),


        ),
        leading: new IconButton(
          icon: new Icon(Icons.add_a_photo),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => UploadPage(gCurrentUser: currentUser,),
                ));
          },
        ),



     actions: <Widget>[
      /*IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>SearchPage(),
                  ));
            },
          ),*/

    new SizedBox(
        height: 1.0,
        width: 43,
        child:  IconButton(
            icon: new Image.asset('assets/images/date.png'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>Meet(),
                  ));
            },
          ),
    )

        ],


      ),
      body: RefreshIndicator(child: createUserTimeline(), onRefresh: ()=> retrieveTimeLine()),
    );
  }
}
