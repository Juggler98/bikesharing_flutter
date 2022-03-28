import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
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
                Icons.directions_bike_outlined,
                color: Colors.black54,
              ),
              title: Text('Bike'),
              onTap: () {

              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.electric_scooter,
                color: Colors.black54,
              ),
              title: const Text('Kolobežka'),
              onTap: () async {

                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.directions_walk,
                color: Colors.black54,
              ),
              title: const Text('Pešo'),
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}
