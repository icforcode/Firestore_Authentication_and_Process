// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseflttr/firestore_islemleri.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirestoreIslemleri(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseAuth auth;
  final String _email = "agadgadgadg@gmail.com";
  final String _password = "abcdefg";
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('************User oturumu kapalı');
      } else {
        debugPrint(
            '****************User oturum acık ${user.email} ve verify${user.emailVerified}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                createUserEmailAndPassword();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              child: const Text("Email/Sifre Kayıt"),
            ),
            ElevatedButton(
              onPressed: () {
                loginUserEmailAndPassword();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: const Text("Email/Sifre Giris"),
            ),
            ElevatedButton(
              onPressed: () {
                signOutUser();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
              ),
              child: const Text("oturumu kapat"),
            ),
            ElevatedButton(
              onPressed: () {
                deleteUser();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: const Text("kullanıcıyı sıl"),
            ),
            ElevatedButton(
              onPressed: () {
                changePasswordUser();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.brown,
              ),
              child: const Text("parola değiştir"),
            ),
            ElevatedButton(
              onPressed: () {
                changeEmailUser();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              child: const Text("email değiştir"),
            ),
            ElevatedButton(
              onPressed: () {
                googleGirisUser();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.pink,
              ),
              child: const Text("google"),
            ),
            ElevatedButton(
              onPressed: () {
                loginWithPhoneUser();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.amber,
              ),
              child: const Text("Tel no ile giris"),
            ),
          ],
        ),
      ),
    );
  }

  void createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);

      var _myUser = _userCredential.user;
      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        debugPrint("***************user maili onaylanmış,girişe izin verildi");
      }

      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signOutUser() async {
    var _user = GoogleSignIn().currentUser;
    if (_user != null) {
      await GoogleSignIn().signOut();
    }
    await auth.signOut();
  }

  void deleteUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
      debugPrint("***********User deleted");
    } else {
      debugPrint("***********Oturum acın");
    }
  }

  void changePasswordUser() async {
    try {
      await auth.currentUser!.updatePassword("abcdefg");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        debugPrint("***********reauthenticate olucak");
        await auth.currentUser!.updatePassword("yenisifre");
        await auth.signOut();
        debugPrint("***********password updated");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeEmailUser() async {
    try {
      await auth.currentUser!.updateEmail("dagadgadgadg@gmail.com");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        debugPrint("***********reauthenticate olucak");
        await auth.currentUser!.updatePassword("dgasdfgadsgda@gmail.com");
        await auth.signOut();
        debugPrint("***********email updated");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void googleGirisUser() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void loginWithPhoneUser() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+905366350000',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint("*****************verifying");
        debugPrint(credential.toString());
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.toString());
        debugPrint("*****************kod yanlıs");
      },
      codeSent: (String verificationId, int? resendToken) async {
        String _smsCode = "123456";
        debugPrint("*****************code sending");
        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smsCode);
        await auth.signInWithCredential(_credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint("*****************code 30sn auto retrival  timeout");
      },
    );
  }
}
