import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models/auth.dart';
import 'screens/history/history_screen.dart';

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
              onTap: () async {},
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
          ],
        ),
      ),
    );
  }
}
