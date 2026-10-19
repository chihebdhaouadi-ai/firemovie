import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/home/blocs/home_bloc.dart';
import 'package:film_wise_mobile/home/blocs/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/core.dart';
import '../../../core/session.dart';
import 'package:film_wise_mobile/home/views/pages/home.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:convert';



class Movie_Page extends StatefulWidget {
  final String arg; // Assuming the argument is of type String

  Movie_Page({required this.arg});
  @override
  _Movie_Page createState() => _Movie_Page();
}

class _Movie_Page extends State<Movie_Page> with TickerProviderStateMixin {


  @override
  void initState() {
    BlocProvider
       .of<HomeBLoc>(context)
       .movie_detail_movies(detail_moviesTrigerState(id_movie: "${widget.arg}"));

         BlocProvider
       .of<ReviewBLoc>(context)
       .Get_Review_movies_movies(Review_MoviesTrigerState(token: Session.token,imdbid: "${widget.arg}"));
   BlocProvider
       .of<StreamBLoc>(context)
       .Get_Stream_movies(Stream_MoviesTrigerState(imdbid: "${widget.arg}"));

    super.initState();
  }
  @override
  void dispose() {
    // Ensure the controller is disposed when the State is disposed
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
  
    return  Scaffold(body: SingleChildScrollView(
      child: Column(children: [Container(
                    margin: EdgeInsets.only(top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () {Navigator.of(context).pop();                            },
                            icon: Icon(Icons.arrow_back_ios,
                                color: Color.fromARGB(255, 93, 90, 90)),
                          ),
                        ),
                   
                     
                      ],
                    ),
                  ),

   Container(


            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container( height:
                MediaQuery.of(context).size.width *
                    0.58,
                  width:
                  MediaQuery.of(context).size.width *
                      0.30,
                  decoration:
                  BoxDecoration(
                    color:Color.fromRGBO(8, 76, 128, 1),

                    borderRadius:
                    BorderRadius.circular(10.0), // Adjust the radius value as needed

                    boxShadow: [

                    ],
                  ),
                  child: 
                  
                  
                  
                    BlocBuilder<HomeBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Detail_moviesLoadedState) {
                                return    Container(
                    margin: EdgeInsets.all(8),

                    decoration:
                    BoxDecoration(
                      image:
                      DecorationImage(
                        image:
                        NetworkImage('${state.movie_data.imageLink}'), // Replace with your image path
                        fit: BoxFit
                            .cover,
                      ),
                      borderRadius:
                      BorderRadius.circular(10.0), // Adjust the radius value as needed

                      boxShadow: [

                      ],
                    ),
                  );
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: (SizeConfig.screenWidth!! * 134) / 450,
            width: SizeConfig.screenWidth!! * 0.22,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),
            
                ),
            Container(
              height:
              MediaQuery.of(context).size.width *
                  0.58,
              margin: EdgeInsets.fromLTRB(0,10,10,10),
              decoration:
              BoxDecoration(
                color:Color.fromRGBO(8, 76, 128, 1),

                borderRadius:
                BorderRadius.circular(10.0), // Adjust the radius value as needed

                boxShadow: [

                ],
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                Container(

                  width:  MediaQuery.of(context).size.width *
                      0.58,
                  child: Container(
                    decoration:
                    BoxDecoration(
                      color:Color.fromRGBO(26, 40, 50, 1),

                      borderRadius:
                      BorderRadius.circular(10.0), // Adjust the radius value as needed

                      boxShadow: [

                      ],
                    ),


                    margin: const EdgeInsets.fromLTRB(8.0,8,8,0),

                    padding: const EdgeInsets.fromLTRB(8,8,8,8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                             BlocBuilder<HomeBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Detail_moviesLoadedState) {
                                return     Row(
                          children: [


                            Text(
                              '${state.movie_data.title}',
                              style: TextStyle(
                                color: Color.fromARGB(
                                    255, 255, 255, 255), // Set the text color
                                fontFamily: 'Poppins', // Set the font family
                                fontWeight: FontWeight.w100, // Set the font weight
                                fontSize: 15, // Set the font size
                                height: 1.2,
                              ),
                            ),
                            Text(
                              '   ${state.movie_data.year}',
                              style: TextStyle(
                                color: Color.fromARGB(
                                    255, 217, 217, 217), // Set the text color
                                fontFamily: 'Poppins', // Set the font family
                                fontWeight: FontWeight.w100, // Set the font weight
                                fontSize: 10,
                                height: 1.2, // Set the font size
                              ),
                            ),
                          ],
                        );
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: 20,
            width: 300,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),

                                        BlocBuilder<HomeBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Detail_moviesLoadedState) {
                                return     Row(
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
                                                              ' ${state.movie_data.directedBy}',
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
                                );
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: 20,
            width: 300,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),
                      
                        
                      ],
                    ),
                  ),
                ),
                Container(

                  width:  MediaQuery.of(context).size.width *
                      0.58,
                  height: MediaQuery.of(context).size.width *
                      0.30 ,
                  child: Expanded(
                    child:  Container(
                      decoration:
                      BoxDecoration(
                        color:Color.fromRGBO(26, 40, 50, 1),

                        borderRadius:
                        BorderRadius.circular(10.0), // Adjust the radius value as needed

                        boxShadow: [

                        ],
                      ),

                      margin: const EdgeInsets.all(8.0),
                      padding:const EdgeInsets.all(8.0) ,

                      child: 
                      
                        BlocBuilder<HomeBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Detail_moviesLoadedState) {
                                return   Text("${state.movie_data.descritption}",
                        style: TextStyle(
                          color: Color.fromARGB(
                              255, 217, 217, 217), // Set the text color
                          fontFamily: 'Poppins', // Set the font family
                          fontWeight: FontWeight.w100, // Set the font weight
                          fontSize: 8,
                          height: 1.2, // Set the font size
                        ),
                      );
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: 200,
            width: 300,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),
                      
                     
                    ),
                  ),
                ),

                

