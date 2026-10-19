import 'dart:developer';
import 'dart:ffi';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/blocs/login_event.dart';
import 'package:film_wise_mobile/account/data/auth_entity.dart';
import 'package:film_wise_mobile/core/core.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import '../../../home/views/pages/home.dart';
import '../../../home/views/widgets/custom_dialgo.dart';
import '../../blocs/login_state.dart';


class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  late AnimationController _controller;
  late Animation<double> _animation;
  List<bool> d = [false, false, false];
  List<bool> g = [false, false, false, false, false, false];
  bool next = false;
  bool show = false;
  bool loginload = true;
  String value = 'Initial Value';
 late bool showanimationpopup=false;
late bool AccountCreationstate=false;
late bool showanimationpopup_ster=false;

  int _currentPage = 0;

  var _pageController = PageController(initialPage: 0);
  bool _isPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
 final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


 final TextEditingController usernameregisterControler= TextEditingController();
 final TextEditingController emailregisterControler= TextEditingController();
 final TextEditingController passwordregisterControler= TextEditingController();
 final TextEditingController passwordreapetregisterControler= TextEditingController();

late final AnimationController _animationController_popup;

  void handleValueChanged(String newValue) {
    setState(() {
      value = newValue;
    });
  }

  bool isImage1 = true;
  
  void _toggleImage() {
    setState(() {
      isImage1 = !isImage1;
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController_popup=AnimationController(      duration: const Duration(milliseconds: 3000),
vsync: this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

_animationController_popup.addStatusListener((AnimationStatus status)  {
      if (status == AnimationStatus.forward) {
     print('Animation Started');
     Future.delayed(Duration(seconds: 5), () {
        print('Code executed after 2 seconds');

        // Code here will execute after the delay

   setState(() {
      showanimationpopup = false;
    });


        // Additional code if needed after setting showanimationpopup to false
      });
 
    
      }
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }




  @override
 Widget build(BuildContext context) {
  Map<String, dynamic>? arguments =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (arguments != null) {
    String? comeFrom = arguments['come_from'] as String?;

    if (comeFrom != null) {
      print('come_from: $comeFrom');

      AccountCreationstate = true;
      if(showanimationpopup_ster == false){
      showanimationpopup = true;
      showanimationpopup_ster=true;

      }
      

      _animationController_popup.forward();

      // You don't need 'await' here since build method cannot be marked as 'async'

    }
  }
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Stack(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              AnimatedContainer(
                                padding: EdgeInsets.only(
                                    bottom: (MediaQuery.of(context).size.height *
                                            130) /
                                        792),
                                duration: Duration(microseconds: 1),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: isImage1
                                        ? AssetImage("assets/loginbg.png")
                                        : AssetImage("assets/createbg.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height:
                                    (MediaQuery.of(context).size.height * 480) /
                                        792,
                              ),
                              Stack(
                                children: [
                                  Container(
                                    color: Color.fromARGB(250, 30, 30, 30),
                                    height: (MediaQuery.of(context).size.height *
                                            200) /
                                        792,
                                  ),
                                  Positioned(
                                    top: 0,
                                    width: MediaQuery.of(context).size.width,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(250, 30, 30, 30),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Color.fromARGB(255, 28, 20, 77),
              
                                            // Shadow color
                                            spreadRadius: 12, // Spread radius
                                            blurRadius: 8, // Blur radius
                                            offset: Offset(0,
                                                -4), // Offset to the top (negative y value)
                                          ),
                                        ],
                                      ),
                                      height: 0,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          bottom:
                              (MediaQuery.of(context).size.height * 200) / 792,
                          child: Container(
                            height:
                                (MediaQuery.of(context).size.height * 600) / 792,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromARGB(10, 24, 20, 136),
                                  Color.fromARGB(20, 24, 20, 136),
                                  Color.fromARGB(30, 24, 20, 136),
                                  Color.fromARGB(70, 24, 20, 136),
                                  Color.fromARGB(110, 24, 20, 136),
                                  Color.fromARGB(130, 24, 20, 136),
                                  Color.fromARGB(130, 24, 20, 136),
                                  Color.fromARGB(70, 24, 20, 136),
                                  Color.fromARGB(10, 24, 20, 136),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    PageView(
                      allowImplicitScrolling: false,
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        ListView(
                          children: [
                            SizedBox(
                              height: (MediaQuery.of(context).size.height * 220) /
                                  792,
                            ),
                             Center(
                                         child: BlocBuilder<LoginBLoc, LoginState>(
                                            builder: (context, state)  {
          if (state is LoginLoadingState) {
            return CircularProgressIndicator(color: Colors.white);
          } else if (state is LoginErrorState) {
              // Show a pop-up dialog when there is a login error
          
            }
      return SizedBox();
    },
                                                     ),
                                       ),
                            Center(
                              
                            
                              child: Container(
                                margin: EdgeInsets.fromLTRB(25, 0, 25, 25),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 8,
                                      ), AccountCreationstate?
                                      Text(
                                      "Account created successfully",
                                      style: TextStyle(
                                        color: Color.fromARGB(199, 49, 252, 42), // Set the text color
                                        // Set the text color
                                        fontFamily:
                                            'Poppins', // Set the font family
                                        fontWeight: FontWeight
                                            .w400, // Set the font weight
                                        fontSize: 12,
                                        // Set the font size
                                      ),
                                    ):SizedBox(),
                                      Text(
                                        "SIGN IN AND",
                                        style: TextStyle(
                                          color: Color.fromARGB(200, 217, 217,
                                              217), // Set the text color
                                          // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12,
                                          // Set the font size
                                        ),
                                      ),
                                      Text(
                                        "UNLOCK YOUR INNER FILM BUFF",
                                        style: TextStyle(
                                          color: Color.fromARGB(200, 217, 217,
                                              217), // Set the text color
              // Set the text color
                                          fontFamily:
                                              'Poppins', // Set the font family
                                          fontWeight: FontWeight
                                              .w400, // Set the font weight
                                          fontSize: 12,
                                          // Set the font size
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                        color: Color.fromARGB(250, 6, 94, 153),
                                        height: 1,
                                        width: MediaQuery.of(context).size.width *
                                            0.9,
                                      ),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      TextFormField(
                                        controller: emailController,
                                        validator: (value) {
                                          // add email validation
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
              
                                          bool emailValid = RegExp(
                                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(value);
                                          if (!emailValid) {
                                            return 'Please enter a valid email';
                                          }
              
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          hintText: 'Enter youremail',
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          border: OutlineInputBorder(),
                                          labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
              
                                          // Customize the border color
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromARGB(255, 217, 217,
                                                  217), // Change the color to your desired color
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical:
                                                15.0, // Adjust the vertical padding as needed
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: passwordController,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
              
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                        obscureText: !_isPasswordVisible,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical:
                                                15.0, // Adjust the vertical padding as needed
                                          ),
                                          labelText: 'Password',
                                          hintText: 'Enter your password',
                                          prefixIcon: Icon(
                                            Icons.lock_outline_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromARGB(255, 0, 217,
                                                  217), // Change the color to your desired color
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromARGB(255, 217, 217,
                                                  217), // Change the color to your desired color
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Forget Password?",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationThickness: 2.0,
                                              color: Color.fromARGB(255, 12, 85,
                                                  155), // Set the text color
                                              fontFamily:
                                                  'Poppins', // Set the font family
                                              fontWeight: FontWeight
                                                  .w500, // Set the font weight
                                              fontSize: 14,
              
                                              // Set the font size
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                     
                                     
                                     
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Color.fromARGB(255, 12, 85, 155),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              'LOGIN',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              /// do something
                                              if (_currentPage < 1) {
                                                
                                             
                                             



                                                             BlocProvider.of<LoginBLoc>(context).mapEventToState(LoginTrigerState(loginEntity:LoginEntity(email: "${emailController.text}"
                                                             ,passowrd:'${passwordController.text}' ) ));
                                             
                                             
                                             
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Don’t have an account?",
                                            style: TextStyle(
                                              decorationThickness: 2.0,
                                              color: Color.fromARGB(255, 217, 217,
                                                  217), // Set the text color
                                              // Set the text color
                                              fontFamily:
                                                  'Poppins', // Set the font family
                                              fontWeight: FontWeight
                                                  .w500, // Set the font weight
                                              fontSize: 13,
              
                                              // Set the font size
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (_currentPage < 1) {
                                                _toggleImage();
                                                _pageController.nextPage(
                                                  duration:
                                                      Duration(milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            },
                                            child: Text(
                                              "Signup",
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationThickness: 2.0,
                                                color: Color.fromARGB(255, 12, 85,
                                                    155), // Set the text color
                                                // Set the text color
                                                fontFamily:
                                                    'Poppins', // Set the font family
                                                fontWeight: FontWeight
                                                    .w500, // Set the font weight
                                                fontSize: 13,
              
                                                // Set the font size
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListView(
                          children: [
                            SizedBox(
                              height: (MediaQuery.of(context).size.height * 240) /
                                  792,
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
                              child: Form(
                                key: _formKey1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 16),
                                    SizedBox(
                                      height: 8,
                                    ),
                                   
                                    Text(
                                      "SIGN IN AND ",
                                      style: TextStyle(
                                        color: Color.fromARGB(200, 217, 217,
                                            217), // Set the text color
                                        // Set the text color
                                        fontFamily:
                                            'Poppins', // Set the font family
                                        fontWeight: FontWeight
                                            .w400, // Set the font weight
                                        fontSize: 12,
                                        // Set the font size
                                      ),
                                    ),
                                    Text(
                                      "UNLOCK YOUR INNER FILM BUFF",
                                      style: TextStyle(
                                        color: Color.fromARGB(200, 217, 217,
                                            217), // Set the text color
                                        // Set the text color
                                        fontFamily:
                                            'Poppins', // Set the font family
                                        fontWeight: FontWeight
                                            .w400, // Set the font weight
                                        fontSize: 12,
                                        // Set the font size
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      color: Color.fromARGB(250, 6, 94, 153),
                                      height: 1,
                                      width:
                                          MediaQuery.of(context).size.width * 0.9,
                                    ),
                                    SizedBox(
                                      height: 14,
                                    ),
                                    TextFormField(
                                      controller: usernameregisterControler,
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
              
                                        if (value.length < 6) {
                                          return 'Username must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        hintText: 'Enter your username',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        border: OutlineInputBorder(),
                                        labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
              
                                        // Customize the border color
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical:
                                              15.0, // Adjust the vertical padding as needed
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: emailregisterControler,
                                      validator: (value) {
                                        // add email validation
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
              
                                        bool emailValid = RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(value);
                                        if (!emailValid) {
                                          return 'Please enter a valid email';
                                        }
              
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'Enter your email',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        border: OutlineInputBorder(),
                                        labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
              
                                        // Customize the border color
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical:
                                              15.0, // Adjust the vertical padding as needed
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: passwordregisterControler,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
              
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                                                if (value != passwordreapetregisterControler.text) {
      return 'Passwords do not match';
    }
                     
                                        return null;
                                      },
                                      obscureText: !_isPasswordVisible,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical:
                                              15.0, // Adjust the vertical padding as needed
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: passwordreapetregisterControler,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter some text';
                                        }
              
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        if (value != passwordregisterControler.text) {
      return 'Passwords do not match';
    }
                                        return null;
                                      },
                                      obscureText: !_isPasswordVisible,
                                      decoration: InputDecoration(
                                        labelText: ' Repeat Password',
                                        hintText: 'Enter your  repeat password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical:
                                              15.0, // Adjust the vertical padding as needed
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 12, 85, 155),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'CREATE',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (_formKey1.currentState?.validate() ??
                                              false) {
                                            /// do something
                                          
                                             
                                                             BlocProvider.of<LoginBLoc>(context).createaccount(RegisterTrigerState(registerEntity:RegisterEntity(
                                                              username: "${usernameregisterControler.text}",
                                                              email: "${emailregisterControler.text}"
                                                             ,passowrd:'${passwordregisterControler.text}' ) ));
                                            
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "You have an account?",
                                          style: TextStyle(
                                            decorationThickness: 2.0,
                                            color: Color.fromARGB(255, 217, 217,
                                                217), // Set the text color
                                            // Set the text color
                                            fontFamily:
                                                'Poppins', // Set the font family
                                            fontWeight: FontWeight
                                                .w500, // Set the font weight
                                            fontSize: 13,
              
                                            // Set the font size
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _toggleImage();
              
                                            if (_currentPage >= 1) {
                                              _pageController.previousPage(
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          },
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationThickness: 2.0,
                                              color: Color.fromARGB(
                                                  255, 0, 122, 204),
                                              // Set the text color
                                              fontFamily:
                                                  'Poppins', // Set the font family
                                              fontWeight: FontWeight
                                                  .w500, // Set the font weight
                                              fontSize: 13,
              
                                              // Set the font size
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
               
          showanimationpopup?     Center(
                child: Lottie.network("https://lottie.host/2041a391-2eeb-4eac-bf8b-a9fc2a5d7b62/Ygg9wslNj9.json",controller: _animationController_popup),
               ):SizedBox()
               
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlutterLogo(size: isSmallScreen ? 100 : 200),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to Flutter!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineMedium
                : Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: Colors.black),
          ),
        )
      ],
    );
  }
}
