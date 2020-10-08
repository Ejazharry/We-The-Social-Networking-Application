import 'HomePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'ProfilePage.dart';
class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        title:  Center(
          child: Text(
            "Notifications",
            style: TextStyle( color: Colors.black,fontSize: 20 ),
          ),


        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomePage(),
                ));
          },
        ),

        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ProfilePage(userProfileId: currentUser.id,),
                  ));
            },
          )

        ],


      ),
    body: Container(
        child: FutureBuilder(
          future: retrieveNotifications(),
          builder: (context, dataSnapshot){
            if(!dataSnapshot.hasData){
              return Center(child:
              SizedBox( width: 30, height: 30, child: CircularProgressIndicator()));
            }
            return ListView(
              children: dataSnapshot.data,
            );
          },
        ),
      ),
    );
  }

  retrieveNotifications() async {
    QuerySnapshot querySnapshot = await activityFeedReference.doc(currentUser.id).collection("feedItems").orderBy("timestamp", descending: true)
        .limit(60).get();

    List<NotificationsItem> notificationsItems = [];

    querySnapshot.docs.forEach((document) {
      notificationsItems.add(NotificationsItem.fromDocument(document));
    });

    return notificationsItems;
  }
}

String notificationItemText;
Widget mediaPreview;

class NotificationsItem extends StatelessWidget {

  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  NotificationsItem({this.username, this.type, this.commentData, this.postId, this.userId, this.userProfileImg, this.url, this.timestamp});

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationsItem(
      username:  documentSnapshot.data()["username"],
      type:  documentSnapshot.data()["type"],
      commentData:  documentSnapshot.data()["commentData"],
      postId:  documentSnapshot.data()["postId"],
      userId:  documentSnapshot.data()["userId"],
      userProfileImg:  documentSnapshot.data()["userProfileImg"],
      url:  documentSnapshot.data()["url"],
      timestamp:  documentSnapshot.data()["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {

    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(top: 3.0),

      child: Container(

        decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: ListTile(

          title: GestureDetector(
            onTap: ()=> displayUserProfile(context, userProfileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 13.0, color: Colors.black87, ),
                children: [
                  TextSpan(text: username, style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: " $notificationItemText"),
                ],
              ),


            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
            minRadius: 18,
            maxRadius: 22,

          ),
          subtitle: Text(tAgo.format(timestamp.toDate()), overflow: TextOverflow.ellipsis,),
          trailing: mediaPreview,
        ),
      ),
    );
  }
  configureMediaPreview(context){
    if(type == "comment" || type == "like")
    {
      mediaPreview = GestureDetector(
        //onTap: ()=> displayFullPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                image: DecorationImage(
                    fit: BoxFit.cover, image: CachedNetworkImageProvider(url)),
              ),
            ),
          ),

        ),
      );
    }
    else {
      mediaPreview = Text("");
    }
    if(type == "like"){
      notificationItemText = "Liked Your Post.";

    }
    else if(type == "comment"){
      notificationItemText = "Commented: $commentData";

    }
    else if(type == "follow"){
      notificationItemText = "started following you.";

    }
    else{
      notificationItemText = "Error, unknown type = $type";
    }

  }

  /*displayFullPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> PostScreenPage(postId: postId, userId: userId,)));
  }*/

  displayUserProfile(BuildContext context, {String userProfileId})
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userProfileId: userProfileId,)));
  }


}
