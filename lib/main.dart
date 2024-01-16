import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sven_app/list_of_devices.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'table_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'inClass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: const UserTablePage(),
    );
  }
}

class UserTablePage extends StatefulWidget {
  const UserTablePage({Key? key}) : super(key: key);

  @override
  _UserTablePageState createState() => _UserTablePageState();
}

Future<void> startBluetooth() async {
  await FlutterBluePlus.turnOn();
}

Future<void> stopScanning() async {
  await FlutterBluePlus.isScanning.where((val) => val == false).first;
}

class _UserTablePageState extends State<UserTablePage> {
  late Future<List<Album>> futureAlbums;

  List<BluetoothDevice> _bluetoothDevices = [];

  Future<void> startScanning(List<BluetoothDevice> devices) async {
    log("Starting scan");
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          setState(() {
            ScanResult r = results.last;
            for (r in results) {
              if (!devices.contains(r.device) && r.device.advName != "") {
                devices.add(r.device);
                _bluetoothDevices.add(r.device);
                log("Found device!");
                log(r.device.advName);
              }
            }
          });
        }
      },
      onError: (e) => print(e),
    );

    await stopScanning();
    log("Stopped scan!");
  }

  @override
  void initState() {
    super.initState();
    futureAlbums = fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Provide the path to your logo image
              height: 30, // Adjust the height as needed
            ),
            const SizedBox(width: 8),
            const Text('inClass'),
          ],
        ),
      ),
      body: Column(
        children: [
          // SizedBox(
          //   height: MediaQuery.of(context).size.height *
          //       0.35,
          //   child: Center(
          //     child: FutureBuilder<List<Album>>(
          //       future: futureAlbums,
          //       builder: (context, snapshot) {
          //         if (snapshot.hasData) {
          //           return UserTable(albums: snapshot.data!);
          //         } else if (snapshot.hasError) {
          //           return Text('${snapshot.error}');
          //         }

          //         return const CircularProgressIndicator();
          //       },
          //     ),
          //   ),
          // ),
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.75, // Adjust the height as needed
            child: BluetoothDevicesTable(devices: _bluetoothDevices),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      startBluetooth();
                    },
                    child: const Text('Turn On Bluetooth'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _bluetoothDevices.clear();
                      });
                      startScanning(_bluetoothDevices);
                    },
                    child: const Text('Start Scanning'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
