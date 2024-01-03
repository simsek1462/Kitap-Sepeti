import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Models/Book.dart';
import 'Home.dart';

class KitapDetay extends StatelessWidget {
  final Book book;

  KitapDetay({required this.book});

  Future<void> addToCart(String bookId, String userId) async {
    DatabaseReference cartReference = FirebaseDatabase.instance.ref("cart");

    // Sepete ekleme işlemi için yeni bir key oluştur
    DatabaseReference newCartRef = cartReference.push();

    // Yeni bir 'cart item' oluştur
    try {
      await newCartRef.set({
        'bookId': bookId,
        'userId': userId,
        'adet': 1,
        // Ekstra bilgiler veya gereksinimlere göre diğer alanlar eklenebilir
      });
      Fluttertoast.showToast(
          msg: 'Başarıyla Eklendi',
          textColor: Colors.white,
          backgroundColor: Colors.green);
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  Future<void> addToFavorites(String bookId, String userId) async {
    DatabaseReference favoritesReference =
    FirebaseDatabase.instance.ref("favorites");

    DatabaseReference newFavoriteRef = favoritesReference.push();

    try {
      await newFavoriteRef.set({
        'bookId': bookId,
        'userId': userId,
      });
      Fluttertoast.showToast(
          msg: 'Favorilere Eklendi',
          textColor: Colors.white,
          backgroundColor: Colors.blue);
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'), // AppBar başlığı
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      book.imageUrl ?? '', // Kitap resmi
                      height: 300.0, // Resim yüksekliği
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title ?? 'No Title', // Kitap başlığı
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Yazar: ${book.author ?? 'Unknown'}', // Yazar
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Fiyat: ${book.price.toString()} TL', // Fiyat
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          User? user = FirebaseAuth.instance.currentUser;
                          addToCart(book.id.toString(), user!.uid);
                        },
                        child: Text('Sepete Ekle'), // Sepete ekle butonu
                      ),
                      SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            User? user = FirebaseAuth.instance.currentUser;
                            addToFavorites(book.id.toString(), user!.uid);
                          },
                          icon: Icon(Icons.favorite_border), // Favori ekleme ikonu
                          color: Colors.red, // Favori ikon rengi
                          iconSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            Text(
              'Açıklama:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  book.subject ?? 'No Description', // Kitap açıklaması
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
