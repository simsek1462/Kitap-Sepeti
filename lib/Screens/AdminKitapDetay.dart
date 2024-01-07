import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Models/Book.dart';
import 'adminHome.dart';

class AdminKitapDetay extends StatefulWidget {
  final Book book;

  const AdminKitapDetay({Key? key, required this.book}) : super(key: key);

  @override
  _AdminKitapDetayState createState() => _AdminKitapDetayState();
}

class _AdminKitapDetayState extends State<AdminKitapDetay> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _priceController;
  late TextEditingController _subjectController;
  late TextEditingController _imageUrlController;
  final _formKey = GlobalKey<FormState>();

  var refKisiler = FirebaseDatabase.instance.ref().child("books");

  Future<void> guncelle(String author,String id,String title,String price,String subject,String imageUrl) async {
    var bilgi = HashMap<String,dynamic>();
    bilgi["author"] = author;
    bilgi["id"] = id;
    bilgi["title"] = title;
    bilgi["price"] = price;
    bilgi["subject"] = subject;
    bilgi["imageUrl"] = imageUrl;
    refKisiler.child(id).update(bilgi);
    Navigator.push(context, MaterialPageRoute(builder: (context) => adminHome()));
  }
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _subjectController = TextEditingController(text: widget.book.subject);
    _imageUrlController=TextEditingController(text: widget.book.imageUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _subjectController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kitap Detayları"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Başlık'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir başlık girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(labelText: 'Yazar'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir yazar adı girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Fiyat'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir fiyat girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(labelText: 'Konu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir konu girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir URL girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Güncelleme işlemleri burada yapılabilir
                      String updatedTitle = _titleController.text;
                      String updatedAuthor = _authorController.text;
                      double updatedPrice = double.parse(_priceController.text);
                      String updatedSubject = _subjectController.text;
                      String updatedUrl=_imageUrlController.text;
                      guncelle(updatedAuthor,widget.book.id.toString() , updatedTitle, updatedPrice.toString(), updatedSubject,updatedUrl);
                    }
                  },
                  child: Text('Güncelle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
