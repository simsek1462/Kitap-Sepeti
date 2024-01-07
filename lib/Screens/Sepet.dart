import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Models/Book.dart';
import '../Models/Cart.dart';
import '../Screens/Home.dart';
import '../Screens/KitapDetay.dart';
import '../Screens/UserDetails.dart';
import '../Screens/Favori.dart'; // Favori ekranı import edilmeli

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
  String calculateTotalPrice(List<Cart> cartList) {
    double totalPrice = 0;
    for (var cart in cartList) {
      totalPrice += double.parse(cart.price!);
    }
    return totalPrice.toStringAsFixed(2);
  }
  Future<void> completeOrder(List<Cart> cartList) async {
    var orderReference = FirebaseDatabase.instance.ref("orders");
    var totalPrice = calculateTotalPrice(cartList);

    var orderKey = orderReference.push().key;

    await orderReference.child(orderKey!).set({
      'userId': id,
      'orderDate': DateTime.now().toString(),
      'totalPrice': totalPrice,
      'items': cartList.map((cart) {
        return {
          'bookId': cart.bookId,
          'title': cart.title,
          'author': cart.author,
          'url': cart.url,
          'price': cart.price,
          'content': cart.content,
          // Diğer bilgiler...
        };
      }).toList(),
    });

    // Cartları sil
    for (var cart in cartList) {
      await databaseReference.child(cart.key).remove();
    }
  }

  Future<void> increaseCartItem(Cart cartItem) async {
    var snapshot = await databaseReference
        .orderByChild('bookId')
        .equalTo(cartItem.bookId)
        .once();

    if (snapshot.snapshot.value != null) {
      var values = snapshot.snapshot.value as Map<dynamic, dynamic>;
      var keys = values.keys.toList();
      var vals = values.values.toList();

      if (keys.isNotEmpty && vals.isNotEmpty) {
        var key = keys[0];
        var val = vals[0];

        var updatedQuantity = int.parse(val['quantity'].toString()) + 1;
        await databaseReference.child(key).update({'quantity': updatedQuantity});
      }
    } else {
      await databaseReference.push().set({
        'bookId': cartItem.bookId,
        'userId': cartItem.userId,
        'title': cartItem.title,
        'author': cartItem.author,
        'url': cartItem.url,
        'price': cartItem.price,
        'content': cartItem.content,
        'quantity': 1, // Yeni ürün, adet = 1
      });
    }
  }


  int _selectedIndex = 1;

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
        MaterialPageRoute(
          builder: (context) => UserDetails(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text("Sepet"),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
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
              List<Cart> cartList = [];
              myMessages.forEach((key, value) async {
                final currentMessage = Map<String, dynamic>.from(value);
                var bookId = currentMessage['bookId'];
                cartList.add(Cart(
                  key,
                  currentMessage['userId'].toString(),
                  bookId,
                  currentMessage['title'].toString(),
                  currentMessage['author'].toString(),
                  currentMessage['url'].toString(),
                  currentMessage['price'].toString(),
                    currentMessage['content'].toString()
                ));
              });
              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: false,
                        itemCount: cartList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Book book = Book(
                                  cartList[index].bookId,
                                  cartList[index].title,
                                  cartList[index].author,
                                  double.parse(cartList[index].price),
                                  cartList[index].content,
                                  cartList[index].url);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        KitapDetay(book: book)),
                              );
                            },
                            child: Card(
                              child: ListTile(
                                leading: Image.network(cartList[index].url!),
                                title: Text(cartList[index].title!),
                                subtitle: Text(cartList[index].price.toString()),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          sil(cartList[index].key);
                                          cartList.removeAt(index);
                                        });
                                      },
                                    ),
                                    Text(
                                      '1',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                        });
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
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Toplam: ${calculateTotalPrice(cartList)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Fluttertoast.showToast(
                                msg: 'Sipariş oluşturuldu',
                                backgroundColor: Colors.green,
                              );
                              var duration = const Duration(seconds: 2);
                              sleep(duration);
                              completeOrder(cartList);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Home()),
                              );
                            },
                            child: Text('Ödemeyi Tamamla'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text("Sepetiniz boş."),
              );
            }
          },
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
