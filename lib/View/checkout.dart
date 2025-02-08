import 'package:flutter/material.dart';
import 'package:onscreen_num_keyboard/onscreen_num_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:wahlhelfer_app/Entity/SessionProvider.dart';
import 'package:http/http.dart' as http;

class Checkpoint2Screen extends StatefulWidget {
  const Checkpoint2Screen({super.key});

  @override
  _Checkpoint2ScreenState createState() => _Checkpoint2ScreenState();
}

class _Checkpoint2ScreenState extends State<Checkpoint2Screen> {

  final TextEditingController _controller = TextEditingController();


  Future<void> markEntry(BuildContext context, SessionProvider session, String entryId) async {


    String sessionId = session.sessionData!.sessionUuid;

    final url = Uri.parse('https://api.wahlhelfer.app/session/$sessionId/$entryId/mark/2');
    print(url);
    final response = await http.post(
      url,
      body: {
        'password': session.password,
      },
    );

    if (response.statusCode == 200) {
      SnackBar snackBar = SnackBar(
        content: Text('CheckOut erfolgreich!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      SnackBar snackBar = SnackBar(
        content: Text('Fehler beim CheckOut: ${response.statusCode}'),
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

    return SingleChildScrollView(
      child: Row(
      
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(90),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
      
                    // TextField für die numerische Eingabe
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.none,  // Verhindert die systemeigene Tastatur
                      decoration: InputDecoration(
                        labelText: 'Nummer des Wählenden eingeben',
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
                      child: Text('CheckOut durchführen'),
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Offene Nummern:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
      
                  /*ListView.builder(
                    itemCount: session.sessionData!.entries.length,
                    itemBuilder: (context, index) {
                      Entry entry = session.sessionData!.entries[index];
                      if (entry.mark1 && !entry.mark2) {
                        return ListTile(
                          title: Text(entry.entryNo as String),
                        );
                      }
                    },*/
      
                  Column(
                    children: session.sessionData!.entries.map((entry) => ((entry.mark1 && !entry.mark2) ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton( onPressed: () {  },
                          child: Text(entry.entryNo.toString(), style: TextStyle(fontSize: 20))),
                    ): Container())).toList(),
                  )
      
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
