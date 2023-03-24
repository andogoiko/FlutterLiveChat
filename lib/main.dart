import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  final IOWebSocketChannel _channel =
      IOWebSocketChannel.connect('ws://10.0.2.2:6666/ws');

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      _channel.sink.add(jsonEncode({'message': _textController.text}));
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_messages[index]),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: _textController,
                      decoration:
                          InputDecoration.collapsed(hintText: 'Send a message'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _channel.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        final message = decoded['message'];
        setState(() {
          _messages.add(message);
        });
      },
      onError: (error) {
        print('Error: $error');
      },
      onDone: () {
        print('Connection closed');
      },
    );
  }
}
