import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data_provider.dart';
import 'package:provider/provider.dart';

class UserTabWidget extends StatefulWidget {
  @override
  _UserTabWidgetState createState() => _UserTabWidgetState();
}

class _UserTabWidgetState extends State<UserTabWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedBulletPoint;
  bool _isEditing = false; // Added editing mode flag
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('Userdata')
          .doc(_auth.currentUser!.uid)
          .get(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!.data()!;

          _firstNameController.text = userData['Firstname'] ?? '';
          _lastNameController.text = userData['Lastname'] ?? '';
          _ageController.text = userData['Age'] ?? '';

          List<Item> _items = [
            Item(
              headerValue: 'Meine Daten',
              expandedValue: 'Hier können Sie Ihre Daten einsehen',
              userData: [
                if (!_isEditing)
                  ListTile(
                    title: Text('Firstname: ${userData['Firstname']}'),
                  ),
                if (!_isEditing)
                  ListTile(
                    title: Text('Lastname: ${userData['Lastname']}'),
                  ),
                if (!_isEditing)
                  ListTile(
                    title: Text('Age: ${userData['Age']}'),
                  ),
                if (!_isEditing)
                  ListTile(
                    title: Text('Level: ${userData['totalLevels']}'),
                  ),
                if (!_isEditing)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: Text('Edit'),
                  ),
                if (_isEditing)
                  Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(labelText: 'Firstname'),
                      ),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(labelText: 'Lastname'),
                      ),
                      TextField(
                        controller: _ageController,
                        decoration: InputDecoration(labelText: 'Age'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _firstNameController.text =
                                    userData['Firstname'] ?? '';
                                _lastNameController.text =
                                    userData['Lastname'] ?? '';
                                _ageController.text = userData['Age'] ?? '';
                              });
                            },
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              String firstName = _firstNameController.text;
                              String lastName = _lastNameController.text;
                              String age = _ageController.text;

                              FirebaseFirestore.instance
                                  .collection('Userdata')
                                  .doc(_auth.currentUser!.uid)
                                  .update({
                                'Firstname': firstName,
                                'Lastname': lastName,
                                'Age': age,
                              }).then((_) {
                                setState(() {
                                  _isEditing = false;
                                });
                              }).catchError((error) {
                                print('Error updating user data: $error');
                              });
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            Item(
              headerValue: 'Netzwerk Optionen',
              expandedValue: 'Netzwerk Optionen Content',
            ),
            Item(headerValue: 'Logout', expandedValue: '', userData: [
              Center(
                  child: ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                },
                child: Text('Logout!'),
              ))
            ]),
            Item(
              headerValue: 'Datenschutzbestimmungen',
              expandedValue: '''
              Datenschutzbestimmungen für eine App, die Name, Vorname und Alter speichert:
              
              Datenschutz ist uns wichtig, daher haben wir die folgenden Bestimmungen festgelegt, um Ihre personenbezogenen Daten zu schützen:
              
              Datensammlung und Verwendung:
              a. Wir erfassen Ihren Namen, Vornamen und Ihr Alter, um Ihnen personalisierte Dienste bereitzustellen und Ihr Nutzungserlebnis zu verbessern.
              b. Ihre Daten werden nur für den angegebenen Zweck verwendet und nicht an Dritte weitergegeben, es sei denn, Sie haben ausdrücklich Ihre Zustimmung gegeben oder es besteht eine gesetzliche Verpflichtung.
              c. Wir speichern Ihre Daten sicher und schützen sie vor unbefugtem Zugriff oder Missbrauch.
              
              Datenlöschung:
              a. Wenn Sie möchten, dass Ihre Daten aus unserer App gelöscht werden, können Sie sich unter der folgenden E-Mail-Adresse an uns wenden: example@email.de.
              b. Nach Erhalt Ihrer Anfrage werden wir Ihre Daten innerhalb einer angemessenen Frist löschen, sofern keine rechtlichen Gründe für die Aufbewahrung bestehen.
              
              Datensicherheit:
              a. Wir setzen technische und organisatorische Maßnahmen ein, um Ihre Daten vor unbefugtem Zugriff, Verlust oder Diebstahl zu schützen.
              b. Wir verwenden Verschlüsselungstechnologien, um die Sicherheit Ihrer Daten während der Übertragung zu gewährleisten.
              
              Nutzung von Cookies:
              a. Wir verwenden möglicherweise Cookies oder ähnliche Tracking-Technologien, um Informationen über Ihre Nutzung der App zu sammeln.
              b. Diese Informationen dienen dazu, Ihr Nutzungserlebnis zu verbessern und statistische Analysen durchzuführen.
              c. Sie haben die Möglichkeit, die Verwendung von Cookies in den Einstellungen Ihrer App zu steuern.
              
              Änderungen der Datenschutzbestimmungen:
              a. Wir behalten uns das Recht vor, diese Datenschutzbestimmungen jederzeit zu ändern oder zu aktualisieren.
              b. Bei wesentlichen Änderungen werden wir Sie über die App oder per E-Mail benachrichtigen.
              
              Wenn Sie Fragen oder Bedenken zu unseren Datenschutzbestimmungen haben, können Sie sich gerne an uns wenden.
              ''',
            ), // Rest of the code remains the same...
          ];

          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ListView(
                children: _items.map<Widget>((Item item) {
                  return ExpansionPanelList(
                    elevation: 1,
                    expandedHeaderPadding: EdgeInsets.zero,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _selectedBulletPoint =
                            isExpanded ? null : item.headerValue;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                              item.headerValue,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: isExpanded
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        body: _selectedBulletPoint == item.headerValue
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.expandedValue,
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    SizedBox(height: 16.0),
                                    if (item.userData != null)
                                      ...item.userData!,
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                        isExpanded: _selectedBulletPoint == item.headerValue,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class Item {
  final String headerValue;
  final String expandedValue;
  final List<Widget>? userData;

  Item({
    required this.headerValue,
    required this.expandedValue,
    this.userData,
  });
}

Widget _buildBulletPoint(String text, {required bool selected}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    margin: EdgeInsets.symmetric(vertical: 4.0),
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: selected ? Colors.blue : Colors.grey,
          width: 2.0,
        ),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: selected ? 18.0 : 16.0,
          color: selected ? Colors.blue : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

class PageFour extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return StreamBuilder<Map<String, dynamic>>(
      stream: firebaseService.getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!;

          return Center(
              child: ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
            },
            child: Text('Hello, ${userData['Level'].toString()}!'),
          ));
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}