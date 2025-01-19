import 'package:flutter/material.dart';

class InvitesListScreen extends StatefulWidget {

  final int mariageId; // ID du mariage en cours
  final String nomMariage; // Nom du mariage en cours

  const InvitesListScreen(
      {
        super.key,
        required this.mariageId,
        required this.nomMariage
      }
  );

  @override
  State<InvitesListScreen> createState() => _InvitesListScreenState();
}

class _InvitesListScreenState extends State<InvitesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomMariage),
        elevation: 1,
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: Text('Liste des invités du mariage ${widget.nomMariage}'),
      ),
    );
  }
}
