import 'package:flutter/material.dart';
import 'package:nostr_tools/nostr_tools.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NostrFeed());
  }
}

class NostrFeed extends StatefulWidget {
  const NostrFeed({super.key});

  @override
  State<NostrFeed> createState() => _NostrFeedState();
}

class _NostrFeedState extends State<NostrFeed> {
  // This variable is used to store whether the widget is connected to the relay or not.
  bool _isConnected = false;

  // This variable is used to create a new instance of the RelayApi class with the given relay URL.
  final relay = RelayApi(relayUrl: 'wss://relay.damus.io');

  // This list is used to store the events received from the relay.
  final List<Event> events = [];

  // This method is used to connect to the relay and return the stream of events.
  Future<Stream> _connectToRelay() async {
    // Connect to the relay and wait for the stream to be returned.
    final stream = await relay.connect();

    // Listen for events from the relay and update the state accordingly.
    relay.on((event) {
      if (event == RelayEvent.connect) {
        setState(() => _isConnected = true);
      } else if (event == RelayEvent.error) {
        setState(() => _isConnected = false);
      }
    });

    // Subscribe to the Nostr event filter.
    relay.sub([
      Filter(
        kinds: [1],
        limit: 100,
        t: ["nostr"],
      )
    ]);

    // Listen for messages on the stream and add them to the events list.
    stream.listen((message) {
      if (message.type == 'EVENT') {
        Event event = message.message;
        events.add(event);
      }
    });

    // Return the stream.
    return stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nostr Tools Dart'),
        centerTitle: true,
        backgroundColor:
            _isConnected ? const Color(0XFFe728dc) : Colors.redAccent,
      ),
      body: StreamBuilder(
        stream: _connectToRelay()
            .asStream(), // Connect to the relay and get the event stream
        builder: (context, snapshot) {
          // If there is data in the stream, display the events
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    child: Text(
                      events[index].pubkey[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'Event ${events[index].id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Created at:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        unixToHumanReadable(events[index].created_at),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'User:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        events[index].pubkey,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Content:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        events[index].content,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Waiting....'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // This method converts a Unix timestamp to a human-readable date string.
  String unixToHumanReadable(int unixTimeStamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimeStamp * 1000);
    var day = dateTime.day.toString().padLeft(2, '0');
    var month = dateTime.month.toString().padLeft(2, '0');
    var year = dateTime.year.toString().padLeft(4, '0');
    var hour = dateTime.hour.toString().padLeft(2, '0');
    var minute = dateTime.minute.toString().padLeft(2, '0');
    var second = dateTime.second.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute:$second';
  }
}
