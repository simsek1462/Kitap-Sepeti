import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_flutter_project/Screens/KitapDetay.dart';
import 'package:my_flutter_project/Screens/Sepet.dart';
import 'package:my_flutter_project/Screens/UserDetails.dart';

import '../Models/Book.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final databaseReference = FirebaseDatabase.instance.ref("books");

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

  Future<void> addToCart(String bookId, String userId) async {
    DatabaseReference cartReference = FirebaseDatabase.instance.ref("cart");

    // Sepete ekleme işlemi için yeni bir key oluştur
    DatabaseReference newCartRef = cartReference.push();

    // Yeni bir 'cart item' oluştur
    await newCartRef.set({
      'bookId': bookId,
      'userId': userId,
      // Ekstra bilgiler veya gereksinimlere göre diğer alanlar eklenebilir
    });
  }

  Widget buildBookContainer(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => KitapDetay(book: book,)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5 -
            10, // Cihaz genişliğinin yarısından biraz az
        height: MediaQuery.of(context).size.height *
            0.50, // Cihaz yüksekliğinin 4'te biri
        margin: EdgeInsets.all(5), // Kenar boşlukları
        padding: EdgeInsets.all(8), // İçerik boşlukları
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Sınır çizgisi
          borderRadius: BorderRadius.circular(8), // Köşeleri yumuşat
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.network(
                  book.imageUrl ?? '', // Resim URL'si
                  width: 75,
                  height: 75,
                ),
              ],
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  book.title ?? 'No Title', // Kitabın başlığı
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  book.author ?? '', // Kitabın konusu
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${book.price.toString()}', // Kitabın fiyatı
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart), // Sepet ikonu
                  onPressed: () {
                    // Sepete ekleme işlemi
                    addToCart(
                      book.id.toString(), // Kitabın ID'si
                      'kullanici_idsi', // Kullanıcı ID'si (gerçek kullanıcı ID'si gelecek)
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    // setState ile _selectedIndex güncelleniyor
    setState(() {
      _selectedIndex = index;
    });

    // Hangi indekse tıklanıldığını kullanarak sayfaları yönlendirebilirsiniz
    // Örneğin:
    if (_selectedIndex == 0) {
      // İlk ikona tıklandıysa, Home sayfasına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()), // HomeScreen yerine gideceğiniz sayfa olmalı
      );
    } else if (_selectedIndex == 1) {
      // İkinci ikona tıklandıysa, Business sayfasına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Sepet()), // BusinessScreen yerine gideceğiniz sayfa olmalı
      );
    } else if (_selectedIndex == 2) {
      // Üçüncü ikona tıklandıysa, School sayfasına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDetails()), // SchoolScreen yerine gideceğiniz sayfa olmalı
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          title: aramaYapiliyorMu
              ? TextField(
                  decoration:
                      InputDecoration(hintText: "Arama için birşey yazın"),
                  onChanged: (aramaSonucu) {
                    print("Arama sonucu : $aramaSonucu");
                    setState(() {
                      aramaKelimesi = aramaSonucu;
                    });
                  },
                )
              : Text("Shopping Book"),
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
                            as Map<dynamic, dynamic>); //typecasting
                    myMessages.forEach((key, value) {
                      final currentMessage = Map<String, dynamic>.from(value);
                      print(currentMessage);
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
                        print(bookList.first.title.toString());
                      }
                    });
                    return SizedBox(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 sütunlu grid
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: bookList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return buildBookContainer(context, bookList[index]);
                          },
                        ));
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
              icon: Icon(Icons.person),
              label: 'Kullanıcı',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueGrey,
          onTap: _onItemTapped,
        )));




  }
}
