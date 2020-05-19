import 'dart:typed_data';
import 'package:http/http.dart' as http;


class UserModel {

  String uid;
  String name;
  Uint8List photo;
  bool inDatabase;
  String role;
  String identifier;

  UserModel(this.uid, this.name, String photoUrl, this.inDatabase, this.role, [this.identifier]){
    if (photoUrl != null){
      _loadFromUrl(photoUrl);
    }
  }

  void _loadFromUrl(String url) async {

    try{
      Uint8List bytes = await http.readBytes(url, headers: {});
      photo = bytes;
    }
    catch(e){
      print('Fetch Profile Pic: ' + e.toString());
    }
  }

}