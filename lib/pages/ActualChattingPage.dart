
import 'dart:io';
import 'FullImageWidget.dart';
import 'HomePage.dart';
import 'user.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ActualChattingPage extends StatelessWidget{
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;


  ActualChattingPage(
  {
   Key key,

    @required this.recieverId,
    @required this.recieverAvatar,
    @required this.recieverName
});

  @override
  Widget build(BuildContext context){
    return  Container(
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage("assets/images/chatBackgroundImage.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all((8.0)),
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              backgroundImage: CachedNetworkImageProvider(recieverAvatar, ),
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.black
        ),
       title: Text(
         recieverName ,
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
      body:
      Chatting(recieverId: recieverId, recieverAvatar: recieverAvatar),
    ),);
  }
}

class Chatting extends StatefulWidget{
  final String recieverId;
  final String recieverAvatar;
  Chatting({
    Key key,
    this.recieverId,
    this.recieverAvatar,
  }
      ): super (key : key);


  @override
  State createState() => ChattingState(recieverId: recieverId, recieverAvatar: recieverAvatar);
}

class ChattingState extends State<Chatting>{
  final String recieverId;
  final String recieverAvatar;
  final User gCurrentUser;
  ChattingState({
    Key key,
    this.gCurrentUser,
    this.recieverId,
    this.recieverAvatar,
  }
      );
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;
  File imageFile;
  String imageUrl;
  var listMessage;

