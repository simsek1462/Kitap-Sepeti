import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_project/Models/UsersAnswer.dart';
import 'package:my_flutter_project/Screens/Verify.dart';
import '../Models/Users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Home.dart';
class Register extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController = TextEditingController();
  TextEditingController? _surnameController = TextEditingController();
  TextEditingController? _emailController = TextEditingController();
  TextEditingController? _passwordController = TextEditingController();
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('users');
  final firebaseAuth = FirebaseAuth.instance;
  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return 'Lütfen adınızı girin';
    }
    return null;
  }

  String? _validateSurname(String? value) {
    if (value!.isEmpty) {
      return 'Lütfen soyadınızı girin';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Lütfen e-posta adresinizi girin';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'Lütfen şifrenizi girin';
    }
    return null;
  }

  Future<void> signUp(
      {required String name,
      required String surname,
      required String mail,
      required String password}) async {
      try{
        final UserCredential userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(email: mail, password: password);
        if (userCredential.user != null) {
            _registerUser(name, surname, mail, password);
            await userCredential.user?.sendEmailVerification();
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Verify()));
          }
    }on FirebaseAuthException catch(e){
        Fluttertoast.showToast(msg: e.message!);
      }
  }
  Future<void> _registerUser(
      String name, String surname, String mail, String password) async {
    await Firebase
        .initializeApp(); // Initialize Firebase app if not already initialized
    DatabaseReference _userRef =
        FirebaseDatabase.instance.reference().child('users');
    // Push user data to Firebase under a unique ID
    await _userRef.push().set({
      'name': name,
      'surname': surname,
      'mail': mail,
      'password': password,
      'role':'user',
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Üye Olun',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: _validateName,
                ),
                SizedBox(height: 18.0),
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Soyad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: _validateSurname,
                ),
                SizedBox(height: 18.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 18.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      signUp(name: _nameController!.text, surname: _surnameController!.text, mail: _emailController!.text, password: _passwordController!.text);
                    }
                  },
                  child: Text('Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
