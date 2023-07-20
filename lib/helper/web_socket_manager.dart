import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  final String url;
  late WebSocketChannel _channel;

  WebSocketManager({required this.url});

  // 连接WebSocket
  Future<void> connect() async {
    _channel = IOWebSocketChannel.connect(url);
    _channel.stream.listen((data) {
      // 处理接收到的数据
      handleReceivedData(data);
    }, onError: (error) {
      // 处理连接错误
      handleError(error);
    }, onDone: () {
      // 处理连接关闭
      handleDone();
    });
  }

  // 关闭WebSocket连接
  void disconnect() {
    _channel.sink.close();
  }

  // 发送消息
  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  // 处理接收到的数据
  void handleReceivedData(dynamic data) {
    // 在这里解析和处理接收到的信令数据
    print('Received: $data');
  }

  // 处理连接错误
  void handleError(dynamic error) {
    print('WebSocket error: $error');
  }

  // 处理连接关闭
  void handleDone() {
    print('WebSocket closed');
  }
}
