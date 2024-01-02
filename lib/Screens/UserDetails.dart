import 'package:flutter/material.dart';
class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(title: Text("Kullanıcı İşlemleri"),),
      body: Column(
        children: [
          Text("Kullanıcı detay"),
        ],


      ),
    );
  }
}
