import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/src/providers/socket_provider.dart';


class StatusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final socketProvider = Provider.of<SocketProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ServerStatus: ${socketProvider.serverStatus}')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          socketProvider.socket.emit('desdeflutter',{'Nomnre':'Salome Castro'});
        },
        child: Icon(Icons.send),
      ),
   );
  }
}