import 'ActualChattingPage.dart';
import 'file:///C:/Users/ejazh/AndroidStudioProjects/we-thesocialnetwork/lib/pages/user.dart';
import 'HomePage.dart';
import 'ProfilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin<ChatPage>
{
  TextEditingController searchTextEditingController = TextEditingController();
  Future< QuerySnapshot>futureSearchResults;

  emptyTheTextFormField(){
    searchTextEditingController.clear();
  }
  controlSearching(String str){

    Future<QuerySnapshot> allUsers = usersReference.where("profileName",
        isGreaterThanOrEqualTo: str).get();
    setState(() {
      futureSearchResults = allUsers;
    });
  }
  AppBar searchPageHeader(){
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      backgroundColor: Colors.white,
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back_ios, color: Colors.black,size: 20,),
        onPressed: () {

        },
      ),
      title: TextFormField(
        cursorColor: Colors.black54,
        cursorWidth: 1.5,
        style: TextStyle(fontSize: 16.0,),
        controller: searchTextEditingController,
        decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                width: 2,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            contentPadding: EdgeInsets.all(16),
            prefixIcon: Icon(Icons.chat, color:Colors.black87,size:21.0),
            suffixIcon: IconButton(icon: Icon(Icons.clear,color:Colors.black,size: 20,),
              onPressed:emptyTheTextFormField,)

        ),
        onFieldSubmitted: controlSearching,

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
    );
  }
  displayNoSearchResultScreen() {
    return Container(
      child: Center(
        child: ListView(

        ),

      ),
    );
  }

  displayUsersFoundScreen(){

    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot)
      {
        if(!dataSnapshot.hasData)
        {
          return  Center(child:
          SizedBox( width: 30, height: 30, child: CircularProgressIndicator()));
        }
        List<UserResult>searchUsersResult = [];
        dataSnapshot.data.documents.forEach((document)
        {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUsersResult.add(userResult);
        }
        );
        return ListView(children: searchUsersResult);
      },
    );

  }

  bool get wantKeepAlive => true;
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchPageHeader(),
      body: futureSearchResults == null ? displayNoSearchResultScreen() : displayUsersFoundScreen(),

    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(.0),
      child: Container(

        color: Colors.white54,
        child: Column(

          children: <Widget>[
            GestureDetector(
              onTap: () => sendUserToChatPage(context),
              child: ListTile(

                  leading: CircleAvatar(backgroundColor: Colors.black, backgroundImage:CachedNetworkImageProvider(eachUser.url),),
                  title: Text(eachUser.username, style:TextStyle(
                    color: Colors.black,fontSize: 15.0, fontWeight: FontWeight.bold,
                  ),),

              ),
            ),
            Divider(color: Colors.grey,),
          ],
        ),
      ),
    );
  }
  sendUserToChatPage(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ActualChattingPage(recieverId: eachUser.id, recieverAvatar: eachUser.url, recieverName: eachUser.username)));
  }
  displayUserProfile(BuildContext context, {String userProfileId})
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userProfileId: userProfileId,)));
  }
}
