import 'dart:convert';

import 'package:clevertap/permissions/push_permission.dart';
import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CleverTapPlugin.enableDeviceNetworkInfoReporting(true);

  bool granted =
      await NotificationPermissionRequester.requestNotificationPermission();

  if (granted) {
    print("Ready to initialize CleverTap or receive push notifications.");
  } else {
    print("Permission not granted, notifications will not work.");
  }

  if (kIsWeb) {
    // ✅ Web initialization
    CleverTapPlugin.init("TEST-98R-65Z-6K7Z", "eu1");

    var pushData = {
      'titleText': 'Would you like to receive Push Notifications?',
      'bodyText': 'We promise to only send you relevant content and updates',
      'okButtonText': 'Ok',
      'rejectButtonText': 'Cancel',
      'okButtonColor': '#F28046',
      'askAgainTimeInSeconds': 5,
      'serviceWorkerPath': '/firebase-messaging-sw.js',
    };

    CleverTapPlugin.enableWebPush(pushData);

    CleverTapPlugin.onUserLogin({
      'Name': 'Captain America',
      'Email': 'xykm.p@america.com',
      'userType': 'Flutter Web User',
    });

    Future.delayed(const Duration(seconds: 5), () {
      CleverTapPlugin.recordEvent("AppointmentBooked", {});
    });

    CleverTapPlugin.initializeInbox();

    runApp(const WebApp());
  } else {
    // ✅ Mobile
    runApp(const MyApp());
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

  // void updateDiv() {
  //   final div = html.document.getElementById('clevertap-container');
  //   if (div != null) {
  //     div.innerHtml = ""; // empty div (you wanted this)
  //   }
  // }

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
  late CleverTapPlugin _cleverTapPlugin;

  // final CleverTapPlugin _clevertapPlugin = CleverTapPlugin();

  @override
  void initState() {
    super.initState();

    _cleverTapPlugin = CleverTapPlugin();

    CleverTapPlugin.setDebugLevel(3);
    CleverTapPlugin.setOptOut(true);

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

    // _cleverTapPlugin.

    _cleverTapPlugin.setCleverTapInAppNotificationButtonClickedHandler((data) {
      debugPrint("🔥 In-App Button Clicked: $data");
    });

    _cleverTapPlugin.setCleverTapPushClickedPayloadReceivedHandler((data) {
      debugPrint("📩 Push Clicked Payload: $data");
    });

    _cleverTapPlugin.setCleverTapInAppNotificationDismissedHandler(
      inAppNotificationDismissed,
    );
  }

  void inAppNotificationButtonClicked(
    Map<dynamic, dynamic>? map,
    int? buttonIndex,
  ) {
    print("🔥 inAppNotificationButtonClicked called");
    print("Payload: $map");
    print("Button Index: $buttonIndex");

    if (map != null) {
      final data = Map<String, dynamic>.from(map);
      print("Button Text: ${data["buttonText"]}");
    }
  }

  // void pushClickedPayloadReceived(Map<dynamic, dynamic>? data) {
  //   print("📩 pushClickedPayloadReceived called");
  //   print("Payload: $data");

  //   if (data != null) {
  //     final payload = Map<String, dynamic>.from(data);
  //     print("Push Payload: $payload");
  //   }
  // }
  void inAppNotificationDismissed(Map<String, dynamic> map) {
    final extras = Map<String, dynamic>.from(
      map['extras'] ?? {},
    ); // dashboard key-values
    final actionExtras = Map<String, dynamic>.from(
      map['actionExtras'] ?? {},
    ); // null -> {}

    print(
      "inAppNotificationDismissed extras: $extras, actionExtras: $actionExtras",
    );

    if (actionExtras.isEmpty) {
      // dismissed without an action (e.g. close button)
    }
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
                  var dob = '2002-08-17';
                  CleverTapPlugin.onUserLogin({
                    "Name": "John Check",
                    'Phone': _phone,
                    'Identity': _identity,
                    'Email': _email,
                    'dob': CleverTapPlugin.getCleverTapDate(
                      DateTime.parse(dob),
                    ),
                    'stuff': ['bags', 'shoes', 'hats'],
                    'Plan type': 'Yes',
                    'MSG-sms': true,
                    'Language': 'en',
                    'prop_method': 'OnUserLogin Called',
                    "Tz": "Asia/Kathmandu",
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
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  var dob = '2002-02-22';
                  CleverTapPlugin.profileSet({
                    "Name": "John Check",
                    'Phone': _phone,
                    'Identity': _identity,
                    'Email': _email,
                    'dob': CleverTapPlugin.getCleverTapDate(
                      DateTime.parse(dob),
                    ),
                    'content_saved_to_watch_later_ids': '56481',
                    // 'stuff': ['8180'],
                    'Plan type': 'Yes',
                    'MSG-sms': true,
                    'Language': 'en',
                    'prop_method': 'profile_update',
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
              child: const Text('Profile Update'),
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
                CleverTapPlugin.recordEvent("Video Watched", {
                  "video_id": 300,
                  "video_name": "Credit card",
                  "Charged ID": "12345",
                });

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
                // CleverTapPlugin.recordEvent("pagescreen_view", {
                //   "pagescreen_name": "service_home_page",
                // });

                // DateTime date = DateTime(2026, 3, 14, 4, 45);

                // CleverTapPlugin.recordEvent("Child eSIM Activated", {
                //   "date": "\$D_1773478500",
                // });
                Future.delayed(const Duration(seconds: 4), () {
                  CleverTapPlugin.recordEvent("Child eSIM Activated", {
                    "date": "\$D_1773478500",
                  });
                });

                // CleverTapPlugin.recordEvent("pagescreen_view", {
                //   "pagescreen_name": "home_page",
                // });
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
