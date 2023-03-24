import 'dart:convert';
import 'dart:io';

class server {
  List<WebSocket> lClientes = [];

  Future<void> start() async {
    final server = await HttpServer.bind('localhost', 6666);
    print('Server iniciado en ${server.address}:${server.port}');

    await for (var request in server) {
      if (request.uri.path == '/ws') {
        WebSocketTransformer.upgrade(request).then((webSocket) {
          print(
              'Cliente conectado desde ${request.connectionInfo!.remoteAddress.address}:${request.connectionInfo!.remotePort}');
          lClientes.add(webSocket);

          webSocket.listen(
            (data) {
              final message = utf8.decode(data).trim();
              print(
                  'El cliente (${request.connectionInfo!.remoteAddress.address}:${request.connectionInfo!.remotePort}) ha enviado el siguiente mensaje: $message');
              _broadcast('$message\n', webSocket);
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

  void _broadcast(String message, [WebSocket? exclude]) {
    for (var client in lClientes) {
      if (client != exclude) {
        client.add(utf8.encode(message));
      }
    }
  }
}
