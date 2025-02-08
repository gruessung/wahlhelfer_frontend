import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../Entity/SessionData.dart';
import 'dart:js' as js;
import '../Entity/SessionProvider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.title});

  final String title;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _entriesPerPageController =
      TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _totalEntriesController = TextEditingController();
  final TextEditingController _sessionIdController = TextEditingController();
  final TextEditingController _joinPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> sendPostRequest(BuildContext context) async {
    final url = Uri.parse('https://api.wahlhelfer.app/session/create');
    final response = await http.post(
      url,
      //headers: {'Content-Type': 'application/json'},
      body: {
        'password': _passwordController.text,
        'cnt_entries_per_page': _entriesPerPageController.text,
        'cnt_pages': _pagesController.text,
        'cnt_entries_total': _totalEntriesController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SessionData session = SessionData.fromJson(data);
      Provider.of<SessionProvider>(context, listen: false)
          .setSessionData(session);
      Provider.of<SessionProvider>(context, listen: false)
          .setToken(session.sessionUuid);
      Provider.of<SessionProvider>(context, listen: false)
          .setPassword(_passwordController.text);
      print('Erfolgreich: ${response.body}');
    } else {
      print('Fehler: ${response.body}');
    }
  }

  Future<void> joinSession(BuildContext context) async {
    if (_sessionIdController.text.isEmpty) {
      SnackBar snackBar = SnackBar(
        content: Text(
            'Fehler beim Beitritt der Session: Formular nicht korrekt ausgefüllt.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final url = Uri.parse(
        'https://api.wahlhelfer.app/session/${_sessionIdController.text}/join');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'password': _joinPasswordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Provider.of<SessionProvider>(context, listen: false)
          .setSessionData(SessionData.fromJson(data));
      Provider.of<SessionProvider>(context, listen: false)
          .setToken(_sessionIdController.text);
      Provider.of<SessionProvider>(context, listen: false)
          .setPassword(_joinPasswordController.text);

      SnackBar snackBar = SnackBar(
        content: Text('Erfolgreich der Session beigetreten.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      SnackBar snackBar = SnackBar(
        content:
            Text('Fehler beim Beitritt der Session: ${response.statusCode}'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    var _result = "";

    return Scaffold(
      appBar: AppBar(
        title: Text('Wahlhelfer.app'),
        backgroundColor: Colors.lightGreen,
        actions: [
          TextButton(
            onPressed: () {
              js.context.callMethod('open', ['https://impressum.gruessung.eu/6d211af0ac142580474bbffbbde8b226/1.html']);
            },
            child: const Text(
              'Datenschutz',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              js.context.callMethod('open', ['https://impressum.gruessung.eu/6d211af0ac142580474bbffbbde8b226.html']);
            },
            child: const Text(
              'Impressum',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Session erstellen'),
            Tab(text: 'Session beitreten'),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
        tooltip: 'Session beitreten',
        onPressed: (){


          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("QR Code scannen"),
                content: Text("Test"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dialog schließen
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );

          /**
           *
           */

        },
        child: const Icon(Icons.qr_code, color: Colors.white, size: 28),
      ),*/
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 100, right: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                ),
                TextField(
                  controller: _entriesPerPageController,
                  decoration:
                      InputDecoration(labelText: 'Anzahl Einträge pro Seite'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _pagesController,
                  decoration: InputDecoration(labelText: 'Anzahl Seiten'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _totalEntriesController,
                  decoration:
                      InputDecoration(labelText: 'Anzahl Einträge Gesamt'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    sendPostRequest(context);
                  },
                  child: Text('Session Erstellen'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 100, right: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _sessionIdController,
                  decoration: InputDecoration(labelText: 'SessionID'),
                ),
                TextField(
                  controller: _joinPasswordController,
                  decoration: InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                /* ElevatedButton(
                  onPressed: () {
                    _sessionIdController.text = "d2450be1-e544-4be1-b7db-ab1d6deec074";
                    _joinPasswordController.text = "0000000000";
                    joinSession(context);
                  },
                  child: Text('Test Session Beitreten'),
                ),*/

                ElevatedButton(
                  onPressed: () {
                    joinSession(context);
                  },
                  child: Text('Session Beitreten'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
