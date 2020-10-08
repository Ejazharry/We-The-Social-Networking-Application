import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HangoutProfileSetUpPage {
  final FirebaseFirestore  _firestore;

  HangoutProfileSetUpPage(this._firestore);
  Future<void>profileSetup(
  File photo,
  String gender,
  String Hangoutname,
  String interestedIn,
  String Hangoutid,
  DateTime age,
  GeoPoint location,
      )
    async{
      StorageUploadTask storageUploadTask;
      storageUploadTask =FirebaseStorage.instance.ref().child('UserProfilePhotoOfHangouts').child(Hangoutid).child(Hangoutid).putFile(photo);
      return await storageUploadTask.onComplete.then((ref) async {
        await ref.ref.getDownloadURL().then((url) async {
          await _firestore.collection('hangoutusers').doc(Hangoutid).set({
            'uid': Hangoutid,
            'photoUrl': url,
            'name': Hangoutname,
            "location": location,
            'gender': gender,
            'interestedIn': interestedIn,
            'age': age
          });
        });
      });
    }
}