import 'package:flutter/material.dart';
import 'package:wic/screens/create_mariage_screen.dart';
import 'package:wic/screens/invites_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'wic',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/create-mariage': (context) => CreateMariageScreen(userId: 1), // Exemple avec un userId
        '/login': (context) => LoginScreen(), // Exemple avec un mariageId et un nomMariage
        '/invites-list': (context) => InvitesListScreen(mariageId: 1, nomMariage: 'Mariage de test'), // Exemple avec un mariageId et un nomMariage
      },
    );
  }
}
