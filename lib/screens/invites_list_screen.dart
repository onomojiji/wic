import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:wic/screens/qr_code_view_screen.dart';
import '../helpers/database_helper.dart';

class InvitesListScreen extends StatefulWidget {
  final int mariageId; // ID du mariage
  final String nomMariage; // Nom du mariage

  const InvitesListScreen({
    super.key,
    required this.mariageId,
    required this.nomMariage,
  });

  @override
  State<InvitesListScreen> createState() => _InvitesListScreenState();
}

class _InvitesListScreenState extends State<InvitesListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _invites = [];

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  /// Charger la liste des invités depuis la base locale
  Future<void> _loadInvites() async {
    final invites = await _dbHelper.getInvites(widget.mariageId);
    setState(() {
      _invites = invites;
    });
  }

  /// Importer des invités depuis un fichier Excel
  Future<void> _importInvites() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Traiter chaque ligne du fichier Excel
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) {
          final String nom = "${row[0]?.value}";
          final String prenom = "${row[1]?.value}";
          final String qrCode = "${row[2]?.value}";

          // Vérifier si l'invité existe déjà
          final existingInvite = await _dbHelper.getInviteByQRCode(qrCode);
          if (existingInvite != null) {
            await _handleDuplicateInvite(existingInvite, {
              'mariageId': widget.mariageId,
              'nom': nom,
              'prenom': prenom,
              'qrCode': qrCode,
            });
          } else {
            // Ajouter un nouvel invité
            await _dbHelper.insertInvite({
              'mariageId': widget.mariageId,
              'nom': nom,
              'prenom': prenom,
              'qrCode': qrCode,
            });
          }
        }
      }

      // Recharger la liste des invités après l'importation
      _loadInvites();
    }
  }

  /// Gestion des doublons : Afficher une boîte de dialogue pour demander confirmation
  Future<void> _handleDuplicateInvite(
      Map<String, dynamic> existingInvite,
      Map<String, dynamic> newInvite,
      ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invité déjà existant'),
          content: Text(
            'L\'invité ${existingInvite['nom']} ${existingInvite['prenom']} existe déjà.\n'
                'Voulez-vous écraser ses informations ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Ignorer
              child: Text('Ignorer'),
            ),
            TextButton(
              onPressed: () async {
                // Écraser les informations existantes
                await _dbHelper.updateInvite(existingInvite['id'], newInvite);
                Navigator.pop(context);
              },
              child: Text('Écraser'),
            ),
          ],
        );
      },
    );
  }

  /// Scanner un QR code et valider la présence
  Future<void> _scanQRCode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRViewScreen(
          onQRCodeScanned: (qrCode) async {
            final invite = await _dbHelper.getInviteByQRCode(qrCode);
            if (invite != null) {
              // Marquer l'invité comme présent
              await _dbHelper.updatePresence(invite['id'], 'présent');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Présence validée pour ${invite['nom']} ${invite['prenom']}')),
              );
              _loadInvites(); // Recharger la liste
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('QR Code non reconnu')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomMariage),
        elevation: 1,
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importInvites,
          ),
        ],
      ),
      body: Expanded(
        child: _invites.isEmpty
            ? Center(
          child: Text('Aucun invité trouvé. Importez-en pour commencer !'),
        )
            : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    '${_invites.length} invités',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                            itemCount: _invites.length,
                            itemBuilder: (context, index) {
                  final invite = _invites[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ListTile(
                      title: Text('${invite['nom']} ${invite['prenom']}'),
                      subtitle: Text('QR Code : ${invite['qrCode']}'),
                      trailing: invite['presence'] == 'présent'
                          ? Icon(Icons.rectangle, color: Colors.green)
                          : Icon(Icons.rectangle, color: Colors.grey),
                    ),
                  );
                            },
                          ),
                ),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        backgroundColor: Colors.blue,
        child: Icon(Icons.qr_code, color: Colors.white),
      ),
    );
  }
}
