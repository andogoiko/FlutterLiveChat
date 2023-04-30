import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'classes/message.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatefulWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  String _username = '';

  void _setUsername(String username) {
    setState(() {
      _username = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_username.isEmpty) {
      return MaterialApp(
        title: 'Set username',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Set username'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: widget._textController,
                    decoration:
                        InputDecoration.collapsed(hintText: 'Escoge tu nombre de usuario'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _setUsername(widget._textController.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatWindow(username: _username),
                      ),
                    );
                  },
                  child: Text('Accept'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Chat Window',
      home: ChatWindow(username: _username),
    );
  }
}

class ChatWindow extends StatefulWidget {
  final String username;

  final TextEditingController _textController = TextEditingController();
  final List<Message> _messages = [];
  final IOWebSocketChannel _channel =
      IOWebSocketChannel.connect('ws://10.0.2.2:6666/ws');

  ChatWindow({
    required this.username,
  });

  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  void _sendMessage() {
    if (widget._textController.text.isNotEmpty) {
      final message =
          Message(widget._textController.text, 'John', DateTime.now());
      Map<String, dynamic> data = message.toJson();
      widget._channel.sink.add(jsonEncode(data));
      widget._textController.clear();
    }
  }

  @override
  void initState() {
    super.initState();

    widget._channel.stream.listen(
      (data) {
        final Map<String, dynamic> json = jsonDecode(data);
        final Message message = Message.fromJson(json);
        setState(() {
          widget._messages.add(message);
        });
      },
      onError: (error) {
        print('Error: $error');
      },
      onDone: () {
        print('Conexión perdida');
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    widget._channel.sink.close();
    widget._textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensajería Palomino'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              itemCount: widget._messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.username + ": " + widget._messages[index].mensaje),
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
                    controller: widget._textController,
                    decoration:
                        InputDecoration.collapsed(hintText: 'Envía un mensaje'),
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
    );
  }
}
