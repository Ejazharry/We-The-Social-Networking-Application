
import 'file:///C:/Users/ejazh/AndroidStudioProjects/we-thesocialnetwork/lib/pages/user.dart';
import 'EditProfilePage.dart';
import 'PostTileWidget.dart';
import 'PostWidget.dart';
import 'HomePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0 ;
  List<Post> postsList = [];
  String postOrientation= "grid";
  int countTotalFollowers = 0;
  int countTotalFollowing = 0;
  bool following = false;

  // ignore: must_call_super
  void initState(){
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }


  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference.doc(widget.userProfileId).collection("userFollowers").get();

    setState(() {
      countTotalFollowers = querySnapshot.docs.length;
    });
  }
  getAllFollowings() async {
    QuerySnapshot querySnapshot = await followingReference.doc(widget.userProfileId).collection("userFollowing").get();

    setState(() {
      countTotalFollowing = querySnapshot.docs.length;
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .doc(widget.userProfileId).collection("userFollowers").doc(currentOnlineUserId).get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }
  createProfileTopView(){
    return FutureBuilder(
      future: usersReference.doc(widget.userProfileId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData)
        {
          return
            Center(child:
            SizedBox( width: 15, height: 15, child: CircularProgressIndicator()));
        }
        User user = User.fromDocument(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.all(17.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 38.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column (
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createColumns("Uploads", countPost),
                            createColumns("following", countTotalFollowing),
                            createColumns("followers", countTotalFollowers),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createButton(),
                          ],
                        ),
                        /* Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          createLogOutButton(),
                        ],
                      ),*/
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13.0),
                child: Text(
                  user.username, style: TextStyle(fontSize: 12.0,color: Colors.black),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5.0),
                child: Text(
                  user.profileName, style: TextStyle(fontSize: 15.0,color: Colors.black),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 3.0),
                child: Text(
                  user.bio, style: TextStyle(fontSize: 14.0,color: Colors.black),
                ),
              ),
            ],
          ),
        );

      },
    );

  }

  // ignore: non_constant_identifier_names
  createColumns(String title, int Count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          Count.toString(),
          style: TextStyle(fontSize: 17.0, color: Colors.black,fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 13.0,color: Colors.black,fontWeight: FontWeight.w300),
          ),
        ),
      ],
    );

  }
  createButton(){
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if(ownProfile){
      return createButtonTitleAndFunction(title:"Edit", performFunction: editUserProfile,);
    }
    else if(following){
      return createButtonTitleAndFunction(title: "Unfollow", performFunction: controlUnfollowUser,);
    }
    else if(!following){
      return createButtonTitleAndFunction(title: "follow", performFunction: controlFollowUser,);
    }

  }

  createLogOutButton(){
    return createButtonTitleAndFunction(title:"LogOut", performFunction: LogOut,);
  }
  // ignore: non_constant_identifier_names
  LogOut() async {
    await gSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
  }
  controlUnfollowUser(){
    setState(() {
      following= false;
    });

    followersReference.doc(widget.userProfileId)
        .collection("userFollowers").doc(currentOnlineUserId)
        .get().then((document){
      if(document.exists){
        document.reference.delete();
      }
    });

    followingReference.doc(currentOnlineUserId)
        .collection("userFollowing").doc(widget.userProfileId)
        .get().then((document){
      if(document.exists){
        document.reference.delete();
      }
    });


    activityFeedReference.doc(widget.userProfileId).collection("feedItems")
        .doc(currentOnlineUserId)
        . get()
        .then((document){
      if(document.exists){
        document.reference.delete();
      }
    });
  }

  controlFollowUser(){
    setState(() {
      following = true;
    });
    followersReference.doc(widget.userProfileId).collection("userFollowers").doc(currentOnlineUserId).set({});
    followingReference.doc(currentOnlineUserId).collection("userFollowing").doc(widget.userProfileId).set({});
    activityFeedReference.doc(widget.userProfileId).collection("feedItems").doc(currentOnlineUserId).set({
      "type": "follow",
      "ownerId": currentOnlineUserId,
      "userName": currentUser.username,
      "timeStamp": DateTime.now(),
      "userProfileImg": currentUser.url,
      "userId": currentOnlineUserId,
    });

  }


  createButtonTitleAndFunction({String title, Function performFunction}){
    return Container (
      padding: EdgeInsets.only(top:3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 100.0,
          height: 26.0,
          child: Text(title, style: TextStyle(color: following? Colors.grey : Colors.white,fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:following?Colors.white : Colors.black,
            border: Border.all(color: following? Colors.black : Colors.black),
            borderRadius: BorderRadius.circular(6.0),

          ),
        ),
      ),
    );
  }
  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: new Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[

            ListTile(
              title: Center(
                child: Text(
                  "LogOut",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        title:  Center(
          child: Text(
            "Profile",
            style: TextStyle( color: Colors.black, ),
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, size: 20.0,),
          onPressed: () {
            Navigator.pop(
                context);
          },
        ),

        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
          )

        ],


      ),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(height: 0.0,),
          displayProfilePost(),

        ],
      ),
    );
  }

  displayProfilePost(){
    if(loading)
    {

    }

    else if(postsList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(Icons.photo_library,color: Colors.grey,size: 200.0,),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text("No Posts", style: TextStyle(color: Colors.black, fontSize: 40.0,fontWeight: FontWeight.bold),),
            )
          ],
        ),
      );
    }


    else if(postOrientation == "list"){
      return Column(
        children: postsList,
      );
    }
    else if (postOrientation == "grid"){
      List<GridTile> gridTilesLists = [];
      postsList.forEach((eachPost) {
        gridTilesLists.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesLists,
      );
    }

  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference.doc(widget.userProfileId).collection("usersPosts").orderBy("timestamp", descending: true).get();
    setState(() {
      loading= false;
      countPost = querySnapshot.docs.length;
      postsList = querySnapshot.docs.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }


  createListAndGridPostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[


        IconButton(
          onPressed: ()=> setOrientation("grid"),
          icon: Icon(Icons.dashboard),
          color: postOrientation == "grid"? Colors.black : Colors.grey,
        ),
        IconButton(
          onPressed: ()=> setOrientation("list"),
          icon: Icon(Icons.view_list),
          color: postOrientation == "list"? Colors.black : Colors.grey,
        ),
      ],
    );
  }
  setOrientation(String orientation){
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
