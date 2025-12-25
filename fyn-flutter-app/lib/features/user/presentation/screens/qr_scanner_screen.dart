import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/dating_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isDisposed) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        // Handle both production URL (fyn.app/u/) and local URL (localhost:3000/#/u/)
        String? userId;
        if (code.contains('fyn.app/u/')) {
          userId = code.split('fyn.app/u/').last.split('?').first;
        } else if (code.contains('/u/')) {
          // For localhost or any domain with /u/ path
          userId = code.split('/u/').last.split('?').first;
        }
        
        if (userId != null && userId.isNotEmpty) {
          _navigateToProfile(userId);
          break;
        }
      }
    }
  }

  void _navigateToProfile(String userId) {
    if (_isDisposed) return;
    
    // Stop scanning
    controller.stop();
    
    // Navigate using go_router - use /u/ route which is the deeplink route
    context.push('/u/$userId').then((_) {
      // Resume scanning if we return
      if (!_isDisposed) {
        controller.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                  case TorchState.auto:
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: controller,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Custom Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: DatingColors.rose, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Căn chỉnh mã QR vào khung để quét',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
