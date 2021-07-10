import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:band_names/src/providers/socket_provider.dart';
import 'package:band_names/src/models/band_models.dart';



class HomePage extends StatefulWidget {
  //const DetailsPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    //new Band(id: '1', name: 'Metallica', votes: 5),
    //new Band(id: '2', name: 'Queen', votes: 4),
    //new Band(id: '3', name: 'Kiss', votes: 3),
    //new Band(id: '4', name: 'Red Hot Chilli Peppre', votes: 2),
  ];

  @override
  void initState() {
    _initActiveBand();
    super.initState();
  }

  @override
  void dispose() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.off('active-bands');
    super.dispose();
  }

  _initActiveBand(){
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);

    socketProvider.socket.on('active-bands', (payload) {
      
      this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
      setState(() {});

    });
  }

  @override
  Widget build(BuildContext context) {

    final socketProvider = Provider.of<SocketProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: (socketProvider.serverStatus == ServerStatus.Online)
            ? Icon(Icons.check_circle, color: Colors.blue[300],)
            : Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) =>  _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketProvider = Provider.of<SocketProvider>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ){
        //print('direction: $direction');
        socketProvider.socket.emit('delete-band', {'id':band.id});
      },
      background: Container(
        padding: EdgeInsets.only(left: 10.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(Icons.delete_forever_outlined, color: Colors.white,),
              SizedBox(width: 5.0,),
              Text('Delete Band', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20.0),),
        onTap: () => socketProvider.socket.emit('vote-band',{'id': band.id}),
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();

    if(Platform.isAndroid){
      //Android
      return showDialog(
        context: context, 
        barrierDismissible: false,
        builder: ( _ ) {
          return AlertDialog(
            title:Text('New Band Name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                textColor: Colors.blue,
                child: Text('Add'),
                elevation: 5.0,
                onPressed: () => addBandToList(textController.text)
              ),
              MaterialButton(
                textColor: Colors.red,
                child: Text('Dismiss'),
                elevation: 5.0,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('New Band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );

    
  }

  void addBandToList(String name){

    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    if(name.length > 1){
      //this.bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 4));
      socketProvider.socket.emit('add-band', {'name':name});
    }

    //setState(() {});

    Navigator.pop(context);
  }

  Widget _showGraph() {
    
    /*
    Map<String, double> dataMap = {
      "Flutter": 5,
    };
    */

    Map<String, double> dataMap = new Map();

    if(bands.length != 0)
    {
      bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
      });

      return Container(
        padding: EdgeInsets.only(left: 10.0),
        width: double.infinity,
        height: 300.0,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 2.2,
          //colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 20.0,
          centerText: "VOTES",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
        )
      );
    }

    return Container();
    
  }
}