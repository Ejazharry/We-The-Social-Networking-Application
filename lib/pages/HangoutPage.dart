import 'package:flutter/material.dart';

class Meet extends StatefulWidget {
  @override
  _MeetState createState() => _MeetState();
}

class _MeetState extends State<Meet> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          backgroundColor: Colors.white,
          title:  Center(
            child: Text(
              "Meet",
              style: TextStyle( color: Colors.black, ),
            ),
          ),
          leading: new IconButton(
            icon: new Icon(Icons.dehaze),
            onPressed: () {},
          ),

          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () {},
            )

          ],
        ),

        body:
        Center(child:
        PageView(
          controller: _controller,
          scrollDirection: Axis.vertical,
          children: <Widget>[


            image1(),

            image2(),
            image3(),
            image4(),
            image5(),
            /* Container(
             alignment: Alignment.bottomCenter,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: <Widget>[
                 FloatingActionButton(
                   onPressed: (){},
                   child: Icon(
                     Icons.close,
                      color: Colors.black,
                   ),
                 )
               ],
             ),
           )*/
          ],

        ),

        )

    );
  }
}
image1() {
  AssetImage assetImage = AssetImage('assets/images/1.jpg',);
  Image image = Image(image: assetImage, height: 20,fit: BoxFit.fill);
  return Container( child: image, );
}
image2() {
  AssetImage assetImage = AssetImage('assets/images/2.jpg');
  Image image = Image(image: assetImage,);
  return Container(child: image,);  }
image3() {
  AssetImage assetImage = AssetImage('assets/images/3.jpg');
  Image image = Image(image: assetImage,);
  return Container(child: image,);  }
image4() {
  AssetImage assetImage = AssetImage('assets/images/4.jpg');
  Image image = Image(image: assetImage,);
  return Container(child: image,);

}
image5() {
  AssetImage assetImage = AssetImage('assets/images/5.jpg');
  Image image = Image(image: assetImage,);
  return Container(child: image,);

}