  String chatId;
  SharedPreferences preferences ;
  String id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);

    isDisplaySticker = false;
    isLoading = false;
    chatId = "";
    readLocal();
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if(id.hashCode <= recieverId.hashCode){
      chatId = '$id-$recieverId';
    }
    else{
      chatId = '$recieverId-$id';
    }

    FirebaseFirestore.instance.collection("users").doc(id).update({'chattingWith': recieverId});
    setState(() {

    });
  }

  onFocusChange(){
    if(focusNode.hasFocus){
      setState(() {
        isDisplaySticker = false;
      });
    }
  }
  @override
  Widget build(BuildContext context){
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(children: <Widget>[
            createMesssgesList(),
            (isDisplaySticker ? createStickers(): Container()),
            createInput(),
          ],
          ),
          createLoading(),
        ],
      ),
      onWillPop: onBackPressed,
    );
  }
  createLoading(){
    return Positioned(
      child: isLoading ? Center(child: SizedBox( width: 15, height: 15, child: CircularProgressIndicator())) : Container() ,
    );
  }

  Future<bool> onBackPressed() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    }
    else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createStickers(){
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
               onPressed:()=> SendMessage("1", 2),
                child: Image.asset(
                  "assets/images/1.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                 onPressed:()=> SendMessage("2", 2),
                child: Image.asset(
                  "assets/images/2.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:()=> SendMessage("3", 2),
                child: Image.asset(
                  "assets/images/3.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),

            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),


          Row(

            children: <Widget>[
              FlatButton(
                onPressed:()=>SendMessage("4", 2),
                child: Image.asset(
                  "assets/images/4.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                 onPressed:()=> SendMessage("5", 2),
                child: Image.asset(
                  "assets/images/5.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: ()=>SendMessage("6", 2),
                child: Image.asset(
                  "assets/images/6.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),

            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),



          Row(
            children: <Widget>[
              FlatButton(
                onPressed:()=> SendMessage("7", 2),
                child: Image.asset(
                  "assets/images/7.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                 onPressed: ()=>SendMessage("8", 2),
                child: Image.asset(
                  "assets/images/8.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                 onPressed:()=> SendMessage("9", 2),
                child: Image.asset(
                  "assets/images/9.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),

            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),


        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey,width: 0.5)), color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }
  createMesssgesList(){
    return
      Flexible(
      child: chatId  == "" ? Center(child: SizedBox( width: 30, height: 30, child: CircularProgressIndicator())) : StreamBuilder(
        stream: FirebaseFirestore.instance.collection("messages")
            .doc(chatId ).collection(chatId )
            .orderBy("timestamp",descending: true).limit(20)
            .snapshots(),

        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(child: SizedBox( width: 30, height: 30, child: CircularProgressIndicator()));
          }
          else{
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
             itemBuilder: (context, index)=> createItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
      //
    );
  }

  bool isLastMsgLeft(int index){
    if((index>0 && listMessage!=null && listMessage[index-1].data()["idFrom"] != id) || index == 0)
    {
      return true;
    }
    else{
      return false;
    }

  }


  bool isLastMsgRight(int index){
    if((index>0 && listMessage!=null && listMessage[index-1].data()["idFrom"] == id) || index == 0)
      {
        return true;
      }
    else{
      return false;
    }

  }


  Widget createItem(int index, DocumentSnapshot document){
    if(document.data()["idFrom"] == id){
      return Container(
          child: Column(
              children:<Widget> [
          Row(
          children: <Widget>[
          document.data()["type"] == 0
              //text
              ? Container(
            padding: EdgeInsets.all(5.0),
            constraints: BoxConstraints( maxWidth: 180,),
            child: Column(
              children: <Widget> [
                Material(
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 6.0,
                  child: Container(
                    constraints: BoxConstraints( maxWidth: 180, minWidth: 25.0),
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                    child: RichText(
                      text: TextSpan(
                          text: document.data()["content"],

                          style: TextStyle(fontSize: 15.0,color: Colors.black),
                          children: <TextSpan>[

                      TextSpan(text:DateFormat("  HH:mm").format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.data()["timestamp"])),
                      ),
                      style: TextStyle( fontSize: 8.0, color: Colors.grey),
                    ),
                          ],
                  ),
      ),

                )
                )],
            ),
            margin: EdgeInsets.only(right: 5.0),
          )




              //image
           :    document.data()["type"] == 1
              ? Container(
                 child: FlatButton(
                   child: Material(

                     child: CachedNetworkImage(
                       placeholder: (context, url) => Container(
                         child: CircularProgressIndicator(
                           valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                         ),
                         width: 200.0,
                         height: 200.0,

                         padding: EdgeInsets.all(70.0),
                         decoration: BoxDecoration(
                           color: Colors.grey,
                           borderRadius: BorderRadius.all(Radius.circular(8.0)),
                         ),
                       ),
                       errorWidget: (context, url, error) => Material(
                         child: Image.asset("assets/images/google_signin_button.png", width: 200.0, height: 200.0,fit: BoxFit.cover,),
                         borderRadius: BorderRadius.all(Radius.circular(8.0)),
                         clipBehavior: Clip.hardEdge,
                       ),
                       imageUrl: document.data()["content" ] ,
                       width: 200.0,
                       height: 200.0,
                       fit: BoxFit.cover,
                     ),
                     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                     clipBehavior: Clip.hardEdge,
                   ),
                   onPressed: (){
                     Navigator.push(context, MaterialPageRoute(
                       builder:(context) => FullPhoto(url: document.data()["content"])
                     ));
                   },
                 ),
                margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 10.0 : 10.0),
               )

              //Sticker
              : Container(
                 child: Image.asset(
                   "assets/images/${document.data()['content']}.gif",
                   width: 100.0,
                     height: 100.0,
                   fit: BoxFit.cover,
                 ),
            margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 5.0),

               ),


        ],
        mainAxisAlignment: MainAxisAlignment.end,
      ),

    ],
            crossAxisAlignment: CrossAxisAlignment.end,

      ));

    }

    else{
      return Container(
        child: Column(
          children:<Widget> [
            Row(
               children: <Widget>[
                  document.data()["type"] == 0
                 //text
                     ? Container(
                    padding: EdgeInsets.only(top: 8.0),
                    constraints: BoxConstraints( maxWidth: 180),
                    child: Column(
                      children: <Widget> [
                        Material(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12.0),
                          elevation: 6.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                            child: RichText(
                              text: TextSpan(
                                text: document.data()["content"],
                                style: TextStyle(fontSize: 15.0,color: Colors.white),
                                children: <TextSpan>[
                                  TextSpan(text:DateFormat("  HH:mm").format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.data()["timestamp"])),
                                  ),
                                    style: TextStyle( fontSize: 8.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),


                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                  )

                  //image
                     : document.data()["type"] == 1
                     ? Container(
                   child: FlatButton(
                     child: Material(
                       child: CachedNetworkImage(
                         placeholder: (context, url) => Container(
                           child: CircularProgressIndicator(
                             valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                           ),
                           width: 200.0,
                           height: 200.0,
                           padding: EdgeInsets.all(70.0),
                           decoration: BoxDecoration(
                             color: Colors.grey,
                             borderRadius: BorderRadius.all(Radius.circular(8.0)),
                           ),
                         ),
                         errorWidget: (context, url, error) => Material(
                           child: Image.asset("assets/images/google_signin_button.png", width: 200.0, height: 200.0,fit: BoxFit.cover,),
                           borderRadius: BorderRadius.all(Radius.circular(8.0)),
                           clipBehavior: Clip.hardEdge,
                         ),
                         imageUrl: document.data()["content"],
                         width: 200.0,
                         height: 200.0,
                         fit: BoxFit.cover,


                       ),
                       borderRadius: BorderRadius.all(Radius.circular(8.0)),
                       clipBehavior: Clip.hardEdge,
                     ),
                     onPressed: (){
                       Navigator.push(context, MaterialPageRoute(
                           builder:(context) => FullPhoto(url: document.data()["content"])
                       ));
                     },
                   ),

                 )

                 //sticker
                     : Container(
                   child: Image.asset(
                     "assets/images/${document.data()['content']}.gif",
                     width: 100.0,
                     height: 100.0,
                     fit: BoxFit.cover,
                   ),
                   margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),

                 ),
               ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  void getStickers(){
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;

    });

  }

  createInput(){
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.black,
                onPressed:()=>  getImage(),
              ),
            ),
          ),

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.black,
                onPressed: getStickers,
              ),
            ),
          ),

          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: Colors.black, fontSize: 15.0,
                ),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                    hintText: "Messege Here",
                     hintStyle: TextStyle(color:Colors.grey)
                    ),
                focusNode: focusNode,

              ),
            ),
          ),

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.black,
                onPressed: ()=>SendMessage(textEditingController.text, 0),
              ),
            ),
            color: Colors.white,
          )

        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
            color: Colors.white,
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void SendMessage(String contentMsg, int type){
         if(contentMsg!= ""){
           textEditingController.clear();

           var docRef = FirebaseFirestore.instance.collection("messages").doc(chatId)
               .collection(chatId).doc(DateTime.now().millisecondsSinceEpoch.toString());

           FirebaseFirestore.instance.runTransaction((transaction) async {
             transaction.set(docRef,{
               "idFrom": currentUser.id,
               "idTo" : recieverId,
               "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
               "content": contentMsg,
               "type": type,
             },);
           });
           listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
         }
         else{
          Fluttertoast.showToast(msg: "Empty Message. cannot br sent.");
         }

  }


 Future getImage() async {
    // ignore: deprecated_member_use
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        maxHeight: 512,
        maxWidth: 512,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9

        ]
            : [

          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],

        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    var result = await FlutterImageCompress.compressAndGetFile(
       imageFile.path,
      croppedFile.path,
      quality: 50,
    );

    uploadImageFile(result);
    if(imageFile != null ){
      isLoading = true;
    }
}

  // ignore: missing_return
  Future<String>  uploadImageFile(result) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageUploadTask storageUploadTask = storageReference.child("Chat Images").child(fileName).putFile(result);
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        SendMessage(imageUrl, 1);
      });
    },
    onError: (error){
      setState(() {
        isLoading = false;
      });
        Fluttertoast.showToast(msg: "Error" + error);
    });

  }
}
