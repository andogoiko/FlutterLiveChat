import 'dart:io';

import 'dart:async';

void main() async {
Socket sock;

try {
sock = await Socket.connect('localhost', 6666);
} catch (e) {
print('Error connecting to server: $e');
return;
}

final hilo = Thread(() async {
final scanner = Scanner(System.in);
String mensaje;
OutputStream outputStream;
BufferedWriter writer;
bool vacio;

while (true) {
  try {
    mensaje = scanner.nextLine();
    vacio = true;

    outputStream = sock.getOutputStream();
    writer = BufferedWriter(new OutputStreamWriter(outputStream));

    for (int i = 0; i < mensaje.length; i++) {
      if (mensaje[i] != ' ') {
        vacio = false;
      }
    }

    if (!vacio) {
      await writer.write(mensaje);
      await writer.newLine();
      await writer.flush();
    }
  } catch (e) {
    throw RuntimeException(e);
  }
}

});

hilo.start();

InputStream inputStream = sock.getInputStream();
BufferedReader reader = BufferedReader(new InputStreamReader(inputStream));

String str;

while ((str = await reader.readLine()) != null) {
print(str);
}
}