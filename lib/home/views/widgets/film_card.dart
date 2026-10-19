import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/core.dart';
import '../../../core/session.dart';
import '../../blocs/home_state.dart';
import '../../data/top_5_movies_entity.dart';


class Filmcard extends StatefulWidget {
  final String imagePath;
  final bool loaded;
  final String filmname;
  final String film_id;
    final String come_from;


  Filmcard( {
    Key? key,
    required this.imagePath,
    required this.loaded,
        required this.filmname,
        required this.film_id,
        required this.come_from,

  }) : super(key: key);

  @override
  _FilmcardState createState() => _FilmcardState();
}

class _FilmcardState extends State<Filmcard> with TickerProviderStateMixin  {
 // late final AnimationController _animationController_popup;
 bool show_arrow=false;
  @override
  void initState() {
    super.initState();
    // Initialization logic goes here
  /*  _animationController_popup = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return widget.loaded
        ? widget.come_from == "popular_list" ? 
        GestureDetector(
          onTap: (){

            print("object");
          },
          child: Slidable(
             
              child: Container(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    onTap: () {
                      print("handle");
                      // Handle the onTap event
                    },
                  
                  ),
                ),
                margin: EdgeInsets.fromLTRB(5, 0, 5, 4),
                height: (SizeConfig.screenWidth!! * 134) / 450,
                width: SizeConfig.screenWidth!! * 0.22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 0, 0, 0),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        )
        :Slidable(
            direction: Axis.vertical,
            startActionPane: ActionPane(
              motion: StretchMotion(),
              children: [
                SlidableAction(
                  backgroundColor: Color.fromARGB(199, 184, 21, 0),
                  icon: Icons.delete,
                  onPressed: (context2) {
                   

                      showDialog(
  context: context,
  builder: (BuildContext context1) {
  return  Dialog(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        height: 150,
        width: widget.come_from =="watched_list"?  500.0 : 300.0,
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (widget.come_from == "top_5_movies") ? " DELETE ${widget.filmname} from your top 5 movies ":
                 (widget.come_from == "watched_list") 
                 ? " DELETE ${widget.filmname} from your watched list movies " : (widget.come_from =="watchlist")? "DELETE ${widget.filmname} from your watch list movies ":"",
                style: TextStyle(color: const Color.fromARGB(255, 217, 217, 217), fontSize: 13),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {


print("top_5_movies");


if (widget.come_from == "top_5_movies")
BlocProvider
       .of<HomeBLoc>(context)
       .Delete_List_movies_movies(Delete_List_MoviesTrigerState(add_List_Movies_Entity: Add_List_Movies_Entity(token: Session.token,movie_id: "${widget.film_id}",come_from: "${widget.come_from}")  ));




if (widget.come_from == "watched_list")
BlocProvider
       .of<WatchedBLoc>(context)
       .Delete_List_movies_movies(Delete_List_MoviesTrigerState(add_List_Movies_Entity: Add_List_Movies_Entity(token: Session.token,movie_id: "${widget.film_id}",come_from: "${widget.come_from}")  ));




if (widget.come_from == "watchlist")
BlocProvider
       .of<WatchtlistBLoc>(context)
       .Delete_List_movies_movies(Delete_List_MoviesTrigerState(add_List_Movies_Entity: Add_List_Movies_Entity(token: Session.token,movie_id: "${widget.film_id}",come_from: "${widget.come_from}")  ));




                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(199, 184, 21, 0),
                ),
                child: Text(
                  "Delete IT",
                  style: TextStyle(color: const Color.fromARGB(255, 217, 217, 217)), // Button text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
  
);

                  },
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: GestureDetector(
                  onTap: () {
 
 print("clicket");
 
                   },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: (){
                                  setState(() {
                                                              show_arrow=true;

                              });
                          
                               Future.delayed(Duration(seconds: 2), () {
    print("Code executed after 2 seconds");
    setState(() {
                                                              show_arrow=false;

                              });
  });

                            },
                            child: Icon(
                              BootstrapIcons.three_dots_vertical,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    show_arrow?  Center(
                        child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(136, 33, 149, 243), // Change this color to your desired color
              BlendMode.srcIn,),
                          child: Lottie.asset("assets/arrow.json",
                              ),
                        ),
                      ):SizedBox(),
                    ],
                  ),
                ),
              ),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 4),
              height:  widget.come_from  == "watched_list" ? (SizeConfig.screenWidth!! ) : (SizeConfig.screenWidth!! * 134) / 450 ,
              width:  widget.come_from  == "watched_list" ? SizeConfig.screenWidth!! * 0.4 :  SizeConfig.screenWidth!! * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 0, 0, 0),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : SizedBox(
            height: (SizeConfig.screenWidth!! * 134) / 450,
            width: SizeConfig.screenWidth!! * 0.22,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 4),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
  }


}