
import 'package:flutter/gestures.dart';
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

  bool _mailError = false;
  bool _passwordError = false;
  bool _isObscure = true;
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
      Fluttertoast.showToast(msg: 'Lütfen giriş bilgilerinizi kontrol edin.',backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color:Colors.black,
                child: Image(
                  image: AssetImage("lib/assets/images/Kitap.png"),
                  width: 300,
                  height:300,
                ),
              ),
              TextFormField(
                controller: _mailController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  errorText: _mailError ? 'This field cannot be empty' : null,
                ),
                onChanged:(value){
                  setState(() {
                    _mailError = false;
                  });
                }
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  errorText: _passwordError ? 'This field cannot be empty' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                  onChanged:(value){
                    setState(() {
                      _passwordError = false;
                    });
                  }
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _mailError = _mailController.text.isEmpty;
                        _passwordError = _passwordController.text.isEmpty;
                      });
                      signIn(mail: _mailController.text, password: _passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Buton rengi
                      padding: EdgeInsets.symmetric(horizontal: 100), // Buton genişliği
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Köşe yuvarlatma
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      _handleSignIn(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color:Colors.white,
                              child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/36px-Google_%22G%22_logo.svg.png', // Google logosunun yer aldığı dosya yolu
                                height: 20,
                                width: 20,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Sign In with Google'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Üye Değil misin? ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Üye Ol',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Register()));
                            },
                        ),
                      ],
                    ),
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
