import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/home/data/home_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../blocs/home_bloc.dart';
import '../../blocs/home_state.dart';
import '../pages/add_find_film.dart';

class AppBarActionItems extends StatelessWidget {
  GlobalKey<ScaffoldState> drawerKey;

  AppBarActionItems({
    required this.drawerKey,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       Container(
          margin: EdgeInsets.only(bottom: 7),
          child: IconButton(
              onPressed: () {
                drawerKey.currentState?.openDrawer();
              },
              icon: Icon(BootstrapIcons.list,
                  size: 35, color: Color.fromARGB(255, 93, 90, 90))),
        ),

        //SizedBox(width: (SizeConfig.screenWidth!! * 50)/384),
      //  SizedBox(width: (SizeConfig.screenWidth!! * 115) / 500),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => RepositoryProvider<HomeRepo>(
          
        create: (context) => HomeRepo(),
        child: BlocProvider<HomeBLoc>(
          
          create:(context)=>HomeBLoc(context.read<HomeRepo>()) ,
          child: BlocListener<HomeBLoc,Top_5_moviesState>(
            listener: (context,state){  

            }
            ,child: Find()),)),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = Offset(1.0, 0);
                  var end = Offset.zero;
                  var tween = Tween(begin: begin, end: end);
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
          child:  Hero(
                                      tag: "findicon",
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                width: (SizeConfig.screenWidth!! * 60) / 500,
                child: Padding(
                  padding: const EdgeInsets.only(bottom:15),
                  child: Icon(
                    BootstrapIcons.search,
                    color: Color.fromARGB(255, 93, 90, 90),
                    size: 35,
                  ),
                )),
          ),
        )
      ],
    );
  }
}
