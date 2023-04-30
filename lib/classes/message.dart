class Message {
  String mensaje;
  String usuario;
  DateTime fecha;
  bool? conexion;
  

  Message(this.mensaje, this.usuario, this.fecha);

  factory Message.fromJson(Map<String, dynamic> json) {
    if (json == null) {
    throw ArgumentError("Received null JSON data");
  }
  return Message(
    json['mensaje'] as String,
    json['usuario'] as String,
    json['fecha'] == null ? DateTime.now() : DateTime.parse(json['fecha'] as String),
  );
}

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mensaje': mensaje,
      'usuario': usuario,
      'fecha': fecha.toIso8601String(),
    };
  }
}