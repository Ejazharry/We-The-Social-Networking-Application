import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key : key);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
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
          "Full Image",
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
      body: FullPhotoScreen(url: url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {

  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key : key);
  @override
  State createState() => FullPhotoScreenState(url:url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;
  double _scale = 1.0;
  double _previousScale = 1.0;

  FullPhotoScreenState({Key key, @required this.url});
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

   /*return Container(
     child: PhotoView(
         imageProvider: url != null ? NetworkImage(url) : NetworkImage("")
   ));*/
    return GestureDetector(

      onScaleStart: (ScaleStartDetails details){
        print(details);
        _previousScale = _scale;
        setState(() {

        });
      },
      onScaleUpdate: (ScaleUpdateDetails details){
        print(details);
        _scale = _previousScale * details.scale;
        setState(() {

        });

      },
      onScaleEnd: (ScaleEndDetails details){
        print(details);
        _scale = 1.0;
        setState(() {

        });
      },


      //onDoubleTap: ()=> controlUserLikePost,
      child: RotatedBox(
        quarterTurns: 0,
        child: Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.diagonal3(Vector3(_scale,_scale,_scale)),
          child: PhotoView(
        imageProvider: url != null ? NetworkImage(url) : NetworkImage("")
    )
        ),

      ),
      /*child: Stack(
             alignment: Alignment.center,
             children: <Widget>[
               transform:
              Image.network(url),
            //showHeart? Icon(Icons.insert_emoticon, size: 20.0, color: Colors.black,): Text(""),
          ],

        ),*/
    );
  }
}