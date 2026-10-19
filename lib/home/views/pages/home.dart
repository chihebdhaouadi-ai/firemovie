import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/home/blocs/home_bloc.dart';
import 'package:film_wise_mobile/home/blocs/home_state.dart';
import 'package:film_wise_mobile/home/data/home_repo.dart';
import 'package:film_wise_mobile/home/data/top_5_movies_entity.dart';
import 'package:film_wise_mobile/home/views/widgets/top_icons_bar_nav_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'dart:convert';

import '../../../core/core.dart';
import '../../../core/session.dart';
import '../widgets/add_film_card.dart';
import '../widgets/app_bar_action_items.dart';
import '../widgets/film_card.dart';
import '../widgets/generated_card.dart';
import '../widgets/list_card.dart';
import '../widgets/side_menu.dart';
import 'add_find_film.dart';
import 'film_page.dart';
const itemSize = 150.0;

class Generatecard {
  final String name;
  final String imageUrl;

  Generatecard({
    required this.name,
    required this.imageUrl,
  });
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  late AnimationController _controller;
  late Animation<double> _animation;
  List<bool> cardgenerate = [false, false, false];
  var c = Generatecard(name: "", imageUrl: "");
  List<Generatecard> cardlist = [];
  bool generateload = true;
    final scrollController = ScrollController();
        final scrollController1 = ScrollController();
        final scrollController2 = ScrollController();

       late  bool loaded_top_5=false;
  late  bool callint=false;
bool alertshowet = true;
  fetch_generates() async {
  }

  void onListen() {
    setState(() {});
  }
   void onListen1() {
    setState(() {});
  }
    void onListen2() {
    setState(() {});
  }
    TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onListen);
    scrollController1.addListener(onListen1);
    scrollController2.addListener(onListen2);
