import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/home/data/home_repo.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';

import '../../../core/core.dart';
import '../../blocs/home_bloc.dart';
import '../../blocs/home_state.dart';
import '../../data/top_5_movies_entity.dart';
import '../widgets/find_film_card.dart';
import '../widgets/side_menu.dart';

class Film {
  final String id;
  final String name;
  final String year;
  final String imageUrl;
  final String director;

  Film({
    required this.id,
    required this.name,
    required this.year,
    required this.imageUrl,
    required this.director,
  });
}

class Find extends StatefulWidget {
  final String param;

  // Constructor with a named parameter 'param'
  Find({Key? key, this.param = "noparam"}) : super(key: key);

  @override
  _Find createState() => _Find();
}

class _Find extends State<Find> with TickerProviderStateMixin {

  List<String> listItems = <String>["textt12","textt22354"]; 
  TextEditingController _textEditingController = TextEditingController();

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  late AnimationController _controller;
  late Animation<double> _animation;
  List<bool> d = [false, false, false];
  List<bool> g = [false, false, false, false, false, false];
  bool find = false;
  bool show_under_list = false;
  String value = 'Initial Value';

  List<Film> Films = [];

  Future<Film> fetch_data(ch) async {
    final Map<String, String> headers = {
      'X-RapidAPI-Key': '',
      'X-RapidAPI-Host': 'online-movie-database.p.rapidapi.com'
    };
    final Map<String, String> params = {
      'title': '${ch}',
      'limit': '3',
      'sortArg': 'moviemeter,asc'
    };
    final uri = Uri.https(
        'online-movie-database.p.rapidapi.com', '/title/v2/find', params);
    List<Film> _Films = [];

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          find = true;
        });
        if (jsonDecode(response.body).containsKey("results")) {
          for (var filmData in jsonDecode(response.body)["results"]) {
            if (filmData['titleType'] == "movie") {
              var id = filmData['id'].toString();
              var name = filmData['title'];

              var image = filmData['image']["url"];
              var year = filmData['year'].toString();
              String extractedValue = id.split('/').elementAt(2);

              final Map<String, String> _params = {
                'tconst': '${extractedValue}',
              };
              final _uri = Uri.https('online-movie-database.p.rapidapi.com',
                  '/title/get-full-credits', _params);
              try {
                final _response = await http.get(_uri, headers: headers);

                if (_response.statusCode == 200) {
                  var dir =
                      jsonDecode(_response.body)["crew"]["director"][0]["name"];
                  var director = dir;

                  Film film = Film(
                    id: id,
                    name: name,
                    year: year,
                    imageUrl: image,
                    director: director,
                  );
                  _Films.add(film);

                  print("dircc ${dir}");
                }
              } catch (error) {
                print('Error2: $error');
                setState(() {
                  find = false;
                });
                setState(() {
                  Films = _Films;
                });
              }

              print(extractedValue);
            }

            /*   Film film = Film(
            id: filmData['id'],
            name: filmData['name'],
            year: filmData['year'],
            imageUrl: filmData['image']["url"],
            director: filmData['director'],
          );
          Films.add(film);*/
          }
          setState(() {
            find = false;
          });
          setState(() {
            Films = _Films;
          });
        }

        final x = Film(
            id: "15",
            name: "te",
            director: "tt",
            imageUrl: "tet",
            year: "2015");
        return x;
      } else {
        setState(() {
          Films = _Films;
          find = false;
        });
        print('Request failed with status1: ${response.statusCode}');
        final x =
            Film(id: "0", name: "0", director: "0", imageUrl: "0", year: "0");
        return x;
      }
    } catch (error) {
      print('Error1: $error');
      setState(() {
        Films = _Films;
        find = false;
      });
      final x =
          Film(id: "0", name: "0", director: "0", imageUrl: "0", year: "0");
      return x;
    }
  }

  void auto_complete(ch) async {
    print(ch);
    if (ch.length > 5) final Film x = await fetch_data(ch);
  }

  void handleValueChanged(String newValue) {
    setState(() {
      value = newValue;
    });
  }/*

  addfilm(filmname, filmid, filmimageUrl, filmyear, filmdirector) async {
    print(widget.arg);

    final apiUrl = 'http://127.0.0.1:8000/films/add_film_generate';
    final jsonBody = jsonEncode({
      "index": "${widget.arg}",
      'filmname': filmname,
      'filmid': filmid,
      'filmimageUrl': filmimageUrl,
      'filmyear': filmyear,
      'filmdirector': filmdirector,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody,
      );
      print(response.statusCode);
    } catch (e) {
      print("errer ${e}");
    }
  }*/

  @override
  void initState() {
    super.initState();

    print(widget.param);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _drawerKey,
      drawer: SideMenu(
        key: null,
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          height: 900,
          color: Color.fromARGB(255, 20, 20, 20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () {
Navigator.of(context).pop();                            },
                            icon: Icon(Icons.arrow_back_ios,
                                color: Color.fromARGB(255, 93, 90, 90)),
                          ),
                        ),
                   
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            width: (SizeConfig.screenWidth!! * 60) / 500,
                            child: Icon(
                              Icons.search,
                              color: Color.fromARGB(0, 93, 90, 90),
                              size: 10,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                    height: 1,
                    color: Color.fromARGB(255, 71, 71, 71),
                    width: SizeConfig.screenWidth!! - 20,
                  ),
                if(widget.param =="noparam")
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                    child:SingleChildScrollView(
                      dragStartBehavior: DragStartBehavior.start,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                  //        for (var i in top_bar_search)
                   /*         Container(
                      
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                    if(i["is_active"])    BoxShadow(
                      color: Colors.blue.withOpacity(0.5), // Blue shadow color with opacity
                      blurRadius: 30.0, // Adjust the blur radius as needed
                                        ),
                                      ],
                                    ),
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 8),
                              child: ElevatedButton(
                                
                                  style: ElevatedButton.styleFrom(
                                    
                                    foregroundColor: Colors
                                        // ignore: deprecated_member_use
                                        .white, primary: !i["is_active"]
                                        ? Color.fromARGB(0, 0, 122, 204)
                                        : Color.fromARGB(240, 2, 154,
                                            255), // Set the text color of the button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          28), // Set the border radius of the button
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      i["is_active"] = !i["is_active"];
                      
                                       show_under_list= i["is_active"];
                      
                      
                          for (var k in top_bar_search){
                            if (k["btn_string"] != i["btn_string"]){
                              if (i["is_active"] ==true)
                                {
                                k["is_active"] = !i["is_active"]; if (i["btn_string"]!="Films")
                                                                         show_under_list= false;


                                }else{

                                }
                      
                            }
                          }
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Text(
                                            "${i["btn_string"]}",
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 255, 255,
                                                  255), // Set the text color
                                              fontFamily:
                                                  'Poppins', // Set the font family
                                              fontWeight: FontWeight
                                                  .w500, // Set the font weight
                                              fontSize: 12, // Set the font size
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                    */    ],
                      ),
                    ),
                  ),

