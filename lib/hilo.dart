import 'dart:io';

import 'package:concurrent/executor.dart';

import 'server.dart';

class hilo implements Runnable {
Socket shocko;
int numCli;
bool deleteOld = false;

hilo(this.shocko, this.numCli);

@override
void run() async {
BufferedReader bR;
try {
bR = BufferedReader(new InputStreamReader(shocko.getInputStream()));

String queDice;

  while ((queDice = await bR.readLine()) != null) {
    print("Lo que cuenta el cliente NÂª$numCli: $queDice");

    String finalQueDice = queDice;

    Server.lock.lock();

    try {
      Server.sockets.forEach((socket) async {
        try {
          if (socket.isConnected) {
            BufferedWriter bufferedWriterSock =
                BufferedWriter(new OutputStreamWriter(socket.getOutputStream()));
            await bufferedWriterSock.write(
                "Lo que me cuenta el cliente NÂª$numCli: $finalQueDice");
            await bufferedWriterSock.newLine();
            await bufferedWriterSock.flush();
          }
        } on SocketException catch (e) {
          deleteOld = true;
          print("casca");
          e.message;
        } on IOException catch (e) {
          e.message;
        }
      });

      if (deleteOld) {
        deleteOld = false;
        // Server.sockets.removeWhere((s) => s == shocko);
      }
    } on ConcurrentModificationException catch (y) {
      y.printStackTrace();
    }

    Server.lock.unlock();
  }
} on SocketException catch (e) {
  Server.lock.lock();
  // Server.sockets.removeWhere((s) => s == shocko);
  Server.lock.unlock();
} on IOException catch (e) {
  e.message;
}
}
}