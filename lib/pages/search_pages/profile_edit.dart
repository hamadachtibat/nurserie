import 'dart:developer';
import 'dart:io';
import 'dart:math' as mth;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Hathante/blocs/internet_bloc.dart';
import 'package:Hathante/blocs/user_bloc.dart';
import 'package:Hathante/utils/snacbar.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileEditPage extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String imagePath;
  ProfileEditPage({Key key, @required this.imageUrl, this.name, this.imagePath})
      : super(key: key);

  @override
  _ProfileEditPageState createState() =>
      _ProfileEditPageState(this.imageUrl, this.name);
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  _ProfileEditPageState(this.imageUrl, this.name);

  String imageUrl;
  String name;
  File imageFile;
  String fileName;
  bool loading = false;
  String newImagePath;

  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future pickImage() async {
    PickedFile pickedFile = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);
    File imagepicked = File(pickedFile.path);
    if (imagepicked != null) {
      setState(() {
        imageFile = imagepicked;
        fileName = (imageFile.path);
      });
    } else {
      print('No image has is selected!');
    }
  }

  Future uploadPicture() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String uid = sp.getString('uid');
    int rand = mth.Random().nextInt(5000);
    String path = rand.toString() + uid;
    Reference storageReference =
        FirebaseStorage.instance.ref("user_image").child(path);
    TaskSnapshot uploadTask = await storageReference.putFile(imageFile);
    // if (uploadTask.isComplete) {print('upload complete');}
    var _url = await uploadTask.ref.getDownloadURL();
    newImagePath = path;
    var _imageUrl = _url.toString();
    setState(() {
      imageUrl = _imageUrl;
    });
  }

  Future deleteOldImage() async {
    try {
      if (widget.imagePath != "google") {
        print(widget.imagePath);
        await FirebaseStorage.instance
            .ref('user_image')
            .child(widget.imagePath)
            .delete();
      }
    } catch (e) {
      log("error in deleteing image : " + e.toString());
      // throw e ;
    }
  }

  handleSaveData() async {
    final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
    final InternetBloc ib = Provider.of<InternetBloc>(context, listen: false);
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openSnacbar(scaffoldKey, 'No internet connection'.tr());
    } else {
      if (formKey.currentState.validate()) {
        formKey.currentState.save();
        setState(() {
          loading = true;
        });
        imageFile == null
            ? ub.updateNewData(name, imageUrl, null).then((_) {
                openSnacbar(scaffoldKey, 'Updated Successfully'.tr());
                setState(() {
                  loading = false;
                });
              }).catchError((e) => setState(() {
                  openSnacbar(scaffoldKey, 'error'.tr());
                  loading = false;
                }))
            : uploadPicture()
                .then((value) => ub
                        .updateNewData(name, imageUrl, newImagePath)
                        .then((_) async {
                      await deleteOldImage();
                      openSnacbar(scaffoldKey, 'Updated Successfully'.tr());
                      setState(() {
                        loading = false;
                      });
                    }))
                .catchError((e) => setState(() {
                      openSnacbar(scaffoldKey, 'error'.tr());
                      loading = false;
                    }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.imagePath);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Edit Profile'.tr(),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(25),
          child: ListView(
            children: <Widget>[
              InkWell(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey[800]),
                        color: Colors.grey[500],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageFile == null
                                ? CachedNetworkImageProvider(imageUrl)
                                : FileImage(imageFile),
                            fit: BoxFit.cover)),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.black,
                        )),
                  ),
                ),
                onTap: () {
                  pickImage();
                },
              ),
              SizedBox(
                height: 50,
              ),
              Form(
                  key: formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter New Name'.tr(),
                    ),
                    initialValue: name,
                    validator: (value) {
                      if (value.length == 0) return "Name can't be empty".tr();
                      return null;
                    },
                    onChanged: (String value) {
                      setState(() {
                        name = value;
                      });
                    },
                  )),
              SizedBox(
                height: 50,
              ),
              Container(
                height: 45,
                child: RaisedButton(
                  textColor: Colors.white,
                  color: Colors.blueAccent,
                  child: Text(
                    'Save Data'.tr(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    handleSaveData();
                  },
                ),
              ),
              SizedBox(
                height: 100,
              ),
              loading == true
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
            ],
          )),
    );
  }
}
