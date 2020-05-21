import 'dart:typed_data';
import 'package:http/http.dart' as http;


class UserModel {

  String uid;
  String name;
  Uint8List photo;
  String photoURL;
  bool inDatabase;
  String role;
  String identifier;

  UserModel(this.uid, this.name, this.photoURL, this.inDatabase, this.role, [this.identifier]){
    loadPhotoFromURL(photoURL);
  }

  Future<void> loadPhotoFromURL(String url) async {
    if (url != null){
      try{
        photoURL = url;
        photo = await http.readBytes(url, headers: {});
      }
      catch(e){
        print('Fetch Profile Pic: ' + e.toString());
      }
    }
  }

}