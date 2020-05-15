import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pesquisagifs/ui/GifPage.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offset = 0;

  int _getCount(List data){
    if(_search==null){
      return data.length;
    }else{
      return data.length + 1;
    }
  }

  Future<Map> _getGif()async{
    http.Response response;
    if(_search == null || _search.isEmpty){
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=qVM744LdzdPRH42zT6jcmDUmIF0mRe74&limit=20&rating=G");
    }else{
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=qVM744LdzdPRH42zT6jcmDUmIF0mRe74&q=$_search&limit=190&offset=$_offset&rating=G&lang=en");
    }
    return json.decode(response.body);
  }

 Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
  return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10
      ),
      itemCount: _getCount(snapshot.data["data"]),//organização dos itens
      itemBuilder: (context, index){
        if(_search == null || index<snapshot.data["data"].length ){
          return GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GifPage(snapshot.data["data"][index])
              ));
            },
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        }else{
          return Container(
            child: GestureDetector(
              onTap: (){
                setState(() {
                  _offset += 19;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    size: 70,
                  ),
                  Text(
                      "Carregar mais...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22
                    ),
                  )
                ],
              ),
            ),
          );
        }

      }
  );
 }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGif().then((map){

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onSubmitted: (texto){
                setState(() {
                  _search = texto;
                  _offset = 0;
                });
              },
              decoration: InputDecoration(
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(
                  color: Colors.white
                ),
                border: OutlineInputBorder()
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGif(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if(snapshot.hasError) {
                      return Container();
                    }else {
                      return _createGifTable(context,snapshot);
                    }

                }
              },
            ),
          )
        ],
      ),
    );
  }
}
