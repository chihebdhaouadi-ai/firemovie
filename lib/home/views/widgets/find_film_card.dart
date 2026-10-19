import 'package:film_wise_mobile/home/views/widgets/home_add_movies_dialog.dart';
import 'package:flutter/material.dart';
import 'package:film_wise_mobile/home/blocs/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../core/session.dart';
import '../../blocs/home_state.dart';
import '../../data/top_5_movies_entity.dart';
import '../pages/film_page.dart';
class CustomHeroTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const CustomHeroTransition({
    required this.animation,
    required this.child,
  });


  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation.drive(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ),
      ),
      child: child,
    );
  }
}

class Findcard extends StatefulWidget {
    final String film_id;

  final String filmname;
  final String year;
  final String directed;
  final String imageurl;
    final String come_from;


  Findcard(
      {
              required this.film_id,

        required this.filmname,
      required this.year,
      required this.directed,
      required this.imageurl,
         required this.come_from});

  @override
  _Findcard createState() => _Findcard();
}

class _Findcard extends State<Findcard> with TickerProviderStateMixin {
  
  bool opacityanimation = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      Future.delayed(Duration(seconds: 1), () {
   setState(() {
      opacityanimation=true;
    });  });

  }

  @override
  Widget build(BuildContext context) {
    return             AnimatedOpacity(
    //  opacity: opacityanimation ?1:0,
      duration: Duration(seconds: 1),
      opacity: 1,
      child: GestureDetector(
        onTap: (){
          print(widget.come_from);

if(widget.come_from == "top_5_movies")
          showDialog(
  context: context,
  builder: (BuildContext contex1) {
    return Add_Movies_CustomDialog(message: 'add ${widget.filmname} top your top 5 movies ', buttonColor: Color.fromARGB(255, 0, 122, 206), buttonText: 'ADD IT',come_from: "top_5_movies",movie_id: "${widget.film_id}",context__: context,);

  },
  
);
if(widget.come_from == "watched_list")
{
            showDialog(
  context: context,
  builder: (BuildContext contex1) {
    return Add_Movies_CustomDialog(message: 'add ${widget.filmname} top your watched  list ', buttonColor: Color.fromARGB(255, 0, 122, 206), buttonText: 'ADD IT',come_from: "watched_list",movie_id: "${widget.film_id}",context__: context,);

});
}

if(widget.come_from == "watchlist")
{
            showDialog(
  context: context,
  builder: (BuildContext contex1) {
    return Add_Movies_CustomDialog(message: 'add ${widget.filmname} top your watch list ', buttonColor: Color.fromARGB(255, 0, 122, 206), buttonText: 'ADD IT',come_from: "watchlist",movie_id: "${widget.film_id}",context__: context,);

});
}


                /*      showDialog(
  context: context,
  builder: (BuildContext context1) {
  return  Dialog(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        height: 150,
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "add ${widget.filmname} top your top 5 movies ",
                style: TextStyle(color: const Color.fromARGB(255, 217, 217, 217), fontSize: 13),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (widget.come_from =="top_5_movies")
                  {
                   print("eooo");
  BlocProvider
       .of<HomeBLoc>(context)
       .Add_List_movies_movies(Add_List_MoviesTrigerState(
        add_List_Movies_Entity:Add_List_Movies_Entity(token: Session.token,movie_id: "${widget.film_id}",come_from: "top_5_movies",)
         ));
                  }
                  
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 122, 206),
                  primary: const Color.fromARGB(255, 216, 216, 216), // Button color
                ),
                child: Text(
                  "ADD IT",
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
       */   
          print("lora");
      /*       Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                FilmPage(imageurl: "${widget.imageurl}",),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return CustomHeroTransition(
                  animation: animation,
                  child: child,
                );
              },
            ),
          );
          */
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              decoration: BoxDecoration(
                color: Color.fromARGB(0, 6, 94, 153),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
              child: Row(
                children: [
                  Hero(
                    tag: "tag1",
                    child:
                    
                    
                   Container(
            margin: EdgeInsets.fromLTRB(5, 0, 10, 5),
            height: (SizeConfig.screenHeight!! * 45) / 384,
            width: (SizeConfig.screenWidth!! * 60) / 384,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8, // Set the blur radius
                  // Set the spread radius
                  offset: Offset(0, 2), // Set the offset
                ),
              ],
              image: DecorationImage(
                image: NetworkImage("${widget.imageurl}"),
                fit: BoxFit.cover,
              ),
            )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: "texttagtitle",
                              child: Text(
                                '${widget.filmname}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 255, 255, 255), // Set the text color
                                  fontFamily: 'Poppins', // Set the font family
                                  fontWeight: FontWeight.w300, // Set the font weight
                                  fontSize: 15, // Set the font size
                                  height: 0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:5.0),
                              child: Text(
                                '  ${widget.year}',
                                style: TextStyle(
                                  
                                  color: Color.fromARGB(
                                      255, 217, 217, 217), // Set the text color
                                  fontFamily: 'Poppins', // Set the font family
                                  fontWeight: FontWeight.w100, // Set the font weight
                                  fontSize: 10,
                                  height: 0, // Set the font size
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Directed by',
                              style: TextStyle(
                                color: Color.fromARGB(
                                    255, 217, 217, 217), // Set the text color
                                fontFamily: 'Poppins', // Set the font family
                                fontWeight: FontWeight.w100, // Set the font weight
                                fontSize: 12,
                                height: 1.2, // Set the font size
                              ),
                            ),
                             Text(
                              ' ${widget.directed}',
                              style: TextStyle(
                                color: Color.fromARGB(
                                    255, 217, 217, 217), // Set the text color
                                fontFamily: 'Poppins', // Set the font family
                                fontWeight: FontWeight.w300, // Set the font weight
                                fontSize: 12,
                                height: 1.2, // Set the font size
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 2),
              height: 1,
              color: Color.fromARGB(255, 71, 71, 71),
              width: SizeConfig.screenWidth!! - 20,
            ),
          ],
        ),
      ),
    );
  }
}