                  Container(
                    width:  MediaQuery.of(context).size.width *
                        0.58,

                    child: Container(

                        decoration:
                        BoxDecoration(
                        color:Color.fromRGBO(26, 40, 50, 1),

                    borderRadius:
                    BorderRadius.circular(10.0), // Adjust the radius value as needed

                    boxShadow: [

                    ],
                  ),


              margin: const EdgeInsets.fromLTRB(8.0,0,8,0),

              padding: const EdgeInsets.fromLTRB(8,0,8,0),
                      child: 
                      
                      
                      
                      
                             BlocBuilder<HomeBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Detail_moviesLoadedState) {
                                return    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
       for (var i =0 ; i<options_movie_detail.length ; i++)
                     
                     
                     
                      Row(
                        children: [
                          GestureDetector(
                            onTap: (){
                                showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child:  Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
        
        [
          
          for (var k=0 ; k<state.movie_data.genres.length;k++)
          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${state.movie_data.genres[k]}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 217, 217, 217), // Set the text color
                                  fontFamily: 'Poppins', // Set the font family
                                  fontWeight: FontWeight.w400, // Set the font weight
                                  fontSize: 15,
                                  height: 1.2, // Set the font size
                                ),
                              ),
                            ),
        ]),
            
      ),
    );
 
  },
  
);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${options_movie_detail[i]}',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 217, 217, 217), // Set the text color
                                  fontFamily: 'Poppins', // Set the font family
                                  fontWeight: FontWeight.w100, // Set the font weight
                                  fontSize: 8,
                                  height: 1.2, // Set the font size
                                ),
                              ),
                            ),
                          ),
                          (i<3)?
                          Container(
                            color: Colors.grey,
                            height: 15,
                            width: 1,

                          ):SizedBox()

                        ],
                      ),
                                      ],);
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: 20,
            width: 300,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),
                      
                      
                    ),)
              ],),
            )

              ],
            ),
          ),

          Container( width: ( MediaQuery.of(context).size.width *
              0.95),
            decoration: BoxDecoration(
           //
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Color.fromRGBO(8, 76, 128, 1),
                width: 2.0,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                ( MediaQuery.of(context).size.width *
                    0.02),
                ( MediaQuery.of(context).size.height *
                    0.007),
                ( MediaQuery.of(context).size.width *
                    0.02),
                ( MediaQuery.of(context).size.height *
                    0.007)),
            child:
            Container(
              margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  
                  popupdashboardbutton(icon: BootstrapIcons.eye_fill ,text:"Watch" ,color:Color.fromARGB(255, 255, 255, 255) ,)
                  ,

            //      popupdashboardbutton(icon:   BootstrapIcons.star_half ,text:"Ratings" ,color:Color.fromARGB(255, 255, 255, 255) ,)
                  
                    BlocBuilder<ReviewBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Movie_Rating_moviesLoadedState) {
                                return  Column(children: [
                                      popupdashboardbutton(icon:   BootstrapIcons.star_half ,text:"Ratings" ,color:Color.fromARGB(255, 255, 255, 255) ,),
                                          Text(
                    '${state.movies_rating.moyen}/5',
                    style: TextStyle(
                      color: Color.fromARGB(
                          255, 217, 217, 217), // Set the text color
                      fontFamily: 'Poppins', // Set the font family
                      fontWeight: FontWeight.w300, // Set the font weight
                      fontSize: 10,
                      height: 1.2, // Set the font size
                    ),
                  ),
                                     
                                ],);
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: 20,
            width: 20,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),

                  popupdashboardbutton(icon:  BootstrapIcons.clock_fill,text:"Watchlist" ,color:Color.fromARGB(255, 255, 255, 255) ,)

                  ,

                ],
              ),
            ),
          ),
        

                  Container(

            width: ( MediaQuery.of(context).size.width *
                0.95),
            child:
            Container(
              margin: EdgeInsets.fromLTRB(50, 5, 10, 5),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [

          BlocBuilder<ReviewBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Movie_Rating_moviesLoadedState) {
                                return    Text(
                    'Ratings: ${state.movies_rating.count} filmwiser ',
                    style: TextStyle(
                      color: Color.fromARGB(
                          255, 217, 217, 217), // Set the text color
                      fontFamily: 'Poppins', // Set the font family
                      fontWeight: FontWeight.w100, // Set the font weight
                      fontSize: 10,
                      height: 1.2, // Set the font size
                    ),
                  );
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: 20,
            width: 20,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),


                
                ],
              ),
            ),
          ),



            Container(
            width: ( MediaQuery.of(context).size.width *
                0.95),
            decoration: BoxDecoration(
              color: Color.fromRGBO(8, 76, 128, 1),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Color.fromRGBO(8, 76, 128, 1),
                width: 2.0,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                ( MediaQuery.of(context).size.width *
                    0.02),
                ( MediaQuery.of(context).size.height *
                    0.007),
                ( MediaQuery.of(context).size.width *
                    0.02),
                ( MediaQuery.of(context).size.height *
                    0.007)),
            child:
            Container(

              margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                   /* for (var i=0; i < 5; i++)
              Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                  BootstrapIcons.star,
                  color: Colors.amber,
                  size: 30,
                              ),
                ),*/
                RatingBar(
   initialRating: 3,
   direction: Axis.horizontal,
   allowHalfRating: true,
   itemCount: 5,
   ratingWidget: RatingWidget(
     full: Image.asset('assets/heart.png',color: Colors.amber,),
     half:  Image.asset('assets/heart_half.png',color: Colors.amber,),
     empty:  Image.asset('assets/heart_border.png',color: Colors.amber,),
   ),
   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
   onRatingUpdate: (rating) {
     print(rating);
   },
)



                ],
              ),
            ),
          ),

             Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:  Color.fromARGB(
                                                                          255,
                                                                          26,
                                                                          40,
                                                                          50), // Replace with your desired background color
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0), // Adjust the radius value as needed
                                                                  ),
                                                                  width: (SizeConfig
                                                                          .screenWidth! *
                                                                      0.95),
                                                                  height: (SizeConfig
                                                                          .screenHeight! *
                                                                      0.105),
                                                                  margin: EdgeInsets.only(
                                                                      top: SizeConfig
                                                                              .screenWidth! *
                                                                          0.007),
                                                                  padding: EdgeInsets.fromLTRB(
                                                                      (SizeConfig
                                                                              .screenWidth !*
                                                                          0.009),
                                                                      (SizeConfig
                                                                              .screenHeight !*
                                                                          0.005),
                                                                      (SizeConfig
                                                                              .screenWidth! *
                                                                          0.009),
                                                                      (SizeConfig
                                                                              .screenHeight !*
                                                                          0.005)),
                                                                  child: Column(
                                                                    children: [
                                                                      Container(

                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                (SizeConfig.screenHeight! * 0.00)),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              8,
                                                                              76,
                                                                              124), // Replace with your desired background color
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0), // Adjust the radius value as needed
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              8,
                                                                              2,
                                                                              4,
                                                                              2),
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                "Where to watch ",
                                                                                style: TextStyle(
                                                                                  color: Color.fromARGB(255, 217, 217, 217), // Set the text color
                                                                                  fontFamily: 'Roboto', // Set the font family
                                                                                  fontWeight: FontWeight.w700, // Set the font weight
                                                                                  fontSize: (SizeConfig.screenWidth! * 10) / 384, // Set the font size
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                decoration: BoxDecoration(
                                                                                  color: Color.fromARGB(255, 26, 40, 50), // Replace with your desired background color
                                                                                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius value as needed
                                                                                ),
                                                                                padding: EdgeInsets.fromLTRB((SizeConfig.screenWidth! * 0.02), (SizeConfig.screenHeight! * 0.000), (SizeConfig.screenWidth! * 0.001), (SizeConfig.screenHeight! * 0.000)),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(top: 3),
                                                                                      child: Text(
                                                                                        "Trailer",
                                                                                        style: TextStyle(
                                                                                          color: Color.fromARGB(255, 217, 217, 217), // Set the text color
                                                                                          fontFamily: 'Roboto', // Set the font family
                                                                                          fontWeight: FontWeight.w700, // Set the font weight
                                                                                          fontSize: (SizeConfig.screenWidth! * 10) / 384, // Set the font size
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Icon(
                                                                                      BootstrapIcons.play_fill,
                                                                                      color: Color.fromARGB(255, 217, 217, 217),
                                                                                      size: 20,
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets.only(left: 10),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                                              "Friends Reviews",
                                                                                              textAlign:TextAlign.start,
                                                                                              style: TextStyle(
                                                                                                
                                                                                                color: Color.fromARGB(255, 191, 183, 183), // Set the text color
                                                                                                fontFamily: 'Roboto', // Set the font family
                                                                                                fontWeight: FontWeight.w200, // Set the font weight
                                                                                                fontSize: (SizeConfig.screenWidth! * 15) / 384, // Set the font size
                                                                                              ),
                                                                                              
                                                                                            ),
                                                                    ],
                                                                  ),
                                                                ),

