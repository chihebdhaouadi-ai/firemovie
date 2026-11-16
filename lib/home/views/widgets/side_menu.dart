import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../account/views/pages/login.dart';
import '../../../core/core.dart';
import '../../../core/session.dart';


class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        width: 400,
        height: SizeConfig.screenHeight!,
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.background),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
/*
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ProfilePage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(-1.0,
                              0); // Change the begin offset to start from the left
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
                 */ },
                  child: Container(
                    height: 70,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color.fromARGB(255, 26, 40,
                                  50), // Set the desired border color
                              width: 2, // Set the desired border width
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0aEjACt2jj8i3I0n3u2rHnWrk9igVej4LTA&usqp=CAU',
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: SizeConfig.screenHeight!! * 0.012,
                            ),
                            Text(
                              "Profile ",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Set the text color
                                fontFamily: 'Inter', // Set the font family
                                fontWeight:
                                    FontWeight.w100, // Set the font weight
                                fontSize: 8,
                                height: 1.2, // Set the font size
                                // Set the font size
                              ),
                            ),
                            Text(
                              "Salim jbeli ",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Set the text color
                                fontFamily: 'Inter', // Set the font family
                                fontWeight:
                                    FontWeight.w300, // Set the font weight
                                fontSize: 23,
                                height: 1.2, // Set the font size
                              ),
                            ),
                            Text(
                              "CINEPHILE NEWBIE ",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Set the text color
                                fontFamily: 'Inter', // Set the font family
                                fontWeight:
                                    FontWeight.w100, // Set the font weight
                                fontSize: 8,
                                height: 1.2, // Set the font size
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 7),
                  color: Color.fromARGB(255, 71, 71, 71),
                  width: SizeConfig.screenWidth!! - 20,
                ),
                for (var element in sidebar_data)
                  element["option_name"] == "Settings" ?
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0), // Adjust border radius as needed
                        ),
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ExpansionTile(
                        //  collapsedBackgroundColor: Colors.blue,
                          //   backgroundColor: Colors.amber,
                       shape: RoundedRectangleBorder(
    side: BorderSide(color: Colors.transparent, width: 2.0),
    borderRadius: BorderRadius.circular(8.0),
    ),

                          childrenPadding: EdgeInsets.all(0),
                          title: Container(
                            margin: EdgeInsets.fromLTRB(4, 0, 4, 8),
                            padding: EdgeInsets.only(bottom: 0),
                            decoration: BoxDecoration(
                              border: Border(

                              ),
                            ),
                            child: GestureDetector(
                                onTap: () {
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 2, 0, 0),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 3),
                                        child: Icon(
                                          element["icon_data"],
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 29,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        child: Text(
                                          "${element["option_name"]}",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary, // Set the text color
                                            fontFamily:
                                            'Inter', // Set the font family
                                            fontWeight:
                                            FontWeight.w300, // Set the font weight
                                            fontSize: 15, // Set the font size
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                                          trailing: Icon(Icons.arrow_drop_down),
                          children: [

                            Container(
                              decoration: BoxDecoration(
                                border: Border(

                                ),
                              ),
                              child: GestureDetector(
                                  onTap: () {
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(50, 2, 10, 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 3),
                                          child: Icon(
                                           Icons.access_alarm,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 29,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 3),
                                          child: Text(
                                            "Acount",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary, // Set the text color
                                              fontFamily:
                                              'Inter', // Set the font family
                                              fontWeight:
                                              FontWeight.w300, // Set the font weight
                                              fontSize: 15, // Set the font size
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            )
                          ],
                        ),
                      )


                      :     Container(
                    margin: EdgeInsets.fromLTRB(4, 0, 4, 8),
                    padding: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border(

                      ),
                    ),
                    child: GestureDetector(
                        onTap: () {
                          if (element["option_name"] == "logout") {
                            Session.clear();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => false);
                          }


                       /*   if (element["option_name"] == "Settings")
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => settings()),
                            );*/
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 3),
                                child: Icon(
                                  element["icon_data"],
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 29,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                child: Text(
                                  "${element["option_name"]}",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary, // Set the text color
                                    fontFamily:
                                        'Inter', // Set the font family
                                    fontWeight:
                                        FontWeight.w300, // Set the font weight
                                    fontSize: 15, // Set the font size
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
      ),
    );
  
  }
}
