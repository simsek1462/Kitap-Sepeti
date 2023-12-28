import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/Book.dart'; // Yukarıda oluşturduğumuz Book sınıfı

class KitapEkle extends StatefulWidget {
  @override
  _KitapEkle createState() => _KitapEkle();
}

class _KitapEkle extends State<KitapEkle> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _priceController;
  late TextEditingController _subjectController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _priceController = TextEditingController();
    _subjectController = TextEditingController();
    _imageUrlController = TextEditingController();
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
      appBar: AppBar(title: Text('Kitap Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Kitap adı'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(labelText: 'Kitabın yazarı'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Fiyatı'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(labelText: 'Konusu'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(labelText: 'URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form geçerli, verileri Firebase Realtime Database'e kaydet
                      _saveBook();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveBook() {
    String title = _titleController.text;
    String author = _authorController.text;
    double price = double.parse(_priceController.text);
    String subject = _subjectController.text;
    String imageUrl = _imageUrlController.text;

    Book newBook = Book(
      "",
      title,
      author,
      price,
      subject,
      imageUrl,
    );

    DatabaseReference booksRef = FirebaseDatabase.instance.reference().child('books');
    booksRef.push().set(newBook.toJson());

    // Kayıt yapıldıktan sonra formu temizle
    _titleController.clear();
    _authorController.clear();
    _priceController.clear();
    _subjectController.clear();
    _imageUrlController.clear();
  }
}