BlocBuilder<ReviewBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                                 
                                   if (state is Movie_Rating_moviesLoadedState) {
                                return   
                                
                              Column(children: [
                                for (var i in state.movies_rating.reviews)
                            Column(
                              children: [
                                                              Container(
                                                                margin: EdgeInsets.all(5),
                                                                height: 1,
                                                                color: const Color.fromARGB(255, 71, 71, 71),
                                                                width:MediaQuery.of(context).size.width*0.9 ,
                                                              ),

                                Row(
                                                           children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                                    margin: EdgeInsets.all(8),
                                
                                                    decoration:
                                                    BoxDecoration(
                                                      image:
                                                      DecorationImage(
                                                        image:
                                                        NetworkImage('http://127.0.0.1:8000${i.image_link}'), // Replace with your image path
                                                        fit: BoxFit
                                .cover,
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(90.0), // Adjust the radius value as needed
                                
                                                      boxShadow: [
                                
                                                      ],
                                                    ),
                                                  ),
                                
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                                                        "Review by ",
                                                                                        style: TextStyle(
                                                                                          color: Color.fromARGB(255, 88, 99, 116), // Set the text color
                                                                                          fontFamily: 'Roboto', // Set the font family
                                                                                          fontWeight: FontWeight.w200, // Set the font weight
                                                                                          fontSize: (SizeConfig.screenWidth! * 8) / 384, // Set the font size
                                                                                        ),
                                                                                        
                                                                                      ),
                                
                                                           Text(
                                                                                        "${i.writer_name}",
                                                                                        style: TextStyle(
                                                                                          color: Color.fromARGB(255, 116, 116, 116), // Set the text color
                                                                                          fontFamily: 'Roboto', // Set the font family
                                                                                          fontWeight: FontWeight.w400, // Set the font weight
                                                                                          fontSize: (SizeConfig.screenWidth! * 8) / 384, // Set the font size
                                                                                        ),
                                                                                        
                                                                                      ),
                                
                                   Text(
                                                                                        " on",
                                                                                        style: TextStyle(
                                                                                          color: Color.fromARGB(255, 88, 99, 116), // Set the text color
                                                                                          fontFamily: 'Roboto', // Set the font family
                                                                                          fontWeight: FontWeight.w200, // Set the font weight
                                                                                          fontSize: (SizeConfig.screenWidth! * 8) / 384, // Set the font size
                                                                                        ),
                                                                                        
                                                                                      ),
                                 Text(
                                                                                        "${i.data}  ",
                                                                                        style: TextStyle(
                                                                                          color: Color.fromARGB(255, 116, 116, 116), // Set the text color
                                                                                          fontFamily: 'Roboto', // Set the font family
                                                                                          fontWeight: FontWeight.w400, // Set the font weight
                                                                                          fontSize: (SizeConfig.screenWidth! * 8) / 384, // Set the font size
                                                                                        ),
                                                                                        
                                                                                      ),                                                          
                                                      ],
                                                    ),
                                      Container(
                                        width:MediaQuery.of(context).size.width*0.5 ,
                                        child: Expanded(
                                          child: Text(
                                                                                            "${i.body}  ",
                                                                                            style: TextStyle(
                                                                                              color: Color.fromARGB(255, 217, 217, 217), // Set the text color
                                                                                              fontFamily: 'Roboto', // Set the font family
                                                                                              fontWeight: FontWeight.w400, // Set the font weight
                                                                                              fontSize: (SizeConfig.screenWidth! * 10) / 384, // Set the font size
                                                                                            ),),
                                        ),
                                      )
                                                                                        
                                
                                                  ],),
                                
                                        SizedBox(width: 20,),
                                                  Row(
                                                    
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,        
                                
                                
                                             children: [
                                        Column(
                                          
                                          children: [
                                             Text(
                                                                                            "like?",
                                                                                            style: TextStyle(
                                                                                              color: Color.fromARGB(255, 217, 217, 217), // Set the text color
                                                                                              fontFamily: 'Roboto', // Set the font family
                                                                                              fontWeight: FontWeight.w400, // Set the font weight
                                                                                              fontSize: (SizeConfig.screenWidth! * 10) / 384, // Set the font size
                                                                                            ),),
                                            Icon(
                                              BootstrapIcons.hand_thumbs_up_fill,
                                              color: const Color.fromARGB(255, 151, 151, 151),
                                              size: 20,
                                            ),
                                
                                                          Text(
                                                                                            "${i.likes}",
                                                                                            style: TextStyle(
                                                                                              color: Color.fromARGB(255, 217, 217, 217), // Set the text color
                                                                                              fontFamily: 'Roboto', // Set the font family
                                                                                              fontWeight: FontWeight.w400, // Set the font weight
                                                                                              fontSize: (SizeConfig.screenWidth! * 10) / 384, // Set the font size
                                                                                            ),),
                                          ],
                                        ),
                                SizedBox(width: 20,),
                                            Column(
                                              children: [
                                                Text(
                                                                                            "Dislike?",
                                                                                            style: TextStyle(
                                                                                              color: Color.fromARGB(255, 217, 217, 217), // Set the text color
                                                                                              fontFamily: 'Roboto', // Set the font family
                                                                                              fontWeight: FontWeight.w400, // Set the font weight
                                                                                              fontSize: (SizeConfig.screenWidth! * 10) / 384, // Set the font size
                                                                                            ),),
                                                Icon(
                                                          BootstrapIcons.hand_thumbs_down_fill,
                                                          color: const Color.fromARGB(255, 88, 88, 116),
                                                          size: 20,
                                                        ),
                                
                                   Text(
                                                                                            "${i.Disliles}  ",
                                                                                            style: TextStyle(
                                                                                              color: Color.fromARGB(255, 217, 217, 217), // Set the text color
                                                                                              fontFamily: 'Roboto', // Set the font family
                                                                                              fontWeight: FontWeight.w400, // Set the font weight
                                                                                              fontSize: (SizeConfig.screenWidth! * 10) / 384, // Set the font size
                                                                                            ),),
                                              ],
                                            ),
                                                  
                                                      
                                
                                                  ], )
                                
                                                           ],
                                ),
                              ],
                            )


                              ],);
                               
                                                                }
                                                                
                                        
                                                                                                    
                                   
                                  return    SizedBox(
                                    
            height: 20,
            width: 20,
            child: Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 30, 30, 30),
              highlightColor: const Color.fromARGB(255, 8, 79, 128),
              child: Container(
                margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                width: SizeConfig.screenWidth!! * 0.22,
                height: (SizeConfig.screenWidth!! * 134) / 450,
                color: Colors.white,
              ),
            ),
          );
                                                                                                         },
                                        ),


                                                            

      ],)));

  }
}