if(show_under_list)

 Container( alignment: Alignment.centerLeft,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (var r in top_bar_searchfilm)
                         Container(
                      
                      
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                    if(r["is_active"])    BoxShadow(
                                      spreadRadius: 0.1,
                      color: Colors.blue.withOpacity(0.4), // Blue shadow color with opacity
                      blurRadius: 8.0, // Adjust the blur radius as needed
                                        ),
                                      ],
                                    ),
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 18),
                              child: ElevatedButton(
                                
                                  style: ElevatedButton.styleFrom(
                                    
                                // Set the text color of the button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          28), // Set the border radius of the button
                                    ),
                                  ),
                                  onPressed: () {
                                           setState(() {
                                      r["is_active"] = !r["is_active"];
             
                      
                      
                          for (var k in top_bar_searchfilm){
                            if (k["btn_string"] != r["btn_string"]){
                              if (r["is_active"] ==true)
                                k["is_active"] = !r["is_active"];
                      
                            }
                          }
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Text(
                                            "${r["btn_string"]}",
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 255, 255,
                                                  255), // Set the text color
                                              fontFamily:
                                                  'Poppins', // Set the font family
                                              fontWeight: FontWeight
                                                  .w500, // Set the font weight
                                              fontSize: 12, // Set the font size
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                      ),
                    ),
                  ),



                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 3.5),
                                margin: EdgeInsets.only(top: 2),
                                width: SizeConfig.screenWidth! - 20,
                                height: 37,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 26, 40, 50),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(196, 3, 3, 3)
                                          .withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: "findicon",
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 2, 0, 0),
                                          child: Icon(
                                            Icons.search,
                                            color: Color.fromARGB(255, 1, 116, 229),
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0),
                                        child: TextFormField(
                                          controller: _textEditingController,
                                          onChanged: (String value) {},
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 217, 218, 219)),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Search',
                                            hintStyle: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 15,
                                              color: Color.fromARGB(
                                                  255, 85, 96, 110),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(255, 6, 94,
                                              153), // Set the background color of the button
                                          foregroundColor: Colors
                                              .white, // Set the text color of the button
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30), // Set the border radius of the button
                                          ),
                                        ),
                                        onPressed: () {
                                     /*   auto_complete(
                                              _textEditingController.text);*/
                                      
                                      
                                      
       BlocProvider
       .of<HomeBLoc>(context)
       .find_movies_movies(Find_MoviesTrigerState(
        find_Movies_Entity:Find_Movies_Entity(title: '${_textEditingController.text}' )
         ));
                                        },
                                        child: const Text(
                                          'Submit',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 217, 218, 219)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


