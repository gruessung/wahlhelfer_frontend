import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onscreen_num_keyboard/onscreen_num_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:wahlhelfer_app/Entity/SessionData.dart';
import 'package:wahlhelfer_app/Entity/SessionProvider.dart';
import 'package:http/http.dart' as http;

class CheckpointScreen extends StatefulWidget {

  const CheckpointScreen({super.key, required this.checkpoint_id});

  final String checkpoint_id;

  @override
  _CheckpointScreenState createState() => _CheckpointScreenState(checkpoint_id: checkpoint_id);
}

class _CheckpointScreenState extends State<CheckpointScreen> {

  _CheckpointScreenState({required this.checkpoint_id});
  final String checkpoint_id;

  String type = "CheckIn";


  final TextEditingController _controller = TextEditingController();

  @override
  initState() {
    super.initState();
    if (checkpoint_id == "2") {
      setState(() {
        type = "CheckOut";
      });
    }
  }




  Future<void> markEntry(BuildContext context, SessionProvider session, String entryId) async {
    String sessionId = session.sessionData!.sessionUuid;
    
    //if (int.parse(entryId))
    
    final url = Uri.parse('https://api.wahlhelfer.app/session/$sessionId/$entryId/mark/$checkpoint_id');
    print(url);
    final response = await http.post(
      url,
      body: {
        'password': session.password,
      },
    );

    _controller.text = "";

    if (response.statusCode == 200) {
      SnackBar snackBar = SnackBar(
        content: Text('$type erfolgreich!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      final data = jsonDecode(response.body);
      Entry entry = Entry.fromJson(data['data']);

      if (!entry.mark1 && entry.mark2) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Achtung!"),
              content: Text("Die Wählernummer ${entry.entryNo.toString()} wurde nicht an Checkpoint 1 erfasst!"),
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
      }

    } else if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Achtung!"),
            content: Text("Die Wählernummer $entryId wurde bereits an beiden Checkpoints erfasst!"),
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
    } else {
      SnackBar snackBar = SnackBar(
        content: Text('Fehler beim $type: ${response.statusCode}'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // Methode zum Hinzufügen einer Zahl in das Textfeld
  void _onButtonPressed(String value) {
    setState(() {
      _controller.text += value; // Wert wird zum aktuellen Text hinzugefügt
    });
  }



  @override
  Widget build(BuildContext context) {

    SessionProvider session = Provider.of<SessionProvider>(context);

    return LayoutBuilder(

      builder: (BuildContext context, BoxConstraints constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

      return Row(
        //direction: isWideScreen ? Axis.horizontal : Axis.vertical,
          children: [
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Checkpoint $checkpoint_id", style: TextStyle(fontSize: 25),),
                        // TextField für die numerische Eingabe
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.none,  // Verhindert die systemeigene Tastatur
                          decoration: InputDecoration(
                            labelText: 'Nummer des Wählenden eingeben $checkpoint_id',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        NumericKeyboard(
                            onKeyboardTap: _onButtonPressed,
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                            ),
                            rightButtonFn: () {
                              if (_controller.text.isEmpty) return;
                              setState(() {
                                _controller.text = _controller.text.substring(0, _controller.text.length - 1);
                              });
                            },
                            rightButtonLongPressFn: () {
                              if (_controller.text.isEmpty) return;
                              setState(() {
                                _controller.text = '';
                              });
                            },
                            rightIcon: const Icon(
                              Icons.backspace_outlined,
                              color: Colors.blueGrey,
                            ),
                            mainAxisAlignment: MainAxisAlignment.spaceBetween),

                        // Button zum Absenden der Eingabe
                        ElevatedButton(
                          onPressed: () {
                            String enteredValue = _controller.text;
                            markEntry(context, session, enteredValue);
                          },
                          child: Text('$type durchführen'),

                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(

                      children: <Widget>[
                        Text(
                          'Offene Nummern:',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16),

                        Column(
                          children: session.sessionData!.entries.map((entry) => ((entry.mark1 != entry.mark2) ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(  onPressed: () {
                              _controller.text = entry.entryNo.toString();
                            },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    (entry.mark1 && !entry.mark2) ? Icon(Icons.timer_outlined) : Icon(Icons.warning, color:  Colors.redAccent,),
                                    Text(entry.entryNo.toString(), style: TextStyle(fontSize: 20)),
                                  ],
                                )),
                          ): Container())).toList(),
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
