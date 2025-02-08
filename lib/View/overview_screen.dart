import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wahlhelfer_app/Entity/SessionData.dart';

import '../Entity/SessionProvider.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SessionData? sessionData = Provider.of<SessionProvider>(context).sessionData;


    return Scaffold(
      appBar: AppBar(
        title: Text('Übersicht'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Zusammenfassung",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                border: TableBorder.symmetric(
                  inside: BorderSide(width: 1, color: Colors.grey.shade300),
                ),
                children:  [
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Einträge Gesamt im Wählerverzeichnis", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("${sessionData?.summary['total_entries'] ?? 0}"),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("davon abgeschlossen", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("${sessionData?.summary['finished'] ?? 0}"),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Aktuell im Wahlprozess", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("${sessionData?.diff['total'] ?? 0}"),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
            ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Warnungen",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey.shade300),
                        ),
                        children:  [
                          TableRow(children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Wählernummern, die an CP 2, aber nicht an CP 1 erfasst wurden", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("${sessionData?.diff['mark2_no_mark1'] ?? 0}"),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Einträge",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(3),
                        },
                        border: TableBorder.symmetric(
                          inside: BorderSide(width: 1, color: Colors.grey.shade300),
                        ),
                        children:
        
                          sessionData!.entries.map((entry) {
                            return TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("${entry.entryNo.toString()} (Seite ${entry.pageNo.toString()})", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: (entry.mark1) ? Icon(Icons.check_circle_outline, color: Colors.green) : Icon(Icons.cancel_outlined, color: Colors.redAccent),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: (entry.mark2) ? Icon(Icons.check_circle_outline, color: Colors.green) : Icon(Icons.cancel_outlined, color: Colors.redAccent),
                              ),
                            ]);
                          }).toList()
        
        
                        ,
                      ),
                    ],
                  ),
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }
}