/*
Autocomplete<String>(
  onSelected: ( x){

  },
  
  optionsBuilder: (TextEditingValue textEditingValue) {

             if(textEditingValue == ""){
              return const Iterable.empty();

             }
             return listItems.where((item) {
              return item.contains(textEditingValue.text.toLowerCase());
             } ) ;

}),
*/
                             


    Padding(
      padding: const EdgeInsets.all(0.0),
      child: Center(
                                           child: BlocBuilder<HomeBLoc,Top_5_moviesState>(
                                              builder: (context, state)  {
            if (state is Find_MoviesLoadingState) {
return    Center(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(136, 33, 149, 243), // Change this color to your desired color
              BlendMode.srcIn,
            ),
            child: Lottie.asset(
              'assets/film_loading.json',
              height: 50,
              width: 70,
            ),
          ),
        );

            }

             if (state is Find_MoviesLoadedState) {
           return   Column(children: [
              for (var i = 0; i < state.find_movies_retrun.length; i++)
                FutureBuilder(
                  future: Future.delayed(Duration(seconds: 1 * i)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return BlocProvider<HomeBLoc>(
          
          create:(context)=>HomeBLoc(context.read<HomeRepo>()) ,
          child: BlocListener<HomeBLoc,Top_5_moviesState>(
            listener: (context,state){  

             
               if ( state is Add_List_Movies_Done_State ){

                Navigator.pushReplacementNamed(context, '/home' ,arguments:{'param_load':'top_5_movies_add','status':'${state.add_List_Movies_Model.status}','message':'${state.add_List_Movies_Model.message}'} );          



                                                               
                                     }            
            



            }
            ,child:   Findcard(
                          film_id: state.find_movies_retrun[i].movies_id,
                          filmname: state.find_movies_retrun[i].title,
                          year: state.find_movies_retrun[i].year,
                          directed: state.find_movies_retrun[i].directed_by,
                          imageurl: state.find_movies_retrun[i].image_link,
                          come_from: "${widget.param}",
                        ),),);
                      
                      
                      /*GestureDetector(
                        onTap: (){/*
                             if (widget.param =="top_5_movies")
                  {
                    BlocProvider
       .of<HomeBLoc>(context)
       .Add_List_movies_movies(Add_List_MoviesTrigerState(
        add_List_Movies_Entity:Add_List_Movies_Entity(movie_id: "${state.find_movies_retrun[i].movies_id}",come_from: "${widget.param}" )
         ));

                  }
                  
                  Navigator.pop(context);*/

                        },
                        child: 
                        
                        Findcard(
                          film_id: state.find_movies_retrun[i].movies_id,
                          filmname: state.find_movies_retrun[i].title,
                          year: state.find_movies_retrun[i].year,
                          directed: state.find_movies_retrun[i].directed_by,
                          imageurl: state.find_movies_retrun[i].image_link,
                          come_from: "top_5_movies",
                        ),
                      );*/
                    } else {
                      return SizedBox(); // Placeholder while waiting
                    }
                  },
                ),
            ],);
             
        
            }
        return SizedBox();
      },
                                                       ),
                                         ),
    ),
                          /*    ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: /*Films.length*/ 10,
                                itemBuilder: (context, index) {
                                 
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  
                                },
                              ),*/
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
           
      
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
