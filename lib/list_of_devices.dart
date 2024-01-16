// bluetooth_table.dart
import 'dart:convert';
import 'dart:developer';
import "dart:async";
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDevicesTable extends StatefulWidget {
  final List<BluetoothDevice> devices;

  const BluetoothDevicesTable({Key? key, required this.devices})
      : super(key: key);

  @override
  _BluetoothDevicesTableState createState() => _BluetoothDevicesTableState();
}

class _BluetoothDevicesTableState extends State<BluetoothDevicesTable> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Guid characteristicUuid = Guid("aac111b6-9d28-4785-98b4-d6c872de03d5");
  void _connectToDevice(BluetoothDevice device) async {
    if (!device.isConnected) {
      await device.connect(timeout: Duration(minutes: 10));
    }

    setState(() {});

    _showPopup(device);
  }

  Future<void> _showPopup(BluetoothDevice device) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            textAlign: TextAlign.center, "Enter your username and password"),
        content: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String username = _usernameController.text;
              String password = _passwordController.text;

              writeData(username, password, device);

              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> writeData(
      String username, String password, BluetoothDevice device) async {
    String loginData = username + " " + password;
    List<int> loginDataHex = utf8.encode(loginData);

    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.characteristicUuid == characteristicUuid) {
          try {
            await c.write(loginDataHex);
            _waitForResponse(c);
          } catch (e) {
            log("Error writing: $e");
          }
        }
      }
    });
  }

  void _waitForResponse(BluetoothCharacteristic characteristic) async {
    int flag = 0;

    List<int> valueAfterWaiting = await characteristic.read();

    log("procitano: $valueAfterWaiting");

    log(valueAfterWaiting.toString());

    String valueAfterWaitingConverted = valueAfterWaiting.toString();

    if (valueAfterWaitingConverted == [0, 0, 0, 0].toString()) {
      log("Login uspješan");
    } else if (valueAfterWaitingConverted == [1, 0, 0, 0].toString()) {
      log("Login neuspješan");
      flag = 1;
    } else if (valueAfterWaitingConverted == [2, 0, 0, 0].toString()) {
      log("Već si logiran");
      flag = 2;
    } else {
      log("Nešto je pošlo po krivu");
      flag = -1;
    }
    _showEndingPopup(flag);
  }

  void _showEndingPopup(int flag) {
    String message = "";
    if (flag == 0) {
      message = "Prijava uspješna";
    } else if (flag == 1) {
      message = "Prijava neuspješna, probajte opet!";
    } else if (flag == 2) {
      message = "Već ste prijavljeni!";
    } else {
      message = "Nepoznati error";
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
            child: ListTile(
          leading: Icon(Icons.login),
          title: Text(message),
          onTap: () {
            Navigator.pop(context);
          },
        ));
      },
    );
  }

  void _showMenu(BluetoothDevice device) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Connect'),
                onTap: () {
                  _connectToDevice(device);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Device Name')),
          DataColumn(label: Text("ID")),
          DataColumn(label: Text("Connect")),
          DataColumn(label: Text("Connected?"))
        ],
        rows: widget.devices
            .map(
              (device) => DataRow(
                cells: [
                  DataCell(
                    Text(device.platformName),
                  ),
                  DataCell(Text(device.remoteId.str)),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.bluetooth_connected_sharp),
                      onPressed: () {
                        _showMenu(device);
                      },
                    ),
                  ),
                  DataCell(Text(device.isConnected.toString()))
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
