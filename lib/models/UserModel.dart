import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum UserRole { Admin, Member, FormerMember }

class UserModel {
  String uid;
  String name;
  Uint8List? photoBytes;
  String? photoURL;
  UserRole? role;
  String? identifier;
  bool? isAnonymous;
  Map<String, String>? membership = {};

  UserModel(this.uid, this.name, this.photoURL,
      {this.role, this.identifier, this.isAnonymous, this.membership}) {
    photo = photoURL;
  }

  UserModel.roleString(this.uid, this.name, this.photoURL,
      {required String role, this.identifier, this.isAnonymous, this.membership}) {
    roleString = role;
    photo = photoURL;
  }

  set roleString(String? roleString) {
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
      case UserRole.FormerMember:
        return 'formerMember';
      case UserRole.Admin:
        return 'admin';
      default:
        debugPrint('UserModel.roleString fired, no matching role');
        return '';
    }
  }

  set photo(String? photoURL) {
    loadPhotoFromURL(photoURL);
  }

  Future<void> loadPhotoFromURL(String? url) async {
    if (url != null) {
      try {
        photoURL = url;
        var uri = Uri.parse(url);
        photoBytes = await http.readBytes(uri, headers: {});
        return;
      } catch (e) {
        print('Fetch Profile Pic: ' + e.toString());
      }
    }
    // ByteData bytes = await rootBundle.load('assets/anonymous_user_icon.png');
    // photoBytes = bytes.buffer.asUint8List();
  }
}
