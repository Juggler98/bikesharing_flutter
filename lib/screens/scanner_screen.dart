import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bikesharing/widgets/code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class ScannerScreen extends StatelessWidget {
  ScannerScreen({Key? key}) : super(key: key);

  final cameraController = MobileScannerController();

  void _openDialog(String? id, BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.QUESTION,
      animType: AnimType.BOTTOMSLIDE,
      headerAnimationLoop: false,
      body: Text('Odomknúť bicykel $id?'),
      btnOkText: 'Áno',
      btnOkOnPress: () {
        // Ride ride = Ride(
        //     id: Random().nextInt(100).toString(),
        //     startDate: DateTime.now(),
        //     locationStart: stand.location,
        //     vehicleType: VehicleType.bike);
        Fluttertoast.showToast(
          msg: 'Bicykel bol odomknutý',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.black54,
        );
        Navigator.of(context).pop();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Skener'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state as CameraFacing) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
                allowDuplicates: false,
                controller: cameraController,
                onDetect: (c, args) {
                  if (c.rawValue != null) {
                    var code = c.rawValue!;
                    final myUri = Uri.parse(code);
                    if (code.contains('bikesharingf3e11.page.link')) {
                      url.launchUrl(myUri,
                          mode: url.LaunchMode.externalApplication);
                      Navigator.of(context).pop(code);
                    }
                  }
                }),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) =>
                          CodeDialog(context, ctx, true, 'Zadaj kód'),
                    ).then((value) {
                      if (value != null) {
                        _openDialog(value, context);
                      }
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black45),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 42.0, vertical: 12.0)),
                  ),
                  child: const Text(
                    'Zadať kód',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
