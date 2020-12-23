import 'dart:typed_data';
import 'package:http/http.dart' as http;

enum UserRole { Admin, Member, FormerMember }

class UserModel {
  String uid;
  String name;
  Uint8List _photo;
  String photoURL;
  UserRole role;
  String identifier;
  bool isAnonymous;
  Map<String, String> membership = {};

  UserModel(this.uid, this.name, this.photoURL,
      {this.role, this.identifier, this.isAnonymous, this.membership}) {
    photo = photoURL;
  }

  UserModel.roleString(this.uid, this.name, this.photoURL,
      {String role, this.identifier, this.isAnonymous, this.membership}) {
    roleString = role;
    photo = photoURL;
  }

  set roleString(String roleString) {
    switch (roleString) {
      case 'member':
        role = UserRole.Member;
        break;
      case 'formerMember':
        role = UserRole.FormerMember;
        break;
      case 'admin':
        role = UserRole.Admin;
        break;
      default:
        role = null;
    }
  }

  String get roleString {
    switch (role) {
      case UserRole.Member:
        return 'member';
        break;
      case UserRole.FormerMember:
        return 'formerMember';
        break;
      case UserRole.Admin:
        return 'admin';
        break;
      default:
        return null;
    }
  }

  set photo(String photoURL) {
    loadPhotoFromURL(photoURL);
  }

  Future<void> loadPhotoFromURL(String url) async {
    if (url != null) {
      try {
        photoURL = url;
        _photo = await http.readBytes(url, headers: {});
      } catch (e) {
        print('Fetch Profile Pic: ' + e.toString());
      }
    }
  }
}
