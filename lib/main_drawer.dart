import 'dart:async';
import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models/auth.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/history/history_screen.dart';
import 'package:http/http.dart' as http;

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 110,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomLeft,
              color: Colors.green,
              child: const Text(
                'Bikesharing',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(
                Icons.history,
                color: Colors.black54,
              ),
              title: const Text('História jázd'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => HistoryScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.outlined_flag,
                color: Colors.black54,
              ),
              title: const Text('Nahlásiť problém'),
              onTap: () async {
                final textFields = [
                  const DialogTextField(hintText: 'ID bicykla'),
                ];
                final result = await showTextInputDialog(
                    context: context,
                    textFields: textFields,
                    title: 'S akým bicyklom je problém?');

                if (result == null) {
                  return;
                }

                final bikeId = result[0];

                final actions = [
                  const SheetAction(key: 0, label: 'Defekt'),
                  const SheetAction(key: 1, label: 'Nejdú brzdy'),
                  const SheetAction(key: 2, label: 'Problém s reťazou'),
                  const SheetAction(key: 3, label: 'Problém s kolesom'),
                  const SheetAction(key: 4, label: 'Chýba časť bicykla'),
                ];

                final reportType = await showModalActionSheet(
                  context: context,
                  actions: actions,
                );

                if (reportType == null) {
                  return;
                }

                final url = Uri.parse(
                    'https://us-central1-bikesharing-f3e11.cloudfunctions.net/reportNotify');
                try {
                  final url2 =
                      Uri.parse('http://$ipAddress:$port/api/v1/report');

                  final body2 = {
                    "id_bike": bikeId.toString(),
                    "id_user": "1",
                    "id_report_type": reportType.toString()
                  };
                  print(body2);
                  final response = await http.post(url2, body: body2);
                  if (response.statusCode == 200) {}
                  print(response.statusCode);

                  final data = {
                    'userId': 'mfHfRPjbWPaEc2OqHnW5TzYRDjI3',
                    'bikeId': bikeId,
                    'reportType': reportType
                  };
                  var body = json.encode(data);
                  //final response = await http.post(url, body: body);
                  await Future.delayed(const Duration(milliseconds: 500));
                  FirebaseFunctions.instance
                      .httpsCallable('reportNotify2')
                      .call([
                    'mfHfRPjbWPaEc2OqHnW5TzYRDjI3',
                    bikeId.toString(),
                    reportType.toString(),
                  ]);

                  //print('response ' + response.toString());
                } catch (error) {
                  print('ERROR: $error');
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.black54,
              ),
              title: const Text('Odhlásiť'),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('Určite?'),
                        content: const Text('Chceš sa odhlásiť?'),
                        alignment: Alignment.center,
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Provider.of<Auth>(context, listen: false)
                                    .logout();
                              },
                              child: const Text('Áno')),
                          TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Nie')),
                        ],
                      );
                    });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: Colors.black54,
              ),
              title: const Text('Info'),
              onTap: () async {
                showAboutDialog(
                  context: context,
                  applicationIcon: Image.asset(
                    'assets/bike.png',
                    width: 48,
                  ),
                  applicationName: 'Bikesharing',
                  applicationVersion: version,
                  applicationLegalese: '© 2022 Adam Belianský & Lukáš Roman',
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.black54,
              ),
              title: const Text('Admin'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AdminScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
