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
  if (!kIsWeb) {
    // to initialize CleverTap for Android and iOS
    runApp(const MyApp());
  } else {
    CleverTapPlugin.init("TEST-98R-65Z-6K7Z", "eu1");

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

    runApp(WebApp());
  }
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleverTap Inbox Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InboxPage(),
    );
  }
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  Map<String, dynamic>? campaignPayload;

  @override
  void initState() {
    super.initState();

    // ✅ Listener registered once
    // CleverTapPlugin.addKVDataChangeListener((kvData) {
    //   print("📩 KV Data Changed: $kvData");
    //   setState(() {
    //     campaignPayload = kvData; // Store payload for UI
    //   });
    // });
  }

  void _triggerInboxViewed() {
    // ✅ This call will cause CleverTap to evaluate campaigns
    CleverTapPlugin.recordEvent("InboxPageViewed", {});
    print("inbox viewed event recorded.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _triggerInboxViewed,
              child: const Text('Record Event & Fetch Campaign'),
            ),

            const SizedBox(height: 20),

            // Render payload if available
            if (campaignPayload != null)
              Text("Payload: $campaignPayload")
            else
              const Text("No campaign payload yet."),
          ],
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
  // String _identity = '';

  // final CleverTapPlugin _clevertapPlugin = CleverTapPlugin();

  @override
  void initState() {
    super.initState();
    CleverTapPlugin.setDebugLevel(3);
    _initializeCleverTap();
    // _fetchCleverTapId();
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
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Identity'),
                    onChanged: (value) => _identity = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _phone = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (value) => _email = value,
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
                    'Phone': _phone,
                    'Identity': _identity,
                    'Email': _email,
                    'dob': CleverTapPlugin.getCleverTapDate(
                      DateTime.parse(dob),
                    ),
                    'stuff': ['bags', 'shoes', 'hats'],
                  });
                  setState(() {
                    _name = '';
                    _email = '';
                    _phone = '';
                    _identity = '';
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void updateForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Form'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Identity'),
                    onChanged: (value) => _identity = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _phone = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (value) => _email = value,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  CleverTapPlugin.profileSet({
                    'Phone': _phone,
                    'Identity': _identity,
                    'Email': _email,
                    'stuff': ['bags', 'shoes', 'hats'],
                  });
                  setState(() {
                    _name = '';
                    _email = '';
                    _phone = '';
                    _identity = '';
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markFirstUnreadMessageAsRead() async {
    try {
      var messageList = await CleverTapPlugin.getUnreadInboxMessages();
      if (messageList == null || messageList.isEmpty) {
        debugPrint("📭 No unread messages found");
        return;
      }

      print('This is message payload: ${jsonEncode(messageList[0])}');

      Map<dynamic, dynamic> firstMessage = messageList[0];
      String messageId = !kIsWeb ? firstMessage["id"] : firstMessage["_id"];

      await CleverTapPlugin.markReadInboxMessageForId(messageId);
      await CleverTapPlugin.pushInboxNotificationViewedEventForId(messageId);

      debugPrint("✅ Marked message as read: $messageId");
    } catch (e) {
      debugPrint("❌ Error marking message as read: $e");
    }
  }

  // void _fetchCleverTapId() async {
  //   try {
  //     String? clevertapId = await CleverTapPlugin.getCleverTapID();
  //     debugPrint("🆔 CleverTap ID: $clevertapId");
  //   } catch (e) {
  //     debugPrint("❌ Error fetching CleverTap ID: $e");
  //   }
  // }

  // Future<void> _sendCleverTapEvent() async {
  //   final url = Uri.parse('https://eu1.api.clevertap.com/1/upload');

  //   final headers = {
  //     'X-CleverTap-Account-Id': 'TEST-98R-65Z-6K7Z',
  //     'X-CleverTap-Passcode': 'QYY-SED-OLEL',
  //     'Content-Type': 'application/json; charset=utf-8',
  //   };

  //   final body = jsonEncode({
  //     "d": [
  //       {
  //         "objectId": "61bd74c14c724aa88346841ec47279e0",
  //         "type": "event",
  //         "evtName": "Store_Page",
  //         "evtData": {},
  //       },
  //     ],
  //   });

  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //     if (response.statusCode == 200) {
  //       debugPrint('Event sent successfully!');
  //     } else {
  //       debugPrint('Failed to send event. Status: ${response.statusCode}');
  //       debugPrint('Response: ${response.body}');
  //     }
  //   } catch (e) {
  //     debugPrint('Error sending event: $e');
  //   }
  // }

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
                  // _markFirstUnreadMessageAsRead();
                }
                // CleverTapPlugin.showInbox({});
              },
              child: const Text('App Inbox'),
            ),
            ElevatedButton(
              onPressed: () {
                CleverTapPlugin.recordEvent("test_event_01", {
                  "test_prop": "NM-PRC-98-STK-25-MAR-8-BLACK",
                });
              },
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
            ElevatedButton(
              onPressed: () {
                // _sendCleverTapEvent();
              },
              child: const Text('Raise Store_Page Event'),
            ),
            ElevatedButton(
              onPressed: () {
                updateForm();
              },
              child: const Text('update profile'),
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
