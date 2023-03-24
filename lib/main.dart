import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  final channel = IOWebSocketChannel.connect('ws://localhost:6666');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mensajería Palomino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContainerChat(channel: channel),
    );
  }
}

class ContainerChat extends StatefulWidget {
  final IOWebSocketChannel channel;

  const ContainerChat({Key? key, required this.channel}) : super(key: key);

  @override
  _ContainerChatState createState() => _ContainerChatState();
}

class _ContainerChatState extends State<ContainerChat> {
  final _textController = TextEditingController();
  final _messages = <String>[];

  @override
  void initState() {
    super.initState();

    // escucha los mensajes del server.
    widget.channel.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();

    super.dispose();
  }

  void _sendMessage() {
    final message = _textController.text;
    widget.channel.sink.add(message);
    _textController.clear();
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
            ),
            onSubmitted: (value) => _sendMessage(),
          ),
        ],
      ),
    );
  }
}
