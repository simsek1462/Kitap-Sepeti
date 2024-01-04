import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../Models/Book.dart';
import '../Models/Cart.dart';
import 'Home.dart';
import 'UserDetails.dart';
import 'Favori.dart'; // Favori ekranı import edilmeli

class Sepet extends StatefulWidget {
  Sepet({Key? key});

  @override
  State<Sepet> createState() => _SepetState();
}

class _SepetState extends State<Sepet> {
  final id = FirebaseAuth.instance.currentUser?.uid;
  var refCarts = FirebaseDatabase.instance.ref().child("cart");
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref("cart");
  Future<void> sil(String key) async {
    await databaseReference.child(key).remove();
  }

  int _selectedIndex =
  1; // Sepet ekranı, bottom navigation bar'da ikinci sırada olacak

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else if (_selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Favori()),
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
    List<Cart> cartList = [];
    List<int> quantities = [];

    String calculateTotalPrice(List<Book> bookList) {
      double totalPrice = 0;
      // Tüm kitapların fiyatını topla
      for (var book in bookList) {
        totalPrice += book.price!;
      }
      // Toplam fiyatı string olarak döndür
      return totalPrice
          .toStringAsFixed(2); // Virgülden sonra 2 basamak göstermek için
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text("Sepet"),
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
                cartList.add(
                    Cart(key, currentMessage['userId'].toString(), bookId));
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
                quantities = List.generate(bookList.length, (index) => 1);
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
                    return Center(child: Text('Sepetiniz boş.'));
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
                                            setState(() {
                                             sil(cartList[index].key);
                                             bookList.removeAt(index);
                                            });
                                          },
                                        ),
                                        Text(quantities[index]
                                            .toString()), // Adet sayısını göstermek için metin
                                        IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              quantities[index]++; // Arttırma işlemi
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
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Toplam: ${calculateTotalPrice(bookList)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // Ödeme işlemi
                                    // Burada ödeme işlemleri veya yönlendirme yapılabilir
                                  },
                                  child: Text('Ödemeyi Tamamla'),
                                ),
                              ],
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
