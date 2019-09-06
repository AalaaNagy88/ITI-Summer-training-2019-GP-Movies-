import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'favorite.dart';
import 'package:toast/toast.dart';
import 'package:connectivity/connectivity.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {"/next": (context) => next_screen(),"/fav":(context)=>fav_screen()},
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyState();
  }
}
//Global list
var List_movie = [];
var List_favorite = [];


class MyState extends State<HomePage> {

  check_connectivity() async {
    return await Connectivity().checkConnectivity().toString();
  }

  getMovies() async {
    final res = await get(
        "https://api.themoviedb.org/3/movie/popular?api_key=d032214048c9ca94d788dcf68434f385");
    Map movie = json.decode(res.body);
    setState(() {
      List_movie = movie['results'];
    });
  }

  getfav() {
    favorite().retrieveData().then((res) {
      setState(() {
        List_favorite = res;
      });
    });
  }

  String _connectionStatus;
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectionSubscription;

  @override
  void initState() {
    getMovies();
    getfav();
    super.initState();
    _connectionSubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            _connectionStatus = result.toString();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    //connecting network desgin
    if (_connectionStatus == "ConnectivityResult.wifi"||_connectionStatus == "ConnectivityResult.mobile" ) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Movies"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  getfav();
                  Navigator.pushNamed(context, '/fav',);
                }),
            IconButton(icon: Icon(Icons.refresh), onPressed: () => getMovies())
          ],
        ),
        body: GridView.count(
          crossAxisCount: 2,
          children: List.generate(List_movie.length, (index) {
            return GestureDetector(
                child: Card(
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Image.network(
                            "http://image.tmdb.org/t/p/w500${List_movie[index]['poster_path']}",
                            height: 115,
                          ),
                          Center(
                              child: Text("${List_movie[index]["title"]}")),
                        ],
                      ),
                    )),
                onTap: () {
                  Navigator.pushNamed(context, '/next',
                      arguments: List_movie[index]);
                });
          }),
        ),
      );
    }
//    //No connection display user favorite
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Movies"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  MyState3();
                }),
            IconButton(icon: Icon(Icons.refresh), onPressed: () => getMovies())
          ],
        ),
        body:List_favorite.length==0
            ?Center(child: Text("No movies in your favorite list"),)
            : GridView.count(
                crossAxisCount: 2,
                children: List.generate(List_favorite.length, (index) {
                  return GestureDetector(
                      child: Card(
                          child: Center(
                        child: Column(
                          children: <Widget>[
                            Image.network(
                              "http://image.tmdb.org/t/p/w500${List_favorite[index]['poster_path']}",
                              height: 115,
                            ),
                            Center(
                                child:
                                    Text("${List_favorite[index]["title"]}")),
                          ],
                        ),
                      )),
                      onTap: () {
                        Navigator.pushNamed(context, '/next',
                            arguments: List_favorite[index]);
                      });
                }),
              ),
      );
    }
  }
}
//===============================================Movie screen============================================
class next_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyState2();
  }
}

//open the movie discribtions
class MyState2  extends State<next_screen>{
  @override
  Widget build(BuildContext context) {
    Map myChocie = ModalRoute.of(context).settings.arguments;
    var x=Saved_in_myDB(List_favorite,myChocie);
    return Scaffold(
        appBar: AppBar(
          title: Text(myChocie['title']),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Image.network(
                "http://image.tmdb.org/t/p/w500${myChocie['poster_path']}",
                height: 200,
                width: MediaQuery.of(context).size.width,
              ),
              Center(child: Text("${myChocie["title"]}\n\n${myChocie["overview"]}",textAlign: TextAlign.center,)),
              IconButton(
                icon: Icon(x==true?Icons.favorite:Icons.favorite_border,color:x==true? Colors.red:null,),
                onPressed: () {
                  if(x==true){
                    favorite().deletRow(myChocie).then((res){Toast.show("Deleted", context,);});
                  }else{
                    favorite().addRow(myChocie).then((res){Toast.show("Saved ", context,);});
                  }
                  getfav();
                  MyState2();
                },
              )
            ],
          ),
        ));
  }
  getfav() {
    favorite().retrieveData().then((res) {
      setState(() {
        List_favorite = res;
      });
    });
  }

  bool Saved_in_myDB(List<Map> list,Map item){
    for(int i=0;i<list.length;i++) {
      if (list[i]["id"] == item["id"]) return true;
    }
    return false;
  }
}
//===================================================Favorite screen===============================================
class fav_screen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyState3();
  }

}

class MyState3 extends State<fav_screen>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      appBar: AppBar(
        title: Text("My Favorite"),
      ),
      body:List_favorite.length==0
      ?Center(child: Text("No movies in your favorite list"),)
      :GridView.count(
        crossAxisCount: 2,
        children: List.generate(List_favorite.length, (index) {
          return GestureDetector(
              child: Card(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Image.network(
                          "http://image.tmdb.org/t/p/w500${List_favorite[index]['poster_path']}",
                          height: 115,
                        ),
                        Center(
                            child:
                            Text("${List_favorite[index]["title"]}")),
                      ],
                    ),
                  )),
              onTap: () {
                Navigator.pushNamed(context, '/next',
                    arguments: List_favorite[index]);
              });
        }),
      ),
    );
  }
}