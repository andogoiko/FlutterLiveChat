import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'classes/message.dart';
import 'package:intl/intl.dart';

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
        debugShowCheckedModeBanner: false,
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
                    decoration: InputDecoration.collapsed(
                        hintText: 'Escoge tu nombre de usuario'),
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
      debugShowCheckedModeBanner: false,
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
          Message(widget._textController.text, widget.username, DateTime.now());
      Map<String, dynamic> data = message.toJson();
      widget._channel.sink.add(jsonEncode(data));
      widget._textController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    final message =
          Message(widget.username + " Se ha conectado", "Sistema", DateTime.now());
      Map<String, dynamic> data = message.toJson();
      widget._channel.sink.add(jsonEncode(data));

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
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget._messages.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      UnconstrainedBox(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Color.fromARGB(255, 255, 194, 214)
                                : Color.fromARGB(255, 182, 182, 182),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 100,
                            maxWidth: MediaQuery.of(context).size.width - 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                widget._messages[index].usuario,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget._messages[index].mensaje,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('HH:mm')
                                        .format(widget._messages[index].fecha)
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(4),
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
