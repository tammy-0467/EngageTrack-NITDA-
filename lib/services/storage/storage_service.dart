import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService with ChangeNotifier {
  // firebase storage
  final firebaseStorage = FirebaseStorage.instance;

  /*
  * Images are stored in firebase as download URLs

  * */
  List<String> _imageUrls = [];

  //loading status
  bool _isLoading = false;

  //uploading status
  bool _isUploading = false;

  //Getters
  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;


  //Read Images
  Future<void> fetchImages() async {
    //start loading
    _isLoading = true;

    //get the list under the directory: uploaded_images/
    final ListResult result = await firebaseStorage.ref('upload_images/').listAll();

    //get the download URLs for each image
    final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    //update URls
    _imageUrls = urls;

    //loading finished..
    _isLoading = false;

    //update UI
    notifyListeners();

  }


  //Delete Images
  Future<void> deleteImages(String imageUrl) async {
    try {
      //remove from local list
      _imageUrls.remove(imageUrl);

      //get path name and delete from firebase
      final String path = extractPathFromUrl(imageUrl);

      await firebaseStorage.ref(path).delete();
    } catch (e) {
      print("Error deleting image: $e");
    }

    notifyListeners();
  }

  String extractPathFromUrl(String url){
    Uri uri = Uri.parse(url);

    //extracting the part of the url we need
    String encodedPath = uri.pathSegments.last;

    //url decoding the path
    return Uri.decodeComponent(encodedPath);
  }


  //upload images
  Future <void> uploadImage()async {
    // start upload
    _isUploading = true;
    // update UI
    notifyListeners();

    //pick an image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return; //user cancelled the picker

    File file = File(image.path);

    try {
      //define the path in storage
      String filepath = "uploaded_images/${DateTime.now()}.png";

      //upload the file to firebase storage
      await firebaseStorage.ref(filepath).putFile(file);

      //after uploading..fetch the download Url
      String downloadUrl = await firebaseStorage.ref(filepath).getDownloadURL();

      //update the image urls list and UI
      _imageUrls.add(downloadUrl);
      notifyListeners();
    }

    //handle errors
    catch (e) {
      print("Error uploading..$e");
    }

    finally {
      _isUploading = false;
      notifyListeners();
    }

  }
}