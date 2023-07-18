import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel channel;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    // Initialize the WebSocket connection
    channel = IOWebSocketChannel.connect('wss://172.16.24.38:8765');
    // Set up the listener for incoming messages
    // channel.stream.listen((message) {
    //   setState(() {
    //     _messages.add(message);
    //   });
    // }, onError: (error) {
    //   print('WebSocket Error: $error');
    // }, onDone: () {
    //   print('WebSocket Connection Closed');
    // });
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Chat'),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              return Text(snapshot.hasData ? '${snapshot.data}' : 'No message');
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Send a message
                    String message = _messageController.text;
                    channel.sink.add(message);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
