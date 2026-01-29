import 'package:flutter/material.dart';
import 'package:idn_pos/screens/scanner/components/payment_modal.dart';
import 'package:idn_pos/screens/scanner/components/scanner_header.dart';
import 'package:idn_pos/screens/scanner/components/scanner_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, //untuk membuat detection speed nya tanpa delay
    returnImage: false,
  );

  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        //widget stack untuk menumpuk widget
        children: [
          //camera scanner
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              //kondisi dimana kamera scanner sedang detect (status),
              if (_isScanned) return;
              //kondisi yang ada di perulangan for adalah kondisi ketika QR Code sudah berhasil ditangkap oleh kamera
              for (final barcode in capture.barcodes) {
                //men detect sebuah barcode yang ada di dalem kamera yang sedang scanning
                _handleQRCode(barcode.rawValue);
              }
            }
          ),

          ScannerOverlay(),
          ScannerHeader(controller: controller)
        ],
      ),
    );
  }

  void _handleQRCode(String? code) {
    if (code != null) {
      if (code.startsWith("PAY:")) {
        //QR Code Valid
        setState(() {
          _isScanned = true;

          final parts = code.split(":");
          final id = parts[1];
          final total = int.tryParse(parts[2]) ?? 0;

          _showPaymentModal(id, total);
        });
      } else {
        //QR Tidak Valid
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text("QR Tidak Dikenali $code", overflow: TextOverflow.ellipsis)), 
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 10),
          )
        );
      }
    }
  }

  void _showPaymentModal(String id, int total) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (paymentContext) => PaymentModal(
        id: id,
        total: total,
        onPay: () {
          Navigator.pop(paymentContext);
          Navigator.pop(paymentContext);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Pembayaran Berhasil"),
              backgroundColor: Colors.green,
            )
          );
        },
        onCancel: () {
          Navigator.pop(paymentContext);
          setState(() {
            _isScanned = false; //untuk meriset state biar bisa di scan lagi dari awal
          });
        },
      )
    ).then((_) {
      if (_isScanned) setState(() => _isScanned = false);
    });
  }
}