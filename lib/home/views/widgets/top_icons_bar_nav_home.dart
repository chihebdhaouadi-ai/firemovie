import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/core.dart';

class top_icons_bar_nav_home extends StatelessWidget {
  final IconData icon_data;
  final String text;
  final String come_from_key;

  const top_icons_bar_nav_home({
    Key? key,
    required this.icon_data,
required this.text, 
    required this.come_from_key,

 }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                padding: come_from_key=="message"?   EdgeInsets.only(right: 4) :  EdgeInsets.only(right: 0),
                                                  margin:
                                                      EdgeInsets.only(right: 0),
                                                  child: Icon(
                                                    icon_data,
                                                    color: Color.fromARGB(
                                                        255, 121, 121, 121),
                                                    size: 25,
                                                  )),
                                              SizedBox(
                                                  width: (SizeConfig
                                                              .screenWidth!! *
                                                          10) /
                                                      500),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: (){
                                                    print("tttt");
                                                  },
                                                  child: Container(
                                                    width: 7,
                                                    height:   7,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:   come_from_key=="message" || come_from_key=="notifications"  ? Colors
                                                          .red: const Color.fromARGB(0, 244, 67, 54), // Set the desired circle color
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '',
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              116,
                                                              116,
                                                              116), // Set the text color
                                                          fontFamily:
                                                              'Inter', // Set the font family
                                                          fontWeight: FontWeight
                                                              .normal, // Set the font weight
                                                          fontSize:
                                                              7, // Set the font size
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 1,
                                          ),
                                          Text(
                                            '$text',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255,
                                                  116,
                                                  116,
                                                  116), // Set the text color
                                              fontFamily:
                                                  'Inter', // Set the font family
                                              fontWeight: FontWeight
                                                  .w600, // Set the font weight
                                              fontSize:
                                                  (SizeConfig.screenWidth!! *
                                                          8) /
                                                      384, // Set the font size
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
  }
}
