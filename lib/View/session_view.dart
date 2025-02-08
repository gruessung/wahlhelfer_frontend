import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wahlhelfer_app/Entity/SessionData.dart';
import 'package:wahlhelfer_app/Entity/SessionProvider.dart';
import 'package:http/http.dart' as http;
import 'package:wahlhelfer_app/View/checkin.dart';
import 'package:wahlhelfer_app/View/overview_screen.dart';
import 'package:wahlhelfer_app/View/share_screen.dart';

class SessionDetailView extends StatefulWidget {
  const SessionDetailView({super.key});

  @override
  _SessionDetailViewState createState() => _SessionDetailViewState();
}

class _SessionDetailViewState extends State<SessionDetailView> {
  int _selectedIndex = 2;
  Timer? _timer;
  SessionProvider session = SessionProvider();
  bool fetchDataRunning = false;

  @override
  void initState() {
    super.initState();
    // Funktion zum Starten des Abrufs
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    session = Provider.of<SessionProvider>(context);
    _startFetchingData();
  }

  // Funktion, die alle 10 Sekunden die Daten abruft
  void _startFetchingData() {
    if (!fetchDataRunning) {
      _timer = Timer.periodic(Duration(seconds: 5), (_) async {
        await _fetchData();
      });
      fetchDataRunning = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stoppe den Timer, wenn das Widget entfernt wird
    fetchDataRunning = false;
    super.dispose();
  }

  // Funktion, um die Daten vom Endpoint abzurufen
  Future<void> _fetchData() async {
    try {
      if (session.sessionData!.sessionUuid.isEmpty) {
        SnackBar snackBar = SnackBar(
          content: Text('Fehler beim Beitritt der Session: Formular nicht korrekt ausgefüllt.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      final url = Uri.parse('https://api.wahlhelfer.app/session/${session.sessionData!.sessionUuid}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'password': session.password
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Provider.of<SessionProvider>(context, listen: false).setSessionData(SessionData.fromJson(data));
        //session = Provider.of<SessionProvider>(context);
        print("fetchData erfolgreich");
      } else {
        SnackBar snackBar = SnackBar(
          content: Text('Fehler beim Abruf der Session: ${response.body}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      // Fehlerbehandlung bei Netzwerkproblemen oder ungültigen Anfragen
      print('Fehler: $e');
    }
  }

  // Liste von Screens, die durch die Navigation erreichbar sind
  final List<Widget> _widgetOptions = <Widget>[
    CheckpointScreen(checkpoint_id: '1', key: Key('cp1'),),
    CheckpointScreen(checkpoint_id: '2', key: Key('cp2')),
    OverviewScreen(),
    ShareScreen(),
  ];

  // Methode zum Wechseln der ausgewählten Seite
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wahlhelfer.app Session'),
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
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_one),
            label: 'Checkpoint 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_two),
            label: 'Checkpoint 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Übersicht',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Teilen',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightGreen,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}



