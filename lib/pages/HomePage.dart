
import 'file:///C:/Users/ejazh/AndroidStudioProjects/we-thesocialnetwork/lib/pages/user.dart';
import 'package:buddiesgram/pages/ActPage.dart';
import 'package:buddiesgram/pages/HangoutProfileSetUpPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CreateAccountPage.dart';
import 'NotificationsPage.dart';
import 'ChatPage.dart';
import 'TimeLinePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = FirebaseFirestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("post Pictures");
final StorageReference storageReferenceForChat = FirebaseStorage.instance.ref().child("post Pictures").child("Chat Images");
final postsReference = FirebaseFirestore.instance.collection("posts");
final messageReference = FirebaseFirestore.instance.collection("messages");
final activityFeedReference = FirebaseFirestore.instance.collection("feed");
final commentsReference = FirebaseFirestore.instance.collection("comments");
final followersReference = FirebaseFirestore.instance.collection("followers");
final followingReference = FirebaseFirestore.instance.collection("following");
final timelineReference = FirebaseFirestore.instance.collection("timeline");
final DateTime timestamp = DateTime.now();
User currentUser;



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  SharedPreferences preferences;
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  void initState(){
    super.initState();
    pageController = PageController();
    controlSignIn(GoogleSignInAccount signInAccount) async {
      if(signInAccount != null){
        await saveUserInfoToFireStore();
        setState(() {
          isSignedIn = true;
        });
        configureRealTimePushNotification();
      }
      else{

        setState(() {
          isSignedIn = false;
        });
      }
    }


    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }, onError: (gError){
      print ("Error Messsage:"+ gError);
    });
    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount){
      controlSignIn(gSignInAccount);

    }).catchError((gError){
      print ("Error Messsage:"+ gError);
    });
  }
  configureRealTimePushNotification(){
    final GoogleSignInAccount gUser = gSignIn.currentUser;


    _firebaseMessaging.getToken().then((token){
      usersReference.doc(gUser.id).update({"androidNotificationToken": token});
    });
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> msg) async{
          final String recipientId = msg["data"]["recipient"];
          final String body = msg["notification"]["body"];

          if(recipientId == gUser.id){
            SnackBar snackBar = SnackBar(
              backgroundColor: Colors.grey,
              content: Text(body, style: TextStyle(color: Colors.black), overflow: TextOverflow.ellipsis,),
            );

            _scaffoldKey.currentState.showSnackBar(snackBar);
          }

        }
    );
  }

  saveUserInfoToFireStore() async{
    preferences = await SharedPreferences.getInstance();
    GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await usersReference.doc(gCurrentUser.id).get();
    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateAccountPage()));
      usersReference.doc(gCurrentUser.id).set({
        "id" : gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "username" : username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": timestamp,
      });
      await preferences.setString("id",gCurrentUser.id );
      // ignore: deprecated_member_use
      await followersReference.document(gCurrentUser.id).collection("userFollowers").document(gCurrentUser.id).setData({});
      documentSnapshot = await usersReference.doc(gCurrentUser.id).get();

    }
    else{
      await preferences.setString("id", documentSnapshot.data()["id"]);
    }
    currentUser = User.fromDocument(documentSnapshot);
  }
  void dispose(){
    pageController.dispose();
    super.dispose();
  }
  loginUser(){
    gSignIn.signIn();
  }

  logoutUser(){
    gSignIn.signOut();
  }


  whenPageChanges(int pageIndex){
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
  }


  Scaffold buildHomeScreen(){
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          TimeLinePage(gCurrentUser: currentUser),
          ChatPage(),
          ActPage(),
          NotificationsPage(),
          ProfilePage(userProfileId: currentUser.id),
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
      ),
      bottomNavigationBar : CupertinoTabBar(

        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        items: [

          BottomNavigationBarItem(icon: Icon(Icons.home, size: 26,)),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline, size: 25,)),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video, size: 25)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none, size: 26)),
          //BottomNavigationBarItem(icon: Icon(Icons.supervisor_account)),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 26)),
        ],

        backgroundColor: Colors.white,//.withOpacity(0.1),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,


    );




    //return RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label:Text( "SignOut"));
  }


  Scaffold buildSignInScreen(){
    if(isSignedIn == false) {
      return Scaffold(
        body: Container(

          child: Column(
            children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(),
                ),
                Expanded( child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: GestureDetector(
                    child: Container(
                      alignment: AlignmentDirectional.bottomCenter,
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                            fit: BoxFit.cover,
                          )
                      ),

                    ),
                  ),
                ),
                ),
              Expanded( child: Align(
                alignment: FractionalOffset.center,
                child: GestureDetector(
                  onTap: loginUser,
                  child: Container(
                  alignment: AlignmentDirectional.bottomCenter,
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/signin-button.png"),
                        fit: BoxFit.cover,
                      )
                  ),

                ),
                ),
              ),),
           ],
          ),
        ),

      );
    }
  }
  @override
  Widget build(BuildContext context) {
    if(isSignedIn)
    {
      return buildHomeScreen();
    }
    else{
      return buildSignInScreen();
    }
  }
}