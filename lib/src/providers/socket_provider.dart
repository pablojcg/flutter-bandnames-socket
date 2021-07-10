import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


enum ServerStatus{
  Online,
  Offline,
  Connecting
}

class SocketProvider with ChangeNotifier
{
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;


  SocketProvider(){
    this._initConfig();
  }

  void _initConfig(){

    // Dart client
    this._socket = IO.io('http://192.168.20.59:3000/',IO.OptionBuilder()
      .setTransports(['websocket'])
      .enableAutoConnect()
      .build()
    );

    this._socket.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
      //socket.emit('msg', 'test');
    });

    //socket.on('event', (data) => print(data));

    this._socket.onDisconnect((_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    //socket.on('fromServer', (_) => print(_));

    this._socket.on('nuevo-mensaje', ( payload ) {
      print('nuevo-mensaje: $payload');
      print('nombre: ' + payload['nombre']);
      print('mensaje: ' + payload['mensaje']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No hay Mensaje');
      print(payload['mensaje2'] ?? 'No hay Nada 2!!');
    });




  }

}