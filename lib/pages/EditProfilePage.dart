import 'file:///C:/Users/ejazh/AndroidStudioProjects/we-thesocialnetwork/lib/pages/user.dart';
import 'HomePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;
  EditProfilePage({
    this.currentOnlineUserId
  });
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController profileNameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading =false;
  User user;
  bool _profileNameValid = true;
  bool _bioValid = true;

  void initState(){
    super.initState();

    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await usersReference.doc(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);
    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;

    });
  }

  updateUserData(){
    setState(() {
      profileNameTextEditingController.text.trim().length<3 || profileNameTextEditingController.text.isEmpty ? _profileNameValid = false : _profileNameValid = true;
      bioTextEditingController.text.trim().length > 110 ? _bioValid = false : _bioValid=true;
    });

    if(_bioValid && _profileNameValid){
      usersReference.doc(widget.currentOnlineUserId).update({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text,

      });
      SnackBar successSnackBar = SnackBar(content: Text("Profile Update Success"));
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Edit Profile", style:TextStyle(color: Colors.black, fontSize: 18.0)),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.black,size: 20,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.done, color: Colors.black,size: 22.0,), onPressed:()=> Navigator.pop(context),),
        ],
      ),
      body: loading ? Center(child:
      SizedBox( width: 15, height: 15, child: CircularProgressIndicator())) : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                  child: CircleAvatar(
                    radius: 52.0,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),

                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      createProfileNameTextFormField(),
                      createBioTextFormField()
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                  child: FlatButton(
                    onPressed: updateUserData,
                    child: Container(
                      width: 60.0,
                      height: 30.0,
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.black, fontSize: 13.0),
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6.0),

                      ),
                    ),
                  ),

                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                  child: FlatButton(
                    onPressed: logoutUser,
                    child: Container(
                      width: 60.0,
                      height: 30.0,
                      child: Text(
                        "LogOut",
                        style: TextStyle(color: Colors.black, fontSize: 13.0),
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6.0),

                      ),
                    ),
                  ),

                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  logoutUser()async {
    await gSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
  }

  Column createProfileNameTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "UserName", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          ),
        )  ,
        TextField(
          style: TextStyle(color: Colors.black),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),

              ),

              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _profileNameValid ? null : "ProfileName is very Short"

          ),
        ),
      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          ),
        )  ,
        TextField(
          style: TextStyle(color: Colors.black),
          controller: bioTextEditingController,
          decoration: InputDecoration(

            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),

            ),

            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
