import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_flutter_project/Models/Favorite.dart';
import 'package:my_flutter_project/Screens/Sepet.dart';

import '../Models/Book.dart';
import '../Models/Cart.dart';
import 'Home.dart';
import 'KitapDetay.dart';
import 'UserDetails.dart';
import 'Favori.dart'; // Favori ekranı import edilmeli

class Favori extends StatefulWidget {
  Favori({Key? key});

  @override
  State<Favori> createState() => _FavoriState();
}

class _FavoriState extends State<Favori> {
  final id = FirebaseAuth.instance.currentUser?.uid;
  var refCarts = FirebaseDatabase.instance.ref().child("favorites");
  final databaseReference = FirebaseDatabase.instance.ref("favorites");
  Future<void> sil(String key) async {
    try {
      await refCarts.child(key).remove();
      print("Silme işlemi başarıyla gerçekleşti.");
    } catch (e) {
      print("Silme işlemi sırasında bir hata oluştu: $e");
    }
  }

  int _selectedIndex = 2;

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
    } else if (_selectedIndex == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDetails()),
      );
    }
  }

  Future<void> addToCart(Book book, String userId) async {
    DatabaseReference cartReference = FirebaseDatabase.instance.ref("cart");

    DatabaseReference newCartRef = cartReference.push();

    await newCartRef.set({
      'bookId': book.id,
      'userId': userId,
      'title': book.title,
      'author': book.author,
      'url': book.imageUrl,
      'price': book.price,
      'content': book.subject,
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Book> bookList = [];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:Colors.blue,
          title: Text("Favoriler"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
          ),
        ),
        body: Container(
          color: Colors.blue,
          child: StreamBuilder(
            stream: databaseReference.orderByChild('userId').equalTo(id).onValue,
            builder: (context, snapshot) {
              List<Favorite> favorites = [];
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  (snapshot.data! as DatabaseEvent).snapshot.value != null) {
                final myMessages = Map<dynamic, dynamic>.from(
                  (snapshot.data! as DatabaseEvent).snapshot.value
                      as Map<dynamic, dynamic>,
                );
                myMessages.forEach((key, value) async {
                  final currentMessage = Map<String, dynamic>.from(value);
                  var bookId = currentMessage['bookId'];
                  favorites.add(Favorite(
                      key.toString(),
                      currentMessage['userId'].toString(),
                      bookId,
                      currentMessage['title'].toString(),
                      currentMessage['author'].toString(),
                      currentMessage['url'].toString(),
                      currentMessage['price'].toString(),
                      currentMessage['content'].toString()));
                });
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          reverse: false,
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Book book = Book(
                                    favorites[index].bookId,
                                    favorites[index].title,
                                    favorites[index].author,
                                    double.parse(favorites[index].price),
                                    favorites[index].content,
                                    favorites[index].url);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          KitapDetay(book: book)),
                                );
                              },
                              child: Card(
                                child: ListTile(
                                  leading: Image.network(favorites[index].url!),
                                  title: Text(
                                    favorites[index].title!,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${favorites[index].price.toString()} TL',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        color: Colors.red,
                                        onPressed: () {
                                          sil(favorites[index].key);
                                        },
                                      ),
                                      IconButton(
                                        icon:
                                            Icon(Icons.shopping_basket_outlined),
                                        iconSize: 30,
                                        color: Colors.lightBlueAccent,
                                        onPressed: () {
                                          Book book = Book(
                                              favorites[index].bookId,
                                              favorites[index].title,
                                              favorites[index].author,
                                              double.parse(favorites[index].price),
                                              favorites[index].content,
                                              favorites[index].url);
                                          addToCart(
                                            book,
                                            id.toString(),
                                          );
                                          Fluttertoast.showToast(
                                            msg: 'Sepete eklendi',
                                            backgroundColor: Colors.green,
                                          );

                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text("Favori ürün yok"),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
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
