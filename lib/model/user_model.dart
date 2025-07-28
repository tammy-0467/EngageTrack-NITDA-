//import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? username;
  // final String? id;
  final String? address;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? imageUrl;
  String? emailInput;
  String? id;
  final DateTime? createdAt;

  UserModel({
    this.emailInput,
    required this.username,
    required this.address,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    this.id,
    this.createdAt,
  });

  //bool get isEmpty => null;

  static UserModel fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data() ?? {};
    //create user instance from this snapshot and create a new user object
    return UserModel(
        emailInput: data['emailInput'] ?? "Not yet assigned by admin",
        username: data['username'] ?? "update required",
        lastName: data['lastName'] ?? "update required",
        firstName: data['firstName'] ?? "no first name",
        address: data['address'] ?? "update required",
        phone: data['Phone Number'] ?? "update required",
        id: data['id'] ?? "not yet assigned by admin",
        createdAt: data['createAt'],
        imageUrl: data['imageUrl'] ?? 'noImage');
  }

  Map<String, dynamic> toJson() {
    //use user instance of the created new object to
    return {
      "emailInput": emailInput,
      "username": username,
      "address": address,
      "Phone Number": phone,
      // "id": id,
      'firstName': firstName,
      'lastName': lastName,
      'imageUrl': imageUrl,
      'createdAt': createdAt
    };
  }
}
