  import 'package:firebase_database/firebase_database.dart';
  import 'package:flutter/material.dart';

  import '../Models/Book.dart';
  import 'AdminKitapDetay.dart';
import 'KitapEkle.dart';
  class adminHome extends StatefulWidget {
    const adminHome({super.key});

    @override
    State<adminHome> createState() => _adminHomeState();
  }

  class _adminHomeState extends State<adminHome> {
    final databaseReference = FirebaseDatabase.instance.ref("books");
    bool aramaYapiliyorMu = false;
    String aramaKelimesi = "";
    @override
    Widget build(BuildContext context) {
      return  Scaffold(
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
              : Text("kitapsepeti",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),),
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
                      child: ListView.builder(
                        itemCount: bookList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AdminKitapDetay(book: bookList[index],)),
                              );
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Resim
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.network(
                                        bookList[index].imageUrl ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    // Metinler
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            bookList[index].title.toString(),
                                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                                          ),
                                          Text(bookList[index].author.toString(),style: TextStyle(fontSize: 15),),
                                          Text("${bookList[index].price.toString()} TL"),
                                        ],
                                      ),
                                    ),
                                    // Silme ikonu
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.black54),
                                      onPressed: () {
                                        // Silme işlevini buraya ekleyebilirsiniz.
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KitapEkle()),
            );
          },
          child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
