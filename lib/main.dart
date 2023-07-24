import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rtc_demo/helper/web_socket_manager.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_sound/flutter_sound.dart';
//import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //late WebSocketChannel channel;
  final TextEditingController _messageController = TextEditingController();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final List<String> _messages = [];
  late SocketIOManager socket;
  @override
  void initState() {
    super.initState();
    // Initialize the WebSocket connection
    //channel = IOWebSocketChannel.connect(Uri.parse('ws://39.108.14.126:9006'));
    //channel = WebSocketManager.getInstance().channel;
    socket = SocketIOManager.getInstance();
    socket.socket.connect();

    //socket.on('data');

    socket.socket.onConnect((data) {
      print('Connected to the server!');
      //socket.emit('join', {'username': 'test', 'room': '123456'});
      socket.socket.on('audio_data', _handleAudioData);
      socket.socket.on('data', _handleOtherData);
    });
  }

  void _handleAudioData(dynamic data) async {
    // Handle audio data here
    print('Received audio data: $data');
    List<int> audioBytes = base64Decode(data);
    debugPrint('audioBytes: $audioBytes');
    Uint8List audioUint8List = Uint8List.fromList(audioBytes);
    // Play the audio using flutter_sound
    await _audioPlayer.openPlayer();
    // 播放Uint8List
    await _audioPlayer.startPlayer(
      fromDataBuffer: audioUint8List,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
    );
    //await _audioPlayer.closePlayer();
  }

  void _handleOtherData(dynamic data) {
    print('Received other data: $data');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    //channel.sink.close();
    socket.socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // socket.socket.onConnect((data) {
    //   socket.on('audio_data', _handleAudioData);
    //   socket.on('data', _handleOtherData);
    // });
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Chat'),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: socket.controller.stream,
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
                    //channel.sink.add(message);
                    socket.emit('data', {
                      'username': 'test',
                      'room': '123456',
                      'data': message
                    });
                    socket.emit('stream_audio', {
                      'username': 'test',
                      'room': '123456',
                      'data': message
                    });

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
