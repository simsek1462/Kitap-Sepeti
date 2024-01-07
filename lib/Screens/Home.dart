import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_flutter_project/Screens/KitapDetay.dart';
import 'package:my_flutter_project/Screens/Sepet.dart';
import 'package:my_flutter_project/Screens/UserDetails.dart';

import '../Models/Book.dart';
import 'Favori.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final databaseReference = FirebaseDatabase.instance.ref("books");
  final id = FirebaseAuth.instance.currentUser?.uid;
  bool aramaYapiliyorMu = false;

  String aramaKelimesi = "";

  Stream<List<Book>> getBookStream() {
    return databaseReference.child('books').onValue.map((event) {
      final books = <Book>[];
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          final bookData =
              value as Map<String, dynamic>; // Her bir kitap verisi
          final book = Book.fromJson(key, bookData);
          books.add(book);
        });
      }
      return books;
    });
  }

  Future<void> addToCart(Book book, String userId) async {
    DatabaseReference cartReference = FirebaseDatabase.instance.ref("cart");

    DatabaseReference newCartRef = cartReference.push();

    // Yeni bir 'cart item' oluştur
    await newCartRef.set({
      'bookId': book.id,
      'userId': userId,
      'title': book.title,
      'author': book.author,
      'url':book.imageUrl,
      'price':book.price,
      'content':book.subject,
    });
  }

  Future<void> addToFavorites(Book book, String userId) async {
    DatabaseReference favoritesReference =
        FirebaseDatabase.instance.ref("favorites");
    DatabaseReference newFavoriteRef = favoritesReference.push();

    await newFavoriteRef.set({
      'bookId': book.id,
      'userId': userId,
      'title': book.title,
      'author': book.author,
      'url':book.imageUrl,
      'price':book.price,
      'content':book.subject
    });
  }

  Widget buildBookContainer(BuildContext context, Book book) {
    bool isFavorite = false;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KitapDetay(book: book)),
        );
      },
      child: Card(
        margin: EdgeInsets.all(5),
        color: Colors.white,
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(book.imageUrl ?? ''),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    book.title ?? 'No Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    book.author ?? '',
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${book.price.toString()} TL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                          Fluttertoast.showToast(
                            msg: 'Favorilere eklendi',
                            textColor: Colors.redAccent,
                            backgroundColor: Colors.white,
                          );
                          addToFavorites(book, id.toString());
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(Icons.shopping_basket_outlined),
                          iconSize: 30,
                          color: Colors.lightBlueAccent,
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: 'Sepete eklendi',
                              backgroundColor: Colors.green,
                            );
                            addToCart(
                              book,
                              id.toString(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else if (_selectedIndex == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Sepet()),
      );
    } else if (_selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Favori()),
      );
    } else if (_selectedIndex == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDetails()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.blue,
          title: aramaYapiliyorMu
              ? TextField(
                  decoration:
                      InputDecoration(hintText: "Arama için birşey yazın"),
                  onChanged: (aramaSonucu) {
                    setState(() {
                      aramaKelimesi = aramaSonucu;
                    });
                  },
                )
              : Text(
                  "kitapsepeti",
                  style: TextStyle(color: Colors.white),
                ),
          actions: [
            aramaYapiliyorMu
                ? IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        aramaYapiliyorMu = false;
                        aramaKelimesi = "";
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        aramaYapiliyorMu = true;
                      });
                    },
                  ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                stream: databaseReference.onValue,
                builder: (context, snapshot) {
                  List<Book> bookList = [];
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      (snapshot.data! as DatabaseEvent).snapshot.value !=
                          null) {
                    final myMessages = Map<dynamic, dynamic>.from(
                        (snapshot.data! as DatabaseEvent).snapshot.value
                            as Map<dynamic, dynamic>);
                    myMessages.forEach((key, value) {
                      final currentMessage = Map<String, dynamic>.from(value);
                      if (aramaYapiliyorMu) {
                        if (currentMessage['title']
                            .toString()
                            .toLowerCase()
                            .contains(aramaKelimesi.toLowerCase())) {
                          bookList.add(Book(
                            key,
                            currentMessage['title'].toString(),
                            currentMessage['author'].toString(),
                            double.parse(currentMessage['price'].toString()),
                            currentMessage['subject'].toString(),
                            currentMessage['imageUrl'].toString(),
                          ));
                        }
                      } else {
                        bookList.add(Book(
                          key,
                          currentMessage['title'].toString(),
                          currentMessage['author'].toString(),
                          double.parse(currentMessage['price'].toString()),
                          currentMessage['subject'].toString(),
                          currentMessage['imageUrl'].toString(),
                        ));
                      }
                    });
                    return SizedBox(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: bookList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return buildBookContainer(context, bookList[index]);
                        },
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Say Hi...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w400),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType
              .fixed,
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Sepet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favori',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Kullanıcı',
            ),
          ],
        ),
      ),
    );
  }
}
