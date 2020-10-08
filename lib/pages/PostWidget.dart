import 'dart:async';
import 'package:chewie/chewie.dart';

import 'user.dart';
import 'CommentsPage.dart';
import 'HomePage.dart';
import 'ProfilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FullImageWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';


class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  //final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;
  final Timestamp timestamp;

  Post({
    this.timestamp,
    this.postId,
    this.ownerId,
    //this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc.data()["postId"],
      ownerId: doc.data()["ownerId"],
      likes: doc.data()["likes"],
      username: doc.data()["username"],
      description: doc.data()["description"],
      location: doc.data()["location"],
      url:doc.data()["url"],
      timestamp:  doc.data()["timestamp"],

    );
  }

  int getTotalNumberOfLikes(likes){

    if(likes == null){
      return 0;
    }

    int counter = 0 ;
    likes.values.forEach((eachValue)
    {
      if(eachValue == true){
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    likes: this.likes,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
    likeCount: getTotalNumberOfLikes(this.likes), image: null,

  );
}

class _PostState extends State<Post>
{

  final String postId;
  final String ownerId;
  bool image = false;
  Map likes;
  String images;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart =false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState({
    @required this.image,
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);

    return Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: fullPost(),
    );
  }


  /*createPostHead(){
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData )
        {
          return  LinearProgressIndicator();
        }
        User user = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;
        return  ListTile(
          leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.white,foregroundColor: Colors.black,) , onTap: ()=> displayUserProfile(context, userProfileId: user.id),
          title: GestureDetector(
            onTap: ()=> displayUserProfile(context, userProfileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(location,style: TextStyle(color: Colors.black),),
          trailing: isPostOwner? IconButton(

            icon: Icon(Icons.more_vert,color: Colors.black,),
            onPressed: ()=> controlPostDelete(context),

          ) : Text(""),

        );
      },
    );
  }*/


  controlPostDelete(BuildContext mContext){
    return showDialog(
        context: mContext,

        builder: (context){
          return SimpleDialog(
            backgroundColor: Colors.white,
            title: Text("Delete?",style: TextStyle(color: Colors.black),),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Yes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                onPressed: ()
                {
                  Navigator.pop(context);
                  removeUserPost();
                },
              ),
              SimpleDialogOption(
                child: Text("No", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
    );
  }
  removeUserPost() async {
    postsReference.doc(ownerId).collection("usersPosts").doc(postId).get().then((document){
      if(document.exists){
        document.reference.delete();
      }
    });
    storageReference.child("post_$postId.jpg").delete();

    QuerySnapshot querySnapshot = await activityFeedReference.doc(ownerId).collection("feedItems").where("postId", isEqualTo: postId).get();
    querySnapshot.docs.forEach((document) {
      if(document.exists){
        document.reference.delete();
      }
    });

    QuerySnapshot commentsQuerySnapshot = await commentsReference.doc(postId).collection("comments").get();
    commentsQuerySnapshot.docs.forEach((document) {
      if(document.exists){
        document.reference.delete();
      }
    });
  }

  displayUserProfile(BuildContext context, {String userProfileId})
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userProfileId: userProfileId,)));
  }


  removeLike(){
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if(isNotPostOwner){
      activityFeedReference.doc(ownerId).collection("feedItems").doc(postId).get().then((document){
        if(document.exists){
          document.reference.delete();
        }
      });

    }
  }

  addLike(){
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if(isNotPostOwner){
      activityFeedReference.doc(ownerId).collection("feedItems").doc(postId).set({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImg": currentUser.url,
      });
    }
  }

  controlUserLikePost(){
    bool _liked = likes[currentOnlineUserId]== true;

    if(_liked)
    {
      postsReference.doc(ownerId).collection("usersPosts").doc(postId).update({"likes.$currentOnlineUserId": false});
      removeLike();
      setState(() {
        likeCount = likeCount -1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    }
    else if(!_liked) {
      postsReference.doc(ownerId).collection("usersPosts").doc(postId).update({"likes.$currentOnlineUserId": true});
      addLike();
      setState(() {
        likeCount = likeCount +1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), (){
        setState(() {
          showHeart = false;
        });
      });

    }
  }




  getFullImage(){
    return Scaffold(
      body: GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
            child:
              Image.network(url),
              //showHeart? Icon(Icons.insert_emoticon, size: 20.0, color: Colors.black,): Text(""),

          ),

        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
}





     fullPost() {
          return FutureBuilder(
           future: usersReference.doc(ownerId).get(),
            // ignore: missing_return
            builder: (context, dataSnapshot) {
              // ignore: missing_return
              if (!dataSnapshot.hasData) {
                   return  Center(child: SizedBox( width: 30, height: 30, child: Text(
                     ""
                   ) ));//CircularProgressIndicator()
                 }
              User user = User.fromDocument(dataSnapshot.data);
              bool isPostOwner = currentOnlineUserId == ownerId;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                  color: Colors.white,
                   borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(color: Colors.black12)
                   ),
                    child: Column(
                      children: <Widget>[
                       Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                           child: Column(
                             children: <Widget>[
                               ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(user.url),
                                    backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,),
                                 onTap: () =>
                                  displayUserProfile(context, userProfileId: user.id),

                                 title: GestureDetector(
                                  onTap: ()=> displayUserProfile(context, userProfileId: user.id),
                                   child: Text(
                                     user.username,
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                     ),
                                        ),
                                  subtitle: Text(location,style: TextStyle(color: Colors.black),),
                                   trailing: isPostOwner? IconButton(

                                   icon: Icon(Icons.more_vert,color: Colors.black,),
                                   onPressed: ()=> controlPostDelete(context),

                                   ) : Text(""),

                                   ),
                                  InkWell(
                                 child: createPostPicture()
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 1.0),
                                     child:
                                     createPostFooter()

                               ),


                             ],
                            ),
                          ),
                         ],
                       ),
                    ),
                 );
              }
              );
  }




  createPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 55.0, left: 15.0)),
            GestureDetector(
              onTap: ()=> controlUserLikePost(),
              child: Icon(
                isLiked? Icons.insert_emoticon : Icons.sentiment_dissatisfied,
                size: 34.0,
                color: Colors.black87,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 10.0)),
            GestureDetector(
              onTap: ()=> displayComments(context,postId: postId, ownerId: ownerId, url: url),
              child: IconButton(
                icon: new Image.asset('assets/images/chat1.png'), iconSize: 5, onPressed: () {  },),
            ),
            Padding(padding: EdgeInsets.only(right:10.0)),
            GestureDetector(

              onTap: ()=> {},
              child: Icon(
                Icons.arrow_downward, size: 34.0,color: Colors.black87,),
            ),

            Padding(padding: EdgeInsets.only(right:130.0)),
            GestureDetector(
              child:IconButton(
                onPressed: () {},
                icon: Icon(Icons.send),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text("$username #", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),

            ),
            Expanded(
              child: Text(description, style: TextStyle(color: Colors.black),),
            )
          ],
        ),

      ],
    );
  }

  createPostPicture(){
    //createPostFooter();


    return GestureDetector(

        onDoubleTap: ()=>
            Navigator.push(context, MaterialPageRoute(
                builder:(context) => FullPhoto(url: url)
            )),
          onLongPress: ()=>
            Navigator.push(context, MaterialPageRoute(
                builder:(context) => FullPhoto(url: url)
            )),


            child: Stack(
             alignment: Alignment.center,
             children: <Widget>[
               full(),
                 Image.network(url),
               //showHeart? Icon(Icons.insert_emoticon, size: 20.0, color: Colors.black,): Text(""),
          ],
        ),
      );
    }

    videos(){
      Container(

              child: Chewie(
                controller: ChewieController(
                  videoPlayerController: VideoPlayerController.network(url),
                  aspectRatio: 3/4,
                  autoPlay: true,
                  looping: true,
                ),

      ),);

    }


    circularProgress()
    {
      return  SizedBox( width: 30, height: 30, child: CircularProgressIndicator());
    }





    full(){
        return Container(
          alignment: Alignment.bottomCenter,
          width: 500,
          height: 335,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Simpleloading.gif"),
                fit: BoxFit.cover,
              )
          ),
        );
    }
    displayComments(BuildContext context, {String postId, String ownerId, String url}){
    Navigator.push(context, MaterialPageRoute(builder: (context)
    {
      return CommentsPage(postId: postId,postOwnerId: ownerId, postImageUrl: url);
    }
    ));
  }
}


