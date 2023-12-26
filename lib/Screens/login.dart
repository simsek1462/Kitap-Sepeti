
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_flutter_project/Screens/Register.dart';
import 'package:my_flutter_project/Screens/adminHome.dart';
import 'Home.dart';
class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');
  TextEditingController _mailController=TextEditingController();
  TextEditingController _passwordController=TextEditingController();
  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Firebase Authentication'dan kullanıcı başarıyla alındı
          // Kullanıcıyı Realtime Database'de kontrol et ve gerekli işlemleri yap
          await _checkUserInDatabase(user);

          // Kullanıcıya bağlı olarak yönlendirme yap
          final ref = FirebaseDatabase.instance.ref();
          final snapshot = await ref.child('users/${user.uid}/role').get();
          if (snapshot.exists) {
            String userRole = snapshot.value.toString();
            print(userRole);
            // Rol kontrolü ve yönlendirme
            if (userRole == 'admin') {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=> adminHome()));
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Home()));
            }
          }
        }
      }
    }on FirebaseAuthException catch(e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }
  Future<void> _checkUserInDatabase(User user) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child(user.uid).once();
    if (snapshot.snapshot.exists) {
      // Kullanıcı veritabanında yok, bilgileri kaydet
      await _userRef.child(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'role':'user',
      });
    }
  }
  Future<void> signIn({required String mail,required String password}) async{
    try{
      final UserCredential userCredential= await _auth.signInWithEmailAndPassword(email: mail, password: password);
      if(userCredential.user!=null)
      {
        if(userCredential.user!.emailVerified){

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
        else{
          Fluttertoast.showToast(msg: "Lütfen Hesabınızı doğrulayın",backgroundColor: Colors.red);
        }
      }
    } on FirebaseAuthException catch (e){
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("LOG IN",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 25,color: Colors.grey),),
              SizedBox(height: 50,),
              TextFormField(
                controller: _mailController,
                decoration:InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: _passwordController,
                decoration:InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      signIn(mail: _mailController.text, password: _passwordController.text);
                    },
                    child: Text('Sign In'),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleSignIn(context),
                    child: Text('Google ile Giriş Yap'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Register()));
                    },
                    child: Text('Üye Ol'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
