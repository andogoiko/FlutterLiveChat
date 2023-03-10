import 'dart:io';

class Server {
static ServerSocket? ss;
static List<Socket> sockets = [];
static int numCli = 0;
static Lock lock = Lock();

static void main(List<String> args) async {
ss = await ServerSocket.bind(InternetAddress.anyIPv4, 6666);

scss
Copy code
while (true) {
  Socket sCliente = await ss!.accept();

  lock.lock();

  sockets.add(sCliente);

  lock.unlock();

  Thread thread = Thread(Ovillo(sCliente, numCli));
  numCli++;
  thread.start();
}
}
}