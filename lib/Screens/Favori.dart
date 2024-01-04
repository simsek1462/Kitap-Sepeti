import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_flutter_project/Models/Favorite.dart';
import 'package:my_flutter_project/Screens/Sepet.dart';

import '../Models/Book.dart';
import '../Models/Cart.dart';
import 'Home.dart';
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
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref("favorites");
  Future<void> sil(String key) async {
    try {
      await refCarts.child(key).remove();
      print("Silme işlemi başarıyla gerçekleşti.");
    } catch (e) {
      print("Silme işlemi sırasında bir hata oluştu: $e");
    }
  }

  int _selectedIndex = 2; // Sepet ekranı, bottom navigation bar'da ikinci sırada olacak

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
        MaterialPageRoute(builder: (context) => UserDetails()), // Favori ekranına yönlendirme
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Book> bookList = [];
    List<Favorite> favorites = [];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text("Favoriler"),
          backgroundColor: Colors.blue, // App bar'ın rengi mavi
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Home()), // HomeScreen yerine gideceğiniz sayfa olmalı
              );
            },
          ),
        ),
        body: StreamBuilder(
          stream: databaseReference.orderByChild('userId').equalTo(id).onValue,
          builder: (context, snapshot) {
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
                favorites.add(
                    Favorite(key, currentMessage['userId'].toString(), bookId));
                DatabaseReference bookRef =
                FirebaseDatabase.instance.ref("books/$bookId");
                final bookSnapshot = await bookRef.once();
                if (bookSnapshot.snapshot.value != null) {
                  var gelenDegerler = bookSnapshot.snapshot.value as dynamic;
                  bookList.add(Book(
                    bookSnapshot.snapshot.key,
                    gelenDegerler['title'].toString(),
                    gelenDegerler['author'].toString(),
                    double.parse(gelenDegerler['price'].toString()),
                    gelenDegerler['subject'].toString(),
                    gelenDegerler['imageUrl'].toString(),
                  ));
                }
              });
              return FutureBuilder(
                future:
                databaseReference.orderByChild('userId').equalTo(id).once(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot == null) {
                    return Center(child: Text('Favori kitabınız yok.'));
                  } else {
                    return Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              reverse: false,
                              itemCount: bookList.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    leading:
                                    Image.network(bookList[index].imageUrl!),
                                    title: Text(bookList[index].title!),
                                    subtitle: Text(
                                        bookList[index].price.toString()),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () {
                                            sil(favorites[index].key);
                                            setState(() {
                                              bookList.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              return Center(
                child: Text("Sepetiniz boş."),
              );
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Eğer fazla öğe varsa bu kullanılabilir
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
