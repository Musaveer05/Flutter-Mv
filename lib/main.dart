import 'dart:convert';

import 'package:clevertap/permissions/push_permission.dart';
import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool granted =
      await NotificationPermissionRequester.requestNotificationPermission();

  if (granted) {
    print("Ready to initialize CleverTap or receive push notifications.");
  } else {
    print("Permission not granted, notifications will not work.");
  }

  // to initialize Flutter Web SDK with your account ID and region
  CleverTapPlugin.init("TEST-98R-65Z-6K7Z", "eu1");
  if (!kIsWeb) {
    // to initialize CleverTap for Android and iOS
    runApp(const MyApp());
  } else {
    var pushData = {
      'titleText': 'Would you like to receive Push Notifications?',
      'bodyText':
          'We promise to only send you relevant content and give you updates on your transactions',
      'okButtonText': 'Ok',
      'rejectButtonText': 'Cancel',
      'okButtonColor': '#F28046',
      'askAgainTimeInSeconds': 5,
      'serviceWorkerPath': '/firebase-messaging-sw.js',
    };
    CleverTapPlugin.enableWebPush(pushData);

    var stuff = ["bags", "shoes"];
    var profile = {
      'Name': 'Captain America',
      'Email': 'xykm.p@america.com',
      'stuff': stuff,
      'age': 50,
    };
    CleverTapPlugin.onUserLogin(profile);

    Future.delayed(Duration(seconds: 5), () {
      CleverTapPlugin.recordEvent("AppointmentBooked", {});
    });

    CleverTapPlugin.initializeInbox();

    runApp(webApp());
  }
}

class webApp extends StatelessWidget {
  const webApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleverTap Inbox Example',
      home: const InboxPage(),
    );
  }
}

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    CleverTapPlugin.recordEvent("InboxPageViewed", {});
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            CleverTapPlugin.showInbox({});
          },
          child: const Text('Show Inbox'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _identity = '';

  // final CleverTapPlugin _clevertapPlugin = CleverTapPlugin();

  @override
  void initState() {
    super.initState();
    CleverTapPlugin.setDebugLevel(3);
    _initializeCleverTap();
    _fetchCleverTapId();
  }

  void _initializeCleverTap() {
    if (!kIsWeb) {
      CleverTapPlugin.initializeInbox();
    }
    CleverTapPlugin().setCleverTapInboxDidInitializeHandler(
      () => debugPrint("✅ CleverTap Inbox Initialized"),
    );
    CleverTapPlugin().setCleverTapInboxMessagesDidUpdateHandler(
      () => debugPrint("Inbox messages updated"),
    );
  }

  void inboxDidInitialize() {
    setState(() {
      print("inboxDidInitialize called");

      var styleConfig = {
        'noMessageTextColor': '#ff6600',
        'noMessageText': 'No message(s) to show.',
        'navBarTitle': 'App Inbox',
      };

      CleverTapPlugin.showInbox(styleConfig);
    });
  }

  void openForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Form'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // TextFormField(
                  //   decoration: const InputDecoration(labelText: 'Name'),
                  //   onChanged: (value) => _name = value,
                  //   validator: (value) =>
                  //       value == null || value.isEmpty ? 'Enter name' : null,
                  // ),
                  // TextFormField(
                  //   decoration: const InputDecoration(labelText: 'Email'),
                  //   keyboardType: TextInputType.emailAddress,
                  //   onChanged: (value) => _email = value,
                  //   validator: (value) => value == null || !value.contains('@')
                  //       ? 'Enter valid email'
                  //       : null,
                  // ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Identity'),
                    onChanged: (value) => _identity = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _phone = value,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  var dob = '2002-02-22';
                  CleverTapPlugin.onUserLogin({
                    'Identity': _identity,
                    'Phone': _phone,
                    'dob': CleverTapPlugin.getCleverTapDate(
                      DateTime.parse(dob),
                    ),
                    'stuff': ['bags', 'shoes', 'hats'],
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Login'),
            ),
            // TextButton(
            //   onPressed: () {
            //     if (_formKey.currentState!.validate()) {
            //       CleverTapPlugin.profileSet({
            //         'Name': _name,
            //         'Email': _email,
            //         'Phone': _phone,
            //       });
            //       Navigator.of(context).pop();
            //     }
            //   },
            //   child: const Text('Update'),
            // ),
          ],
        );
      },
    );
  }

  void _fetchCleverTapId() async {
    try {
      String? clevertapId = await CleverTapPlugin.getCleverTapID();
      debugPrint("🆔 CleverTap ID: $clevertapId");
    } catch (e) {
      debugPrint("❌ Error fetching CleverTap ID: $e");
    }
  }

  Future<void> sendEventToCleverTap() async {
    final url = Uri.parse("https://api.clevertap.com/1/upload");

    final headers = {
      'X-CleverTap-Account-Id': 'TEST-98R-65Z-6K7Z',
      'X-CleverTap-Passcode': 'QYY-SED-OLEL',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "d": [
        {
          "identity": "testdns", // use email or CleverTap ID or identity
          "type": "event",
          "evtName": "booking_fee_completed",
          "evtData": {"tags": "atlanta"},
        },
      ],
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Event sent successfully: ${response.body}");
    } else {
      print("Failed to send event: ${response.statusCode} ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Press the + button to open the user form'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                CleverTapPlugin.recordEvent("Charged", {});
                if (!kIsWeb) {
                  CleverTapPlugin.showInbox({});
                }
                // CleverTapPlugin.showInbox({});
              },
              child: const Text('App Inbox'),
            ),
            ElevatedButton(
              onPressed: sendEventToCleverTap,
              child: const Text('Raise a Event'),
            ),

            ElevatedButton(
              onPressed: () {
                CleverTapPlugin.recordEvent("store_page", {
                  "Store_name": "Ajio",
                });
              },
              child: const Text('Raise Store_Page Event'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openForm,
        tooltip: 'Open Form',
        child: const Icon(Icons.add),
      ),
    );
  }
}
