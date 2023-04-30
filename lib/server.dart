import 'dart:convert';
import 'dart:io';

import 'classes/message.dart';

void main() => server().start();

class server {
  List<WebSocket> lClientes = [];

  Future<void> start() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 6666);
    print('Server iniciado en ${server.address}:${server.port}');

    await for (var request in server) {
      if (request.uri.path == '/ws') {
        WebSocketTransformer.upgrade(request).then((webSocket) {
          print(
              'Cliente conectado desde ${request.connectionInfo!.remoteAddress.address}:${request.connectionInfo!.remotePort}');
          lClientes.add(webSocket);

          webSocket.listen(
            (data) {
              final Map<String, dynamic> json = jsonDecode(data);
              final Message message = Message.fromJson(json);
              print(
                  'El cliente (${request.connectionInfo!.remoteAddress.address}:${request.connectionInfo!.remotePort}) ha enviado el siguiente mensaje: ${message.mensaje}');
              _broadcast(message, webSocket);
            },
            onDone: () {
              print(
                  'El cliente ${request.connectionInfo!.remoteAddress.address}:${request.connectionInfo!.remotePort} se ha desconectado');
              lClientes.remove(webSocket);
            },
            onError: (error) {
              print(
                  'Error del cliente ${request.connectionInfo!.remoteAddress.address}:${request.connectionInfo!.remotePort}: $error');
              lClientes.remove(webSocket);
            },
          );
        });
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      }
    }
  }

  void _broadcast(Message message, [WebSocket? exclude]) {
    for (var client in lClientes) {
      //if (client != exclude) { // quitanto esto le mandamos a todos el mensaje, al que lo envió incluído, dejamos esto para futuras confirmaciones de mensaje enviado
      client.add(jsonEncode(message.toJson()));
      //}
    }
  }
}
