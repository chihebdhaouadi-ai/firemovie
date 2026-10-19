import 'package:film_wise_mobile/home/blocs/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/home_bloc.dart';
import '../../data/top_5_movies_entity.dart';
import '../../../core/session.dart';

class Add_Movies_CustomDialog extends StatelessWidget {
  final String message;
  final Color buttonColor;
  final String buttonText;
    final String come_from;
    final String movie_id;
BuildContext context__;
  

  Add_Movies_CustomDialog({required this.message, required this.buttonColor, required this.buttonText, required this.come_from,required this.movie_id,required this.context__});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        height: 200,
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
 if (come_from =="top_5_movies")
                  {
  BlocProvider
       .of<HomeBLoc>(context__)
       .Add_List_movies_movies(Add_List_MoviesTrigerState(
        add_List_Movies_Entity:Add_List_Movies_Entity(token: Session.token,movie_id: "${movie_id}",come_from: "top_5_movies")
         ));
                  }


     if (come_from == "watched_list")
                        {
  BlocProvider
       .of<HomeBLoc>(context__)
       .Add_List_movies_movies(Add_List_MoviesTrigerState(
        add_List_Movies_Entity:Add_List_Movies_Entity(token: Session.token,movie_id: "${movie_id}",come_from: "watched_list")
         ));
                  }  
 
     if (come_from == "watchlist")
                        {
  BlocProvider
       .of<HomeBLoc>(context__)
       .Add_List_movies_movies(Add_List_MoviesTrigerState(
        add_List_Movies_Entity:Add_List_Movies_Entity(token: Session.token,movie_id: "${movie_id}",come_from: "watchlist")
         ));
                  }                   

                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  buttonColor, // Button color
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(color: Colors.white,fontSize: 10), // Button text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
