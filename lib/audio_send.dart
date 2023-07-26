import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rtc_demo/helper/web_socket_manager.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum RecorderStatus { Initialized, Recording, Stopped }

enum PlayerStatus { Playing, Paused, Stopped }

extension PlayerStatusX on PlayerStatus {
  bool get isPlaying => this == PlayerStatus.Playing;
  bool get isPaused => this == PlayerStatus.Paused;
  bool get isStopped => this == PlayerStatus.Stopped;
}

extension RecorderStatusX on RecorderStatus {
  bool get isInitialized => this == RecorderStatus.Initialized;
  bool get isRecording => this == RecorderStatus.Recording;
  bool get isStopped => this == RecorderStatus.Stopped;
}

class AudioSend extends StatefulWidget {
  const AudioSend({super.key});

  @override
  State<AudioSend> createState() => _AudioSendState();
}

class _AudioSendState extends State<AudioSend> {
  // socket
  late SocketIOManager socketManager;
  // 录音流状态监控
  //late StreamSubscription _recorderSubscription;
  //late StreamSubscription _playerSubscription;
  // 录音数据直接写入录音流
  //StreamController<Food> audioStream = StreamController.broadcast();
  // 录音器
  //final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  // 播放器
  //final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  // 语音流数据帧缓存
  //List<String> cacheAudio = [];
  // 上一次非静音时间
  //int lastNonZeroTime = double.maxFinite.toInt();
  //当前振幅
  //double currentAmp = 0.0;
  @override
  void initState() {
    socketManager = SocketIOManager.getInstance();
    // 连接socket
    socketManager.connect();

    socketManager.socket.onConnect((data) {
      // 加入聊天室
      socketManager.socket.emit('join', {'username': 'test', 'room': '123456'});
      print("connected to server");
    });

    // 接收语音
    socketManager.socket.on('ai-text', _handleOtherData);
    socketManager.socket.on('data', _handleOtherData);
    super.initState();
  }

  void _handleOtherData(dynamic data) {
    print('Received other data: $data');
  }

  // //捕获后端返回的语音流数据，并播放
  // void _handleAudioData(dynamic data) async {
  //   // Handle audio data here
  //   print('Received audio data: $data');
  //   List<int> audioBytes = base64Decode(data);
  //   debugPrint('audioBytes: $audioBytes');
  //   Uint8List audioUint8List = Uint8List.fromList(audioBytes);
  //   // Play the audio using flutter_sound
  //   await _audioPlayer.openPlayer();
  //   // 播放Uint8List
  //   await _audioPlayer.startPlayer(
  //     fromDataBuffer: audioUint8List,
  //     codec: Codec.pcm16,
  //     numChannels: 1,
  //     sampleRate: 16000,
  //   );
  //   setState(() {
  //     _audioPlayer;
  //   });
  //   //await _audioPlayer.closePlayer();
  // }

  // 开启录音
  // void startRecorder() async {
  //   if (!kIsWeb) {
  //     var status = await Permission.microphone.request();
  //     if (status != PermissionStatus.granted) {
  //       throw RecordingPermissionException('Microphone permission not granted');
  //     }
  //   }
  //   await _audioRecorder.openRecorder();
  //   await _audioRecorder
  //       .setSubscriptionDuration(const Duration(milliseconds: 30));
  //   await _audioRecorder.startRecorder(
  //     codec: Codec.pcm16,
  //     toStream: audioStream.sink,
  //     numChannels: 1,
  //     sampleRate: 16000,
  //   );
  //   // 监听录音流
  //   _recorderSubscription = _audioRecorder.onProgress!.listen((e) {
  //     int now = DateTime.now().millisecondsSinceEpoch;
  //     //print("audio recorder: --------------" + e.toString());
  //     // 声音大于20db，更新非静默时间
  //     if (e.decibels! > 20) {
  //       lastNonZeroTime = DateTime.now().millisecondsSinceEpoch;
  //     }
  //     int silenceDuration = now - lastNonZeroTime;
  //     // 静默时间超过1.7s,停止录音并发送语音流
  //     if (silenceDuration > 1700) {
  //       stopRecorder();
  //       lastNonZeroTime = double.maxFinite.toInt();
  //     }
  //     setState(() {
  //       currentAmp = e.decibels!;
  //     });
  //   });
  //   // 读取语音流数据并写入缓存
  //   audioStream.stream.listen((buffer) {
  //     if (buffer is FoodData) {
  //       //print("audio recorder: --------------" + buffer.data!.toString());
  //       String audioData = base64Encode(buffer.data!);
  //       cacheAudio.add(audioData);
  //       //socketManager.emit('audio_data', base64Encode(buffer.data!));
  //     }

  //     //socketManager.emit('audio_data', base64Encode(event.buffer.asUint8List()));
  //   });
  // }

  // // 停止录音 并发送语音数据
  // void stopRecorder() {
  //   print("audio recorder: stopRecorder");
  //   _audioRecorder.stopRecorder();
  //   _recorderSubscription.cancel();
  //   print("audio recorder: stopRecorder end: ${cacheAudio.join('')}");
  //   socketManager
  //       .emit('stream_audio_test', {'username': 'test', 'room_id': '123456'});
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              //startRecorder();
              print("stream recorder: stream test");
              socketManager.socket.emit('stream_audio_test',
                  {'username': 'test', 'room_id': '123456'});
            },
            child: const Text('开始录音'),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                // /stopRecorder();
                socketManager.socket.emit('data', {
                  'username': 'test',
                  'room_id': '123456',
                  'data': "test data"
                });
              },
              child: const Text('停止录音')),
        ],
      ),
    );
  }
}
