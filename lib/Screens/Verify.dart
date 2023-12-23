import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_project/Screens/Login.dart';

class Verify extends StatefulWidget {
  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    _redirectAfterDelay();
  }

  void _checkEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      try {
        if (user.emailVerified) {
          _navigateToLogin();
        }
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: e.message!);
      }
    }
  }

  void _redirectAfterDelay() {
    Future.delayed(Duration(seconds: 5), () {
      _navigateToLogin();
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-posta Doğrulama'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('E-postanızı doğrulayın.'),
            CircularProgressIndicator(), // Circular progress indicator
          ],
        ),
      ),
    );
  }
}