if (!callint){
       BlocProvider
       .of<HomeBLoc>(context)
       .load_top_5_movies(Top_5_moviesTrigerState(
        top_5_Movies_Entity:Top_5_Movies_Entity(token: Session.token )
         ));
//

       BlocProvider
       .of<WatchedBLoc>(context)
       .watched_list_movies(Watched_list_moviesTrigerState(
        top_5_Movies_Entity:Top_5_Movies_Entity(token: Session.token )
         ));

      BlocProvider
       .of<WatchtlistBLoc>(context)
       .watch_list_movies(Watched_list_moviesTrigerState(
        top_5_Movies_Entity:Top_5_Movies_Entity(token: Session.token )
         ));
         setState(() {
           callint=true;
         });
           BlocProvider
       .of<PopularlistBLoc>(context)
       .get_popular_list_list_movies(Watched_list_moviesTrigerState(
        top_5_Movies_Entity:Top_5_Movies_Entity(token: Session.token )
         ));
         setState(() {
           callint=true;
         });
}

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    fetch_generates();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

      Map<String, dynamic>? arguments =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (arguments != null) {
        String? status = arguments['status'] as String?;

    String? param_load = arguments['param_load'] as String?;
    String? message = arguments['message'] as String?;

    if (param_load != null) {

      if(status == "200"){
          if(alertshowet){
      Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          content: Text(
                                  '${message}',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 48, 255, 33), // Set the text color
                                    fontFamily:
                                        'Montserrat', // Set the font family
                                    fontWeight:
                                        FontWeight.w400, // Set the font weight
                                    fontSize: 12, // Set the font size
                                  ),
                                ),
        ),
      );
    });
    setState(() {
      alertshowet=false;
    });
    }
      }

   

      }
      


      // You don't need 'await' here since build method cannot be marked as 'async'

    }





    return Scaffold(
      key: _drawerKey,
      drawer: SideMenu(),
      endDrawer:new Drawer(
              elevation: 10,

        child: Container(color: Color.fromARGB(255, 30, 30, 30),
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
   Container(
    color: const Color.fromARGB(255, 26, 40, 50),


                              padding: const EdgeInsets.fromLTRB(5, 30, 5, 15),
                              child: Row(
                                children: [
                                  Icon(Icons.notifications),
                                  Text(
                                    'NOTIFICATIONS',
                                    style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 216, 216, 216), // Set the text color
                                      fontFamily:
                                          'Montserrat', // Set the font family
                                      fontWeight:
                                          FontWeight.w400, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  ),
                                ],
                              ),
                            ),
 Container(
  padding: EdgeInsets.all(10),
   child: Expanded(
     child: Container(
     
       child: Expanded(
         child: Container(

           child: Row(children: [
                                                                  Container(
                                                                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                                    decoration: BoxDecoration(
                                                                     color: const Color.fromARGB(255, 26, 40, 50),
                                                                     
                                                                      borderRadius: BorderRadius.circular(20)),
                                                                    padding: EdgeInsets.all(10),
                                                                    child: Icon(BootstrapIcons.heart_fill,size: 10,)),
               Container(
                        width: 200,

                 child: Text(
                                                '[Saliimjbeli001] Liked your movie recommendation ‘Pulp fiction’.',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 216, 216, 216), // Set the text color
                                                  fontFamily:
                                                      'Montserrat', // Set the font family
                                                  fontWeight:
                                                      FontWeight.w400, // Set the font weight
                                                  fontSize: 8, // Set the font size
                                                ),
                                              ),
               ),
           
                  
           
           ],),
         ),
       ),
     ),
   ),
 ),



        ]),
        
        )),
      
      
      
      
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 10,
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomScrollView(

                      slivers: [
SliverAppBar(
  collapsedHeight: 120,
  automaticallyImplyLeading: false,
  primary: false,
  expandedHeight: 120,
  backgroundColor: Color.fromARGB(255, 30, 30, 30),
pinned: true,
floating: true,
 actions: [
                Visibility(
                  visible: false,
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Your button's onPressed logic here
                    },
                  ),
                ),
              ],
flexibleSpace: FlexibleSpaceBar(
  
  titlePadding: EdgeInsets.all(0),
  title:  Container(
    color: Color.fromARGB(255, 30, 30, 30),
    child: Column(
      children: [
        Stack(
                                children: [
                                  
                                  AppBarActionItems(
                                    drawerKey: _drawerKey,
                                  ),
                                  
                                ],
                              ),
      
          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    top_icons_bar_nav_home(icon_data: BootstrapIcons.gift_fill ,text: "9999 Points",come_from_key: "point",),
                                        SizedBox(
                                        width: (SizeConfig.screenWidth!! * 6) /
                                            500),
                                    Column(
                                      children: [
                                        Container(
                                          height: 19,
                                          width: 3,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 121, 121, 121),
                    
                                            borderRadius: BorderRadius.circular(
                                                10), // Set the desired border radius value
                                            border: Border.all(
                                                width: 1,
                                                color: Colors
                                                    .black), // Border properties
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        width: (SizeConfig.screenWidth!! * 6) /
                                            500),
                                
                         GestureDetector(
                          onTap: (){
showModalBottomSheet(context: context, builder: (BuildContext buildcontext){

return Container(
  height: 500,
  child: Column(children: [
     Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(166, 158, 158, 158),
        borderRadius:BorderRadius.circular(20.0)),
      margin: EdgeInsets.fromLTRB(50,10,50,5),
      height: 5,),
      Text(
                                    'ONE SUGGESTION AT A TIME!',
                                    style: TextStyle(
                                      color: Color.fromARGB(200, 216, 216, 216), // Set the text color
                                      fontFamily:
                                          'Montserrat', // Set the font family
                                      fontWeight:
                                          FontWeight.w300, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  ),
SizedBox(height: 2,),
                                        Text(
                                    'SEND A MOVIE SUGGESTION TO YOUR FRIENDS',
                                    style: TextStyle(
                                      color: Color.fromARGB(250, 216, 216, 216), // Set the text color
                                      fontFamily:
                                          'Montserrat', // Set the font family
                                      fontWeight:
                                          FontWeight.w400, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  ),

                                  Container(
                          margin: EdgeInsets.fromLTRB( 0,1,0,3),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),

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




  ]),
);
});

                          },
                           child: top_icons_bar_nav_home(icon_data:  BootstrapIcons
                                                          .send_plus_fill ,text: "Send a film",come_from_key: "send_film",),
                         ),
                    
                                 
                                  
                                   
                                   
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                    
                                 
                                  },
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                                margin:
                                                    EdgeInsets.only(right: 0),
                                                child: Center(
                                                                child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  const Color.fromARGB(136, 33, 149, 243), // Change this color to your desired color
                                  BlendMode.srcIn,
                                ),child: Lottie.network("https://lottie.host/14d5e02e-201f-4649-be8d-5d995beb1959/Ba8dehPGRF.json",height: 42,width: 42)),
                                                               )
                                              ),
                                         
                                        ],
                                        ),
                                      
                                     
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                 
                                    Column(
                                      children: [
                              
                                      
                                      ],
                                    ),
                                   
                                    GestureDetector(
                                      onTap: () {
                    
                                        /*
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                messages_list(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              var begin = Offset(-1.0,
                                                  0); // Change the begin offset to start from the left
                                              var end = Offset.zero;
                                              var tween =
                                                  Tween(begin: begin, end: end);
                                              var offsetAnimation =
                                                  animation.drive(tween);
                    
                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      */
                                      
                                      },
                                      child: 
                                      
                                       top_icons_bar_nav_home(icon_data:    BootstrapIcons
                                                          .envelope_fill,text: "Messages",come_from_key: "message",),
                                     
                                    ),
                                    SizedBox(
                                        width: (SizeConfig.screenWidth! * 6) /
                                            500),
                                    Column(
                                      children: [
                                        Container(
                                          height: 19,
                                          width: 3,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 121, 121, 121),
                    
                                            borderRadius: BorderRadius.circular(
                                                10), // Set the desired border radius value
                                            border: Border.all(
                                                width: 1,
                                                color: Colors
                                                    .black), // Border properties
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: (){
 print("gg");                                     },
                                      child: SizedBox(
                                          width: (SizeConfig.screenWidth!! * 5) /
                                              500),
                                    ),
                    
 GestureDetector(
          onTap: (){
                _drawerKey.currentState?.openEndDrawer();
          },
             child: top_icons_bar_nav_home(icon_data:    BootstrapIcons.bell_fill,text: "Notifications",come_from_key: "notifications",)),
                                  
                                     
                                    ],
                                )
                                ,
                                
                              ],
                            ),
                          ),
                         
                         
      
      ],
    ),
  ),
),

),

             SliverList(delegate: SliverChildBuilderDelegate(
              (BuildContext context_1,int index){
                return Column(children:[
                                                                      
                       
                     Container(
                          margin: EdgeInsets.fromLTRB( 0,1,0,3),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 3),
                              child: Text(
                                'MY TOP 5 FAVORITE FILMS',
                                style: TextStyle(
                                  color: Color.fromARGB(
                                      255, 88, 99, 116), // Set the text color
                                  fontFamily:
                                      'Montserrat', // Set the font family
                                  fontWeight:
                                      FontWeight.w400, // Set the font weight
                                  fontSize: 12, // Set the font size
                                ),
                              ),
                            ),
                            SafeArea(
                              child: Container(
                                height:  SizeConfig.screenHeight!!*0.15,width: SizeConfig.screenWidth!!*0.99,
                                child: CustomScrollView(
                                  scrollDirection: Axis.horizontal,
                                          controller: scrollController,
                                
                                  slivers: [BlocBuilder<HomeBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                /*   if (state is Top_5_moviesLoadingState) {
                                                             
                                  return Row(children: [
                                                             
                                    for ( var i = 0 ; i<4 ; i ++)
                                                                
                                                                 Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                     key: null,
                                     imagePath: '',
                                     loaded: false,
                                     
                                   ),
                                                             
                                    ],);
                                   }
                                      */                       
                                   if (state is Top_5_moviesLoadedState) {
                                  
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < state.top_5_movies_retrun.length) {
                            final heightFactor = 0.6;
                            final character = state.top_5_movies_retrun[index];
                            final itemPositionOffset = index * itemSize * heightFactor;
                            final difference = scrollController.offset - itemPositionOffset;
                            final percent = 1.0 - (difference / (itemSize * heightFactor));
                            double opacity = percent;
                  
                            if (opacity > 1.0) opacity = 1.0;
                            if (opacity < 0.0) opacity = 0.0;
                  
                            double scale = percent * 1.2;
                            if (percent > 1.0) scale = 1.0;
                            if (scale > 1.0) scale = 1.0;
                  
                            return   MultiBlocProvider(
                    providers: [
                      BlocProvider<HomeBLoc>(
                        create: (context) => HomeBLoc(context.read<HomeRepo>()),
                      ),
                      BlocProvider<WatchedBLoc>(
                        create: (context) => WatchedBLoc(context.read<HomeRepo>()),
                        child: BlocListener<WatchedBLoc,Top_5_moviesState>(listener: (context, state) {
                    
                        },),
                      ),
                      BlocProvider<WatchtlistBLoc>(
                        create: (context) => WatchtlistBLoc(context.read<HomeRepo>()),
                        child: BlocListener<WatchtlistBLoc,Top_5_moviesState>(listener:(context, state) {
                                print(state);
                           if ( state is Delete_List_Movies_Done_State )
                      Navigator.pushReplacementNamed(context, '/home' ,arguments:{'param_load':'top_5_movies_delete','status':'${state.add_List_Movies_Model.status}','message':'${state.add_List_Movies_Model.message}'} );          
                  
                        },
                        
                        ),
                        
                      ), 
                    ],
                    child: BlocListener<HomeBLoc, Top_5_moviesState>(
                      listener: (context, state) {
                         if ( state is Delete_List_Movies_Done_State )
                      Navigator.pushReplacementNamed(context, '/home' ,arguments:{'param_load':'top_5_movies_delete','status':'${state.add_List_Movies_Model.status}','message':'${state.add_List_Movies_Model.message}'} );          
                  
                        // Your listener logic here
                      },
                      child:GestureDetector(
                        onTap: (){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context_, animation, secondaryAnimation) => MultiBlocProvider(
                        providers: [
                          RepositoryProvider<HomeRepo>(
                            create: (context) => HomeRepo(),
                          ),
                          BlocProvider<HomeBLoc>(
                            create: (context) => HomeBLoc(context.read<HomeRepo>()),
                          ),
                            BlocProvider<ReviewBLoc>(
                            create: (context) => ReviewBLoc(context.read<HomeRepo>()),
                          ),

                             BlocProvider<StreamBLoc>(
                            create: (context) => StreamBLoc(context.read<HomeRepo>()),
                          ),
                        ],
                        child: Movie_Page(arg: "${character.movies_id}"),
                      ),
                      transitionsBuilder: (
                        context_,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
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
                        child: Opacity(
                                opacity: opacity,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..scale(1.0, 1.0),
                                  child:  Filmcard(come_from:'top_5_movies',film_id:"${character.movies_id}",filmname:"${character.title}",
                                    key: null,
                                    imagePath: '${character.image_link}',
                                    loaded: true,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                          } else {
                            // Handle the case where the index is out of bounds
                            return add_film_card(come_from: "top_5_movies");
                          }
                        },
                        childCount: 5,
                      ),
                    );
                  }
                  
                                        
                                                                                                    
                                   
                                  return  SliverList(
                                     delegate: SliverChildBuilderDelegate(
                                       (context, index) {
                                         
                                                             
                                                             
                                         return   Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,);
                                       },
                                       childCount: 5 ,
                                     ),
                                   );
                                                                                                         },
                                        ),
                                                               
                                                             ] ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth!! - 20,
                        ),
                             Text(
                                  "Pick Up To 3, We'll Recommend The Cinematic Key!",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 217, 217,
                                        217), // Set the text color
                                    fontFamily:
                                        'Poppins', // Set the font family
                                    fontWeight: FontWeight
                                        .w400, // Set the font weight
                                    fontSize:
                                        (SizeConfig.screenWidth!! * 13) /
                                            384, // Set the font size
                                  ),
                                ),
                   

    SafeArea(
                              child: Container(
                                height:  SizeConfig.screenHeight!!*0.4,width: SizeConfig.screenWidth!!*0.99,
                                child: CustomScrollView(
                                  scrollDirection: Axis.horizontal,
                                          controller: scrollController2,
                                
                                  slivers: [BlocBuilder<WatchedBLoc,Top_5_moviesState>(
                                                                                                    builder: (context, state)  {
                                /*   if (state is Top_5_moviesLoadingState) {
                                                             
                                  return Row(children: [
                                                             
                                    for ( var i = 0 ; i<4 ; i ++)
                                                                
                                                                 Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                     key: null,
                                     imagePath: '',
                                     loaded: false,
                                     
                                   ),
                                                             
                                    ],);
                                   }
                                      */                       
                                   if (state is Watched_List_moviesLoadedState) {
                                  
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < state.Watched_List_movies_retrun.length) {
                            final heightFactor = 0.6;
                            final character = state.Watched_List_movies_retrun[index];
                            final itemPositionOffset = index * itemSize * heightFactor;
                            final difference = scrollController.offset - itemPositionOffset;
                            final percent = 1.0 - (difference / (itemSize * heightFactor));
                            double opacity = percent;
                  
                            if (opacity > 1.0) opacity = 1.0;
                            if (opacity < 0.0) opacity = 0.0;
                  
                            double scale = percent * 1.2;
                            if (percent > 1.0) scale = 1.0;
                            if (scale > 1.0) scale = 1.0;
                  
                            return   MultiBlocProvider(
                    providers: [
                      BlocProvider<HomeBLoc>(
                        create: (context) => HomeBLoc(context.read<HomeRepo>()),
                      ),
                      BlocProvider<WatchedBLoc>(
                        create: (context) => WatchedBLoc(context.read<HomeRepo>()),
                        child: BlocListener<WatchedBLoc,Top_5_moviesState>(listener: (context, state) {
                    
                        },),
                      ),
                      BlocProvider<WatchtlistBLoc>(
                        create: (context) => WatchtlistBLoc(context.read<HomeRepo>()),
                        child: BlocListener<WatchtlistBLoc,Top_5_moviesState>(listener:(context, state) {
                                print(state);
                           if ( state is Delete_List_Movies_Done_State )
                      Navigator.pushReplacementNamed(context, '/home' ,arguments:{'param_load':'top_5_movies_delete','status':'${state.add_List_Movies_Model.status}','message':'${state.add_List_Movies_Model.message}'} );          
                  
                        },
                        
                        ),
                        
                      ), 
                    ],
                    child: BlocListener<HomeBLoc, Top_5_moviesState>(
                      listener: (context, state) {
                         if ( state is Delete_List_Movies_Done_State )
                      Navigator.pushReplacementNamed(context, '/home' ,arguments:{'param_load':'top_5_movies_delete','status':'${state.add_List_Movies_Model.status}','message':'${state.add_List_Movies_Model.message}'} );          
                  
                        // Your listener logic here
                      },
                      child:GestureDetector(
                        onTap: (){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context_, animation, secondaryAnimation) => MultiBlocProvider(
                        providers: [
                          RepositoryProvider<HomeRepo>(
                            create: (context) => HomeRepo(),
                          ),
                          BlocProvider<HomeBLoc>(
                            create: (context) => HomeBLoc(context.read<HomeRepo>()),
                          ),
                            BlocProvider<ReviewBLoc>(
                            create: (context) => ReviewBLoc(context.read<HomeRepo>()),
                          ),

                             BlocProvider<StreamBLoc>(
                            create: (context) => StreamBLoc(context.read<HomeRepo>()),
                          ),
                        ],
                        child: Movie_Page(arg: "${character.movies_id}"),
                      ),
                      transitionsBuilder: (
                        context_,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
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
                        child: Opacity(
                                opacity: opacity,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..scale(1.0, 1.0),
                                  child:  Filmcard(come_from:'watched_list',film_id:"${character.movies_id}",filmname:"${character.title}",
                                    key: null,
                                    imagePath: '${character.image_link}',
                                    loaded: true,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                          } else {
                            // Handle the case where the index is out of bounds
                            return add_film_card(come_from: "watched_list");
                          }
                        },
                        childCount: 3,
                      ),
                    );
                  }
                  
                                        
                                                                                                    
                                   
                                  return  SliverList(
                                     delegate: SliverChildBuilderDelegate(
                                       (context, index) {
                                         
                                                             
                                                             
                                         return   Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,);
                                       },
                                       childCount: 5 ,
                                     ),
                                   );
                                                                                                         },
                                        ),
                                                               
                                                             ] ),
                              ),
                            ),
                      









                  

                     /*   SafeArea(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                           
                              
                                  Container(
                                    margin: EdgeInsets.only(top: 7),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                 GeneretFilmcard(
                                              imageUrl: "https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg",
                                              id: "0",isloaded: false,),
                                        GeneretFilmcard(
                                              imageUrl: "https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg",
                                              id: "0",isloaded: false,),
                                          GeneretFilmcard(
                                             imageUrl: "https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg",
                                              id: "0",isloaded: true,),
                              ],
                                    ),
                                  ),
                             
                            ],
                            ),
                          ),
                        ),*/
                             Center(
                               child: Container(
                                width:SizeConfig.screenWidth ,
                                    margin: EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          width: (SizeConfig.screenWidth!! * 0.95) ,
                                          
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                 side: BorderSide(color: const Color.fromARGB(255, 93, 105, 122)),
                                                backgroundColor: Color.fromARGB(
                                                    255,
                                                    8,
                                                    76,
                                                    124), // Set the background color of the button
                                                foregroundColor: Colors
                                                    .white, // Set the text color of the button
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      15), // Set the border radius of the button
                                                ),
                                              ),
                                              onPressed: () {
                                          
                                                 showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                /*      backgroundColor: Color.fromARGB(
                                                          255,
                                                          30,
                                                          30,
                                                          30),*/
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0)),
                                                        child:
                                                        
                                                        AnimatedDialog());
                                                        },
                                                );
                                          
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 5, 15, 5),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "FIND",
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255,
                                                            255,
                                                            255,
                                                            255), // Set the text color
                                                        fontFamily:
                                                            'Roboto', // Set the font family
                                                        fontWeight: FontWeight
                                                            .bold, // Set the font weight
                                                        fontSize:
                                                            20, // Set the font size
                                                      ),
                                                    ),
                                                    Row(     mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              right: 4),
                                                          child: Icon(
                                                            BootstrapIcons
                                                                .gift_fill,
                                                            color: Color.fromARGB(255, 231, 7, 7),
                                                            size: 13,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              top: 3),
                                                          child: Text(
                                                            "100 Points",
                                                            style: TextStyle(
                                                              color: Color.fromRGBO(255, 255, 255, 1), // Set the text color
                                                              fontFamily:
                                                                  'Poppins', // Set the font family
                                                              fontWeight: FontWeight
                                                                  .normal, // Set the font weight
                                                              fontSize:
                                                                  10, // Set the font size
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                             )
                             
                        ,
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                 /*       Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 1),
                                    child: Text(
                                      'Watched ',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 88, 99,
                                                  116), // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12 // Set the font size
                                          ),
                                    ),
                                  ),
                                 BlocBuilder<WatchedBLoc,Top_5_moviesState>(
                                                                                                  builder: (context, state)  {
                              /*   if (state is Top_5_moviesLoadingState) {
                                                           
                                return Row(children: [
                                                           
                                  for ( var i = 0 ; i<4 ; i ++)
                                                              
                                                               Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                   key: null,
                                   imagePath: '',
                                   loaded: false,
                                   
                                 ),
                                                           
                                  ],);
                                 }
                                    */                       
                                 if (state is Watched_List_moviesLoadedState) {
                                  print("load_watched_list");
                              return    Text(!state.Watched_List_movies_retrun.isEmpty ?
                                    '${state.Watched_List_movies_retrun[0].count} Films':"0",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 122,
                                          204), // Set the text color
                                      fontFamily:
                                          'Roboto', // Set the font family
                                      fontWeight: FontWeight
                                          .bold, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  );
                                                              }
                                                              
                                      
                                                                                                  
                                 
                                return    Container(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(color: const Color.fromARGB(255, 0, 122, 204),));
                                                                                                       },
                                      ),
                                                
                                ],
                              ),
                              Text(
                                'See all',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                  
                                  color: Color.fromARGB(
                                      255, 88, 99, 116), // Set the text color
                                  fontFamily: 'Roboto', // Set the font family
                                  fontWeight:
                                      FontWeight.w400, // Set the font weight
                                  fontSize: 12, // Set the font size
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                                                       add_film_card(come_from: "watched_list",),
                  
                            Container(
                              height:(SizeConfig.screenWidth!! *134) /450,
                              width: SizeConfig.screenWidth!! * 0.71,
                              child: CustomScrollView(
                                scrollDirection: Axis.horizontal,
                                                                          controller: scrollController1,
                                                              
                                slivers: [BlocBuilder<WatchedBLoc,Top_5_moviesState>(
                                                                                                  builder: (context, state)  {
                                          
                                 if (state is Watched_List_moviesLoadedState) {
                                  print("load_watched_list");
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index < state.Watched_List_movies_retrun.length) {
                                      final heightFactor = 0.6;
                                      final character = state.Watched_List_movies_retrun[index];
                                      final itemPositionOffset = index * itemSize * heightFactor;
                                      final difference = scrollController1.offset - itemPositionOffset;
                                      final percent = 1.0 - (difference / (itemSize * heightFactor));
                                      double opacity = percent;
                                                              
                                      if (opacity > 1.0) opacity = 1.0;
                                      if (opacity < 0.0) opacity = 0.0;
                                                              
                                      double scale = percent * 1.2;
                                      if (percent > 1.0) scale = 1.0;
                                      if (scale > 1.0) scale = 1.0;
                                                              
                                      return  BlocProvider<WatchedBLoc>(
                                      
                                      create:(context)=>WatchedBLoc(context.read<HomeRepo>()) ,
                                      child: BlocListener<WatchedBLoc,Top_5_moviesState>(
                                        listener: (context,state){  
                                                              
                                                              
                                           if (state is Delete_List_Movies_Done_State ){
                                                              
                                            Navigator.pushReplacementNamed(context, '/home' ,arguments:{'param_load':'top_5_movies_delete','status':'${state.add_List_Movies_Model.status}','message':'${state.add_List_Movies_Model.message}'} );          
                                                              
                                                              
                                                              
                                                           
                                 }            
                                        
                                                              
                                                              
                                                              
                                        }
                                        ,child:   Opacity(
                                        opacity: opacity,
                                        child: Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()..scale(1.0, 1.0),
                                          child:  Filmcard(come_from:'watched_list',film_id:"${character.movies_id}",filmname:"${character.title}",
                                            key: null,
                                            imagePath: '${character.image_link}',
                                            loaded: true,
                                          ),
                                        ),
                                      ),),);
                                    } else {
                                      // Handle the case where the index is out of bounds
                                      return SizedBox();
                                    }
                                  },
                                  childCount: state.Watched_List_movies_retrun.length ,
                                ),
                              );
                                                              }
                                                              
                                      
                                                                                                  
                                 
                                return  SliverList(
                                   delegate: SliverChildBuilderDelegate(
                                     (context, index) {
                                       
                                                           
                                                           
                                       return   Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                      key: null,
                                                      imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                      loaded: false,);
                                     },
                                     childCount: 5 ,
                                   ),
                                 );
                                                                                                       },
                                      ),
                                                             
                                                           ] ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 1),
                                    child: Text(
                                      'Watchlist ',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 88, 99,
                                                  116), // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12 // Set the font size
                                          ),
                                    ),
                                  ),
                              BlocBuilder<WatchtlistBLoc,Top_5_moviesState>(
                                                                                                  builder: (context, state)  {
                              /*   if (state is Top_5_moviesLoadingState) {
                                                           
                                return Row(children: [
                                                           
                                  for ( var i = 0 ; i<4 ; i ++)
                                                              
                                                               Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                   key: null,
                                   imagePath: '',
                                   loaded: false,
                                   
                                 ),
                                                           
                                  ],);
                                 }
                                    */                       
                                 if (state is Watched_List_moviesLoadedState) {
                                  print("load_watched_list");
                              return    Text(!state.Watched_List_movies_retrun.isEmpty ?
                                    '${state.Watched_List_movies_retrun[0].count} Films':"0",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 122,
                                          204), // Set the text color
                                      fontFamily:
                                          'Roboto', // Set the font family
                                      fontWeight: FontWeight
                                          .bold, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  );
                                                              }
                                                              
                                      
                                                                                                  
                                 
                                return    Container(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(color: const Color.fromARGB(255, 0, 122, 204),));
                                                                                                       },
                                      ),
                                ],
                              ),
                              Text(
                                'See all',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                  
                                  color: Color.fromARGB(
                                      255, 88, 99, 116), // Set the text color
                                  fontFamily: 'Roboto', // Set the font family
                                  fontWeight:
                                      FontWeight.w400, // Set the font weight
                                  fontSize: 12, // Set the font size
                                ),
                              ),
                            ],
                          ),
                        ),
                              Row(
                          children: [
                           add_film_card(come_from: "watchlist",),
                           Container(
                              height:(SizeConfig.screenWidth!! *134) /450,
                              width: SizeConfig.screenWidth!! * 0.71,
                              child: CustomScrollView(
                                scrollDirection: Axis.horizontal,
                                                                       controller: scrollController2,
                                                              
                                slivers: [BlocBuilder<WatchtlistBLoc,Top_5_moviesState>(
                                                                                                  builder: (context, state)  {
                              /*   if (state is Top_5_moviesLoadingState) {
                                                           
                                return Row(children: [
                                                           
                                  for ( var i = 0 ; i<4 ; i ++)
                                                              
                                                               Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                   key: null,
                                   imagePath: '',
                                   loaded: false,
                                   
                                 ),
                                                           
                                  ],);
                                 }
                                    */                       
                                 if (state is Watched_List_moviesLoadedState) {
                                  print("load_watched_list");
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index < state.Watched_List_movies_retrun.length) {
                                      final heightFactor = 0.6;
                                      final character = state.Watched_List_movies_retrun[index];
                                      final itemPositionOffset = index * itemSize * heightFactor;
                                      final difference = scrollController2.offset - itemPositionOffset;
                                      final percent = 1.0 - (difference / (itemSize * heightFactor));
                                      double opacity = percent;
                                                              
                                      if (opacity > 1.0) opacity = 1.0;
                                      if (opacity < 0.0) opacity = 0.0;
                                                              
                                      double scale = percent * 1.2;
                                      if (percent > 1.0) scale = 1.0;
                                      if (scale > 1.0) scale = 1.0;
                                                              
                                      return  BlocProvider<WatchtlistBLoc>(
                                      
                                      create:(context)=>WatchtlistBLoc(context.read<HomeRepo>()) ,
                                      child: BlocListener<WatchtlistBLoc,Top_5_moviesState>(
                                        listener: (context,state){  
                                                              
                                                              
                                           if (state is Delete_List_Movies_Done_State ){
                                                              
                                            Navigator.pushReplacementNamed(context, '/home' ,
                                            arguments:{'param_load':'top_5_movies_delete',
                                            'status':'${state.add_List_Movies_Model.status}','message':'${state.add_List_Movies_Model.message}'} );          
                                                              
                                                              
                                                              
                                                           
                                 }            
                                        
                                                              
                                                              
                                                              
                                        }
                                        ,child:   Opacity(
                                        opacity: opacity,
                                        child: Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()..scale(1.0, 1.0),
                                          child:  Filmcard(come_from:'watchlist',film_id:"${character.movies_id}",filmname:"${character.title}",
                                            key: null,
                                            imagePath: '${character.image_link}',
                                            loaded: true,
                                          ),
                                        ),
                                      ),),);
                                    } else {
                                      // Handle the case where the index is out of bounds
                                      return SizedBox();
                                    }
                                  },
                                  childCount: state.Watched_List_movies_retrun.length,
                                ),
                              );
                                                              }
                                                              
                                      
                                                                                                  
                                 
                                return  SliverList(
                                   delegate: SliverChildBuilderDelegate(
                                     (context, index) {
                                       
                                                           
                                                           
                                       return   Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                      key: null,
                                                      imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                      loaded: false,);
                                     },
                                     childCount: 5 ,
                                   ),
                                 );
                                                                                                       },
                                      ),
                                                             
                                                           ] ),
                            ),
                          ],
                        ),
                         Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Popular This Friends ',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 88, 99,
                                                  116), // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12 // Set the font size
                                          ),
                                    ),
                                  ),
                                 BlocBuilder<PopularlistBLoc,Top_5_moviesState>(
                                                                                                  builder: (context, state)  {
                              /*   if (state is Top_5_moviesLoadingState) {
                                                           
                                return Row(children: [
                                                           
                                  for ( var i = 0 ; i<4 ; i ++)
                                                              
                                                               Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                   key: null,
                                   imagePath: '',
                                   loaded: false,
                                   
                                 ),
                                                           
                                  ],);
                                 }
                                    */                       
                                 if (state is Watched_List_moviesLoadedState) {
                                  print("load_watched_list");
                              return    Text(!state.Watched_List_movies_retrun.isEmpty ?
                                    '${state.Watched_List_movies_retrun[0].count} Films':"0",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 122,
                                          204), // Set the text color
                                      fontFamily:
                                          'Roboto', // Set the font family
                                      fontWeight: FontWeight
                                          .bold, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  );
                                                              }
                                                              
                                      
                                                                                                  
                                 
                                return    Container(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(color: const Color.fromARGB(255, 0, 122, 204),));
                                                                                                       },
                                      ),
                                ],
                              ),
                              Text(
                                'See all',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                  
                                  color: Color.fromARGB(
                                      255, 88, 99, 116), // Set the text color
                                  fontFamily: 'Roboto', // Set the font family
                                  fontWeight:
                                      FontWeight.w400, // Set the font weight
                                  fontSize: 12, // Set the font size
                                ),
                              ),
                            ],
                          ),
                        ),
                               Row(
                          children: [
                           Container(
                              height:(SizeConfig.screenWidth!! *134) /450,
                              width: SizeConfig.screenWidth!! * 0.9,
                              child: CustomScrollView(
                                scrollDirection: Axis.horizontal,
                                                              
                                slivers: [BlocBuilder<PopularlistBLoc,Top_5_moviesState>(
                                                                                                  builder: (context, state)  {
                              /*   if (state is Top_5_moviesLoadingState) {
                                                           
                                return Row(children: [
                                                           
                                  for ( var i = 0 ; i<4 ; i ++)
                                                              
                                                               Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                   key: null,
                                   imagePath: '',
                                   loaded: false,
                                   
                                 ),
                                                           
                                  ],);
                                 }
                                    */                       
                                 if (state is Watched_List_moviesLoadedState) {
                                  print("load_watched_list");
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index < state.Watched_List_movies_retrun.length) {
                                      final heightFactor = 0.6;
                                      final character = state.Watched_List_movies_retrun[index];
                                      final itemPositionOffset = index * itemSize * heightFactor;
                                      final difference = scrollController2.offset - itemPositionOffset;
                                      final percent = 1.0 - (difference / (itemSize * heightFactor));
                                      double opacity = percent;
                                                              
                                      if (opacity > 1.0) opacity = 1.0;
                                      if (opacity < 0.0) opacity = 0.0;
                                                              
                                      double scale = percent * 1.2;
                                      if (percent > 1.0) scale = 1.0;
                                      if (scale > 1.0) scale = 1.0;
                                                              
                                      return  BlocProvider<PopularlistBLoc>(
                                      
                                      create:(context)=>PopularlistBLoc(context.read<HomeRepo>()) ,
                                      child: BlocListener<PopularlistBLoc,Top_5_moviesState>(
                                        listener: (context,state){  
                                                              
                                                              
                                  
                                                              
                                                              
                                                              
                                        }
                                        ,child:   Opacity(
                                        opacity: opacity,
                                        child: Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()..scale(1.0, 1.0),
                                          child:  Filmcard(come_from:'popular_list',film_id:"${character.movies_id}",filmname:"${character.title}",
                                            key: null,
                                            imagePath: '${character.image_link}',
                                            loaded: true,
                                          ),
                                        ),
                                      ),),);
                                    } else {
                                      // Handle the case where the index is out of bounds
                                      return SizedBox();
                                    }
                                  },
                                  childCount: state.Watched_List_movies_retrun.length,
                                ),
                              );
                                                              }
                                                              
                                      
                                                                                                  
                                 
                                return  SliverList(
                                   delegate: SliverChildBuilderDelegate(
                                     (context, index) {
                                       
                                                           
                                                           
                                       return   Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                      key: null,
                                                      imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                      loaded: false,);
                                     },
                                     childCount: 5 ,
                                   ),
                                 );
                                                                                                       },
                                      ),
                                                             
                                                           ] ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Popular With Week ',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 88, 99,
                                                  116), // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12 // Set the font size
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '99 Films',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 122,
                                          204), // Set the text color
                                      fontFamily:
                                          'Roboto', // Set the font family
                                      fontWeight: FontWeight
                                          .bold, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'See all',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                  
                                  color: Color.fromARGB(
                                      255, 88, 99, 116), // Set the text color
                                  fontFamily: 'Roboto', // Set the font family
                                  fontWeight:
                                      FontWeight.w400, // Set the font weight
                                  fontSize: 12, // Set the font size
                                ),
                              ),
                            ],
                          ),
                        ),
                        SafeArea(
                          left: true,
                          child: SingleChildScrollView(
                            
                            scrollDirection: Axis.horizontal,
                            child: Column( mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column( mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                   Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,)                                       ,
                  
                                                        
                                                         Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                                         Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                                            Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                                            Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                       
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Currently In Theaters ',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 88, 99,
                                                  116), // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12 // Set the font size
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '99 Films',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 122,
                                          204), // Set the text color
                                      fontFamily:
                                          'Roboto', // Set the font family
                                      fontWeight: FontWeight
                                          .bold, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'See all',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                  
                                  color: Color.fromARGB(
                                      255, 88, 99, 116), // Set the text color
                                  fontFamily: 'Roboto', // Set the font family
                                  fontWeight:
                                      FontWeight.w400, // Set the font weight
                                  fontSize: 12, // Set the font size
                                ),
                              ),
                            ],
                          ),
                        ),
                        SafeArea(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                            Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                            Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                  
                                              Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                  
                                                Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                  
                                                  Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'assets/fight club.png',
                                                        loaded: false,),
                  
                                                    Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Upcoming Films ',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 88, 99,
                                                  116), // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12 // Set the font size
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '99 Films',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 122,
                                          204), // Set the text color
                                      fontFamily:
                                          'Roboto', // Set the font family
                                      fontWeight: FontWeight
                                          .bold, // Set the font weight
                                      fontSize: 12, // Set the font size
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'See all',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                  
                                  color: Color.fromARGB(
                                      255, 88, 99, 116), // Set the text color
                                  fontFamily: 'Roboto', // Set the font family
                                  fontWeight:
                                      FontWeight.w400, // Set the font weight
                                  fontSize: 12, // Set the font size
                                ),
                              ),
                            ],
                          ),
                        ),
                        SafeArea(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                          Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                          Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                          Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                            Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                      Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                              Filmcard(come_from:'',film_id:"",filmname:"TEst",
                                                        key: null,
                                                        imagePath: 'https://fr.web.img4.acsta.net/medias/nmedia/18/36/02/52/18846059.jpg',
                                                        loaded: false,),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                          height: 1,
                          color: Color.fromARGB(255, 71, 71, 71),
                          width: SizeConfig.screenWidth! - 20,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Text(
                                      'Articles :',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 88, 99,
                                                  116), // Set the text color
                                          fontFamily:
                                              'Roboto', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12 // Set the font size
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 2, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Netflix: Pulp Fiction will leave the platform',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255,
                                        255), // Set the text color
                                    fontFamily:
                                        'Poppins', // Set the font family
                                    fontWeight: FontWeight
                                        .w400, // Set the font weight
                                    fontSize: (SizeConfig.screenWidth! * 12) /
                                        384 // Set the font size
                                    ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/article.png'), // Replace with your background image path
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 200,
                                width: SizeConfig.screenWidth! - 10,
                              )
                            ],
                          ),
                        ),
                   
                   */   ],
                     );

              },
            childCount: 1
             ))

                      ] ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class popupdashboardbutton extends StatelessWidget {
  final Color color;
  final IconData icon;

  final String text;


  const popupdashboardbutton({
    Key? key,

    required this.color,
    required this.icon,
    required this.text,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Column(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Icon(
          icon,
          color: color,
          size: 30,
        ),
        Container(
          margin: EdgeInsets.only(left: 0),
          child: Text(
            "$text",
            style: TextStyle(
              color: color, // Set the text color
              fontFamily: 'Poppins', // Set the font family
              fontWeight: FontWeight.w400, // Set the font weight
              fontSize: 10, // Set the font size
            ),
          ),
        )
      ],
    );
  }
}
class AnimatedDialog extends StatefulWidget {
  @override
  _AnimatedDialogState createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipPath(
          clipper: SemiCircleClipper(_animation.value),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: YourDialogContent(), // Replace with your dialog content
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class SemiCircleClipper extends CustomClipper<Path> {
  final double animationValue;

  SemiCircleClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    final path = Path();

    final centerY = size.height;
    final semiCircleHeight = size.height * animationValue;

    path.moveTo(0, centerY);
    path.quadraticBezierTo(
        size.width / 2, centerY - semiCircleHeight * 2, size.width, centerY);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class YourDialogContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your custom dialog content
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Your dialog content goes here.',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
