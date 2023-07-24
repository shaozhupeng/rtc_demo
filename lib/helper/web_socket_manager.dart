import 'dart:async';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart' as sic;
import 'package:flutter/foundation.dart' show kIsWeb;

class WebSocketManager {
  late WebSocketChannel channel;
  static WebSocketManager? _instance;
  static const String socketUrl = 'ws://127.0.0.1:9006';
  WebSocketManager._() {
    if (kIsWeb) {
      channel = WebSocketChannel.connect(Uri.parse(socketUrl));
    } else {
      channel = IOWebSocketChannel.connect(Uri.parse(socketUrl));
    }
  }

  static WebSocketManager getInstance() {
    _instance ??= WebSocketManager._();
    return _instance!;
  }
}

class SocketIOManager {
  static SocketIOManager? _instance;
  late sic.Socket socket;
  //static const String socketUrl = 'http://192.168.31.108:5004';
  static const String socketUrl = 'http://127.0.0.1:5004';
  StreamController controller = StreamController.broadcast();
  late Map<String, dynamic> options;
  SocketIOManager._() {
    options = {
      'transports': ['websocket'], // 指定使用 WebSocket 传输协议
      'extraHeaders': {
        'Authorization': 'Bearer your_access_token'
      }, // 可以添加额外的请求头
      'autoConnect': false, // 是否自动连接
      'debug': true,
    };
    if (kIsWeb) {
      options['extraHeaders'] = {
        'Authorization': 'Bearer your_web_access_token',
      };
      socket = sic.io(socketUrl, options);
    } else {
      socket = sic.io(socketUrl, options);
    }
  }
  static SocketIOManager getInstance() {
    _instance ??= SocketIOManager._();
    return _instance!;
  }

  void connect() {
    socket.connect();
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void emit(String event, Map<String, dynamic> data) {
    socket.emit(event, data);
  }
}
