import 'package:flutter/material.dart';

import 'KitapEkle.dart';
class adminHome extends StatelessWidget {
  const adminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Admin Panel",style: TextStyle(fontSize: 25,color: Colors.green,fontWeight: FontWeight.w700
              ),
            ),
          ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> KitapEkle()));
              }, child: const Text("Kitap Ekle")),
      const SizedBox(
        height: 50,
      ),
          ],
        ),
      ),
    );
  }
}
