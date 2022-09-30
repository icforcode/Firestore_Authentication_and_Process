import 'dart:async';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreIslemleri extends StatelessWidget {
  FirestoreIslemleri({Key? key}) : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscribe;

  void dataAdd() async {
    Map<String, dynamic> _eklenecekUser = <String, dynamic>{};
    _eklenecekUser['isim'] = 'scww';
    _eklenecekUser['yas'] = 21;
    _eklenecekUser['ogrenciMi'] = true;
    _eklenecekUser['adres'] = {'il': 'ankara', 'ilce': 'yenimahalle'};
    _eklenecekUser['renkler'] = FieldValue.arrayUnion(['sarı', 'kırmızı']);
    _eklenecekUser['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').add(_eklenecekUser);
  }

  void dataSet() async {
    var _yeniDocID = _firestore.collection("users").doc().id;
    await _firestore
        .doc("users/$_yeniDocID")
        .set({"hastalık": "yok", "userID": _yeniDocID});
    await _firestore.doc('users/Qhry2S0anX59VsuITkcK').set(
        {"okul": "ktü", "yas": FieldValue.increment(1)},
        SetOptions(merge: true));
  }

  void dataUpdate() async {
    /*  await _firestore
        .doc('users/Qhry2S0anX59VsuITkcK')
        .update({"isim": "icww", "ogrenciMi ": true}); */

    await _firestore
        .doc('users/Qhry2S0anX59VsuITkcK')
        .update({"adres.ilce": "demeteveler"});
  }

  void dataDel() async {
    await _firestore.doc('users/Qhry2S0anX59VsuITkcK').delete();

    /*  await _firestore
        .doc('users/Qhry2S0anX59VsuITkcK')
        .update({"okul": FieldValue.delete()}); */
  }

  void dataReadOneTime() async {
    var _usersDocuments = await _firestore.collection("users").get();
    debugPrint(_usersDocuments.docs.length.toString());
    for (var eleman in _usersDocuments.docs) {
      debugPrint("döküman id ${eleman.id}");
      Map userMap = eleman.data();
      debugPrint(userMap["isim"]);
    }

    var _icwwDoc = await _firestore.doc("users/oPxJudjMW95F8L83Jc2D").get();
    debugPrint(_icwwDoc.data()!["adres"]["il"].toString());
  }

  void dataReadRealTime() async {
    // var _userStream = await _firestore.collection("users").snapshots();
    var _userDocStream =
        await _firestore.doc("users/oPxJudjMW95F8L83Jc2D").snapshots();
    _userSubscribe = _userDocStream.listen((event) {
      /*   event.docChanges.forEach((element) {
        debugPrint(element.doc.data().toString());
      }); */

      debugPrint(event.data().toString());
      /*    event.docs.forEach((element) {
        debugPrint(element.data().toString());
      }); */
    });
  }

  void stopStream() async {
    await _userSubscribe?.cancel();
  }

  void Batchdata() async {
    //tek bacth de 500 işlem yapılabilir
    WriteBatch _batch = _firestore.batch();

    CollectionReference _counterColRef = _firestore.collection("counter");
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });

    /* var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.update(
          element.reference, {"createdAt": FieldValue.serverTimestamp()});
    }); */

    /*  for (int i = 0; i < 100; i++) {
      var _yeniDoc = _counterColRef.doc();
      _batch.set(_counterColRef.doc(), {"sayac": ++i, "id": _yeniDoc.id});
    } */

    await _batch.commit();
  }

  void transactionButton() async {
    _firestore.runTransaction((transaction) async {
      DocumentReference<Map<String, dynamic>> acwwRef =
          _firestore.doc("users/6YZ8YPk1ZD1fg5i24MYn");
      DocumentReference<Map<String, dynamic>> scwwRef =
          _firestore.doc("users/eKTJ6dHsPQJ7lG98IG00");

      var _acwwSnapshot = (await transaction.get(acwwRef));
      var _acwwBakiye = _acwwSnapshot.data()!["para"];
      if (_acwwBakiye > 100) {
        var _yeniBakiye = _acwwSnapshot.data()!["para"] - 100;
        transaction.update(acwwRef, {"para": _yeniBakiye});
        transaction.update(scwwRef, {"para": FieldValue.increment(100)});
      }
    });
  }

  void queryingData() async {
    var _userRef =
        _firestore.collection("users"); //.limit(x) x kadar snuc getirir

    var _sonuc = await _userRef.where("renkler", arrayContains: "mavi").get();

    /*    for (var user in _sonuc.docs) {
      debugPrint(user.data().toString());
    } */

/*     var _sirala = await _userRef.orderBy("yas", descending: true).get();
    for (var user in _sirala.docs) {
      debugPrint(user.data().toString());
    } */

    var _stringSearch = await _userRef
        .orderBy("email")
        .startAt(["icww"]).endAt(["icww" + "\uf8ff"]).get();
    for (var user in _stringSearch.docs) {
      debugPrint(user.data().toString());
    }
  }

  void ImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    XFile? _file = await _picker.pickImage(source: ImageSource.gallery);
    var _profileRef = FirebaseStorage.instance.ref("users/profil_resimleri");
    var _task = _profileRef.putFile(File(_file!.path));

    _task.whenComplete(() async {
      var _url = await _profileRef.getDownloadURL();
      _firestore
          .doc("users/6YZ8YPk1ZD1fg5i24MYn")
          .set({"profile_pic": _url.toString()}, SetOptions(merge: true));
      debugPrint(_url);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Idler
    debugPrint(_firestore.collection("users").id);
    debugPrint(_firestore.collection("users").doc().id);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firestore Process"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                dataAdd();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
              ),
              child: const Text(
                "Data Add ",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                dataSet();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: const Text("data Set"),
            ),
            ElevatedButton(
              onPressed: () {
                dataUpdate();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: const Text("Data Update"),
            ),
            ElevatedButton(
              onPressed: () {
                dataDel();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              child: const Text("Data Delete"),
            ),
            ElevatedButton(
              onPressed: () {
                dataReadOneTime();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
              ),
              child: const Text("Data Read One Time"),
            ),
            ElevatedButton(
              onPressed: () {
                dataReadRealTime();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: const Text("Data Read Real Time"),
            ),
            ElevatedButton(
              onPressed: () {
                stopStream();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.pink,
              ),
              child: const Text("Stream Stopper"),
            ),
            ElevatedButton(
              onPressed: () {
                Batchdata();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.brown,
              ),
              child: const Text("Batch Data"),
            ),
            ElevatedButton(
              onPressed: () {
                transactionButton();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey,
              ),
              child: const Text("Transaction Button"),
            ),
            ElevatedButton(
              onPressed: () {
                queryingData();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: const Text("Data query"),
            ),
            ElevatedButton(
              onPressed: () {
                ImageUpload();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.brown,
              ),
              child: const Text("Image Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
