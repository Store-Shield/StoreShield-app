import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveCctvStreamView extends StatefulWidget {
  const LiveCctvStreamView({super.key});

  @override
  State<LiveCctvStreamView> createState() => _LiveCctvStreamViewState();
}

class _LiveCctvStreamViewState extends State<LiveCctvStreamView> {
  IO.Socket? socket;
  String? _base64Image;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io('https://5fbc-223-194-130-45.ngrok-free.app', {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
    });

    socket!.onConnect((_) {
      _startImagePolling();
    });

    socket!.on('update', (data) {
      setState(() {
        _base64Image = data['image'];
      });
    });

    socket!.connect();
  }

  void _startImagePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      socket!.emit('request_update');
    });
  }

  Uint8List? decodeBase64Image(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) return null;
    if (base64Image.startsWith('data:image')) {
      base64Image = base64Image.split(',').last;
    }
    return base64Decode(base64Image.replaceAll(RegExp(r'\s+'), ''));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decodedImage = decodeBase64Image(_base64Image);

    return decodedImage != null
        ? Image.memory(decodedImage, fit: BoxFit.cover)
        : const Center(child: Text('영상 수신 중...'));
  }
}
