
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:image_cropper/image_cropper.dart';
import 'file:///C:/Users/ejazh/AndroidStudioProjects/we-thesocialnetwork/lib/pages/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;
import 'package:video_player/video_player.dart';

import 'HomePage.dart';


class UploadPage extends StatefulWidget {
  final User gCurrentUser;

  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>  with AutomaticKeepAliveClientMixin<UploadPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController;
  bool isLoading = false;
  int getPageIndex = 0;
  File file;
  File videoFile;
  VideoPlayerController _controller;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  captureImageWithCamera() async {
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,

        ]
            : [

          CropAspectRatioPreset.square,
          /*CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9*/
        ],
        androidUiSettings: AndroidUiSettings(
            backgroundColor: Colors.white,
            toolbarTitle: 'Crop',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    setState(() {
      this.file = croppedFile;
    }

    );
    isLoading = true;
    createLoading();
  }

  createLoading() {
    return Positioned(
      child: isLoading
          ? Center(child: SizedBox(
          width: 15, height: 15, child: CircularProgressIndicator()))
          : Container(),
    );
  }

  _video() async {
    File theVid = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (theVid != null) {
      setState(() {
        videoFile = theVid;
      });
    }
  }

  pickImageFromGallery() async {
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        maxHeight: 512,
        maxWidth: 512,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          /*CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9*/

        ]
            : [

          CropAspectRatioPreset.square,
          /*CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9*/
        ],

        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    setState(() {
      this.file = croppedFile;
    }
    );
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: Text("Upload Post with ?", style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Camera", style: TextStyle(color: Colors.black,),),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text("Gallery", style: TextStyle(color: Colors.black,),),
              onPressed: pickImageFromGallery,

            ),
            SimpleDialogOption(
              child: Text("Cancel", style: TextStyle(color: Colors.black,),),
              onPressed: () {
                Navigator.pop(context);
              },

            ),

          ],
        );
      },
    );
  }

  /*diaplayUploadScreens(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:<Widget>[
          Icon(Icons.add_a_photo, color: Colors.grey, size:200.0,),
          Padding(
            padding: EdgeInsets.only(top: 20.0 ),
            child: RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0),),
                child: Text("Upload", style: TextStyle(color: Colors.white,fontSize: 20.0),),
                color: Colors.black,
                onPressed: () => takeImage(context)

            ),
          ),
        ],

      ),

    );
  }*/
  clearPostInfo() {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
      videoFile = null;
    });
    Navigator.pop(context);
  }

  clearPostInfoOfVideo() {
       videoFile = null;
  }


  getUserCurrentLocation() async {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(
        position.latitude, position.longitude);
    Placemark mPlacemark = placeMarks[0];
    //String completeAddressInfo = '${mPlacemark.subThoroughfare} ${mPlacemark.thoroughfare} , ${mPlacemark.subLocality} ${mPlacemark.locality}, ${mPlacemark.subAdministrativeArea} ${mPlacemark.administrativeArea}, ${mPlacemark.postalCode} ${mPlacemark.country}';
    String specificAddress = '${mPlacemark.locality}, ${mPlacemark.country}';
    locationTextEditingController.text = specificAddress;
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 70));
    setState(() {
      file = compressedImageFile;
    });
  }

  controlUploadAndSaveVideo() async {
    setState(() {
      uploading = true;
    });

    String downloadVideoUrl = await uploadVideo(videoFile);

    savePostInfoToFireStore(url: downloadVideoUrl,
        location: locationTextEditingController.text,
        description: descriptionTextEditingController.text);

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }


  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    await compressingPhoto();
    String downloadUrl = await uploadPhoto(file);

    savePostInfoToFireStore(url: downloadUrl,
        location: locationTextEditingController.text,
        description: descriptionTextEditingController.text);

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  savePostInfoToFireStore({String url, String location, String description}) {
    postsReference.doc(widget.gCurrentUser.id).collection("usersPosts").doc(
        postId).set({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,


    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask = storageReference.child(
        "post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask
        .onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadVideo(videoFile) async {
    StorageUploadTask mStorageUploadTask = storageReference.child("Videos")
        .child("postVideo_$postId.mp4")
        .putFile(videoFile, StorageMetadata(contentType: 'video/mp4'));

    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask
        .onComplete;
    String downloadVideoUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadVideoUrl;
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  diaplayUploadScreen() {
    onTapChangePage(int pageIndex) {
      pageController.animateToPage(
          pageIndex, duration: Duration(milliseconds: 100),
          curve: Curves.bounceInOut);
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.0,),
          onPressed: clearPostInfo,),
        title: Text("Upload", style: TextStyle(
            fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: PageView(
        children: <Widget>[
          uploadfromCamera(),
          uploadfromGallery(),
          //pickImageFromVideoGallery(),
          uploadVideofromGallery(),

        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
      ),
      /*Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:<Widget>[
            Icon(Icons.add_a_photo, color: Colors.grey, size:150.0,),
            Padding(
              padding: EdgeInsets.only(top: 20.0 ),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0),),
                  child: Text("Select", style: TextStyle(color: Colors.white,fontSize: 20.0,),),
                  color: Colors.black,
                  onPressed: () => takeImage(context)

              ),
            ),
          ],

        ),

    ),*/

      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,

        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        items: [

          BottomNavigationBarItem(icon: Icon(Icons.camera_alt,)),
          BottomNavigationBarItem(icon: Icon(Icons.photo, size: 28,)),
          BottomNavigationBarItem(icon: Icon(Icons.video_library,)),
        ],
        backgroundColor: Colors.white, //.withOpacity(0.1),
      ),

    );
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(
        pageIndex, duration: Duration(milliseconds: 100),
        curve: Curves.bounceInOut);
  }

  uploadfromCamera() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.camera_alt, color: Colors.grey, size: 150.0,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0),),
                  child: Text("Camera",
                    style: TextStyle(color: Colors.white, fontSize: 20.0,),),
                  color: Colors.black,
                  onPressed: () => captureImageWithCamera()

              ),
            ),
          ],

        ),

      ),
    );
  }

  uploadfromGallery() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.photo_library, color: Colors.grey, size: 150.0,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0),),
                  child: Text("Gallery",
                    style: TextStyle(color: Colors.white, fontSize: 20.0,),),
                  color: Colors.black,
                  onPressed: () => pickImageFromGallery()

              ),
            ),
          ],

        ),

      ),
    );
  }

  pickImageFromVideoGallery() {
    return MaterialApp(

        theme: ThemeData.light().copyWith(
        ),


        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: ListView(
              children: [
                Column(
                  children: [
                    Container(

                        child: videoFile == null ? Center(
                            child: Text('')
                        ) :
                        FittedBox(

                            fit: BoxFit.contain,

                            child: mounted ? Chewie(
                              controller: ChewieController(
                                videoPlayerController: VideoPlayerController
                                    .file(videoFile),
                                aspectRatio: 3 / 4,
                                autoPlay: true,
                                looping: true,
                              ),

                            ) : Container()
                        )

                    ),
                    RaisedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('video'),
                          Icon(Icons.video_library),
                        ],
                      ),
                      onPressed: () {
                        _video();
                        _removeVideo();
                      },
                    )

                  ],
                )

              ],
            ),
          ),

        ));
  }

  void _removeVideo() {
    setState(() {
      _video == null;
    });
  }

  uploadVideofromGallery() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.video_library, color: Colors.grey, size: 150.0,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0),),
                  child: Text("Video",
                    style: TextStyle(color: Colors.white, fontSize: 20.0,),),
                  color: Colors.black,
                  onPressed: () => _video()
              ),
            ),
          ],

        ),

      ),
    );
  }

  diaplayVideoUploadFormScreen() {
    return MaterialApp(

      theme: ThemeData.light().copyWith(
      ),


      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,),
            onPressed: clearPostInfo,),
          title: Text("Upload", style: TextStyle(fontSize: 24.0,
              color: Colors.black,
              fontWeight: FontWeight.bold),),

        ),
        body: Center(
          child: ListView(
            children: [
              Column(
                children: [
                  Container(

                      child: videoFile == null ? Center(
                          child: Text('')
                      ) :
                      FittedBox(

                          fit: BoxFit.contain,

                          child: mounted ? Chewie(
                            controller: ChewieController(
                              videoPlayerController: VideoPlayerController.file(
                                  videoFile),
                              aspectRatio: 3 / 4,
                              autoPlay: true,
                              looping: true,
                            ),

                          ) : Container()
                      )

                  ),


                ],
              )

            ],
          ),
        ),

      ),);
  }


  diaplayUploadFormScreen() {
    return Scaffold(

      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: clearPostInfo,),
        title: Text("Upload", style: TextStyle(
            fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),),

      ),
      body: ListView(
        children: <Widget>[
          uploading
              ? LinearProgressIndicator(backgroundColor: Colors.white,)
              : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery
                .of(context)
                .size
                .width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(
                      image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(
                widget.gCurrentUser.url),),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Say Something...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          ListTile(
            onTap: getUserCurrentLocation,
            leading: Icon(
              Icons.person_pin_circle, color: Colors.black, size: 30.0,),
            trailing: Icon(Icons.my_location, color: Colors.black, size: 25.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: "Location",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Container(
            width: 220.0,
            height: 50.0,
            alignment: Alignment.center,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),),
              color: Colors.white,
              child: Text("Share", style: TextStyle(color: Colors.black),),
              onPressed: uploading ? null : () => controlUploadAndSave(),

            ),
          ),
        ],
      ),

    );
  }

  select() {
    if (file != null) {
      return Scaffold(

        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,),
            onPressed: clearPostInfo,),
          title: Text("Upload", style: TextStyle(fontSize: 24.0,
              color: Colors.black,
              fontWeight: FontWeight.bold),),

        ),
        body: ListView(
          children: <Widget>[
            uploading
                ? LinearProgressIndicator(backgroundColor: Colors.white,)
                : Text(""),
            Container(
              height: 230.0,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    decoration: BoxDecoration(image: DecorationImage(
                        image: FileImage(file), fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0),
            ),
            Divider(),
            ListTile(
              leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(
                  widget.gCurrentUser.url),),
              title: Container(
                width: 250.0,
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  controller: descriptionTextEditingController,
                  decoration: InputDecoration(
                    hintText: "Say Something...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: getUserCurrentLocation,
              leading: Icon(
                Icons.person_pin_circle, color: Colors.black, size: 30.0,),
              trailing: Icon(
                Icons.my_location, color: Colors.black, size: 25.0,),
              title: Container(
                width: 250.0,
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  controller: locationTextEditingController,
                  decoration: InputDecoration(
                    hintText: "Location",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            Container(
              width: 220.0,
              height: 50.0,
              alignment: Alignment.center,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),),
                color: Colors.white,
                child: Text("Share", style: TextStyle(color: Colors.black),),
                onPressed: uploading ? null : () => controlUploadAndSave(),

              ),
            ),
          ],
        ),

      );
    }
    else {
      return MaterialApp(

        theme: ThemeData.light().copyWith(
        ),


        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black,),
              onPressed: clearPostInfoOfVideo,),
            title: Text("Upload", style: TextStyle(fontSize: 24.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),),

          ),
          body: Center(
            child: ListView(
              children: [
                Column(
                  children: [
                    Container(

                        child: videoFile == null ? Center(
                            child: Text('')
                        ) :
                        FittedBox(

                            fit: BoxFit.contain,

                            child: mounted ? Chewie(
                              controller: ChewieController(
                                videoPlayerController: VideoPlayerController
                                    .file(videoFile),
                                aspectRatio: 3 / 4,
                                autoPlay: true,
                                looping: true,
                              ),

                            ) : Container()
                        )

                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            widget.gCurrentUser.url),),
                      title: Container(
                        width: 250.0,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: descriptionTextEditingController,
                          decoration: InputDecoration(
                            hintText: "Say Something...",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: getUserCurrentLocation,
                      leading: Icon(
                        Icons.person_pin_circle, color: Colors.black,
                        size: 30.0,),
                      trailing: Icon(
                        Icons.my_location, color: Colors.black, size: 25.0,),
                      title: Container(
                        width: 250.0,
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: locationTextEditingController,
                          decoration: InputDecoration(
                            hintText: "Location",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: 220.0,
                      height: 50.0,
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),),
                        color: Colors.white,
                        child: Text("Share", style: TextStyle(color: Colors
                            .black),),
                        onPressed: uploading ? null : () =>
                            controlUploadAndSaveVideo(),

                      ),
                    ),


                  ],
                )

              ],
            ),
          ),

        ),

      );
    }
  }

  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return file == null && videoFile == null ? diaplayUploadScreen() : select();
  }

}