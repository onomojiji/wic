import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewScreen extends StatefulWidget {
  final Function(String) onQRCodeScanned;

  const QRViewScreen({required this.onQRCodeScanned, Key? key}) : super(key: key);

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  //QRViewController? controller;

  @override
  /*void dispose() {
    controller?.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner QR Code')),
      /*body: QRView(
        key: qrKey,
        onQRViewCreated: (controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) {
            widget.onQRCodeScanned(scanData.code);
            Navigator.pop(context); // Retourner à l'écran précédent
          });
        },
      ),*/
    );
  }
}
