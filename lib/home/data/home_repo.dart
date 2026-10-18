

import 'dart:convert';

import 'package:film_wise_mobile/core/core.dart';
import 'package:film_wise_mobile/home/blocs/home_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'top_5_movies_entity.dart';
import 'top_5_movies_model.dart';
import 'package:http/http.dart' as http;



double calculateAverageRating(List<Review_Model> ratings) {
  if (ratings.isEmpty) {
    return 0.0; // return 0 if the list is empty
  }

  // Convert the list of strings to a list of doubles
  List<double> ratingValues = ratings.map((rating) => double.parse(rating.rating)).toList();

  // Calculate the average rating
  double sum = ratingValues.reduce((value, element) => value + element);
  double average = sum / ratingValues.length;
 // Round the average to the nearest 0.5
  double roundedAverage = (average * 2).round() / 2;

  // Ensure the result is within the desired range (0.5 to 5.0)
  print(roundedAverage.clamp(0.5, 5.0));
  return roundedAverage.clamp(0.5, 5.0);

}


Future<List<String>> get_image_film_by_id(String id) async{

     final Map<String, String> headers = {
   'X-RapidAPI-Key': '',
    'X-RapidAPI-Host': 'online-movie-database.p.rapidapi.com'
    };
    final Map<String, String> params = {
      'tconst': '${id}',
  };
    final uri = Uri.https(
        'online-movie-database.p.rapidapi.com', '/title/get-details', params);
      final response = await http.get(uri, headers: headers);
      print(jsonDecode(response.body)['image']['url']);

return [jsonDecode(response.body)['image']['url'], jsonDecode(response.body)['title']];
}

class   HomeRepo {

  final url ="http://127.0.0.1:8000/api/film/get_top_5_movies";

     Future<List<Top_5_Movies_Model>> get_top_5_movies(Top_5_Movies_Entity top_5_Movies_Entity)async{
             List<Top_5_Movies_Model> data_return=[];

    final response =  await get(Uri.parse(url),
    
     headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${top_5_Movies_Entity.token}'
        },);

  var services=jsonDecode(response.body)['data'];

    
 
 for (var item in services){
  print("$item");
  var url= await get_image_film_by_id(item["imdp_id"]);

  data_return.add(Top_5_Movies_Model(movies_id: item['imdp_id'],image_link: "${url[0]}",title: "${url[1]}"));
 }



    print(services);
    print(data_return);

    return data_return;
  }


   Future<List<Find_Movies_Model_>> get_find_movies(Find_Movies_Entity find_Movies_Entity)async{


       final Map<String, String> headers = {
      'X-RapidAPI-Key': '',
      'X-RapidAPI-Host': 'online-movie-database.p.rapidapi.com'
    };
    final Map<String, String> params = {
      'title': '${find_Movies_Entity.title}',
      'limit': '3',
      'sortArg': 'moviemeter,asc'
    };
    final uri = Uri.https(
        'online-movie-database.p.rapidapi.com', '/title/v2/find', params);
    List<Find_Movies_Model_> _Films = [];

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
      
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

                  Find_Movies_Model_ film = Find_Movies_Model_(
                    movies_id: id,
                    title: name,
                    year: year,
                    image_link: image,
                    directed_by: director,
                  );
                  _Films.add(film);

                  print("dircc ${dir}");
                }
              } catch (error) {
                print('Error2: $error');
       
              
              }

              print(extractedValue);
            }}}}}
            catch(e){

            }

    print("hani lena$_Films");
     return _Films;

  }

Future<Add_List_Movies_Model> add_list_find_movies(Add_List_Movies_Entity add_List_Movies_Entity) async {
  print("test_add${add_List_Movies_Entity.movie_id} ${add_List_Movies_Entity.come_from}");
  
    RegExp regExp = RegExp(r'/title/(tt\d+)/');

  // Use the firstMatch method to find the match in the input string
  Match? match = regExp.firstMatch(add_List_Movies_Entity.movie_id);

        String imdbId = match!.group(1)!;

     String urllike="";
     if (add_List_Movies_Entity.come_from == "top_5_movies")
      urllike ="http://127.0.0.1:8000/api/film/add_top_5_movies";
          if (add_List_Movies_Entity.come_from == "watched_list")
      urllike ="http://127.0.0.1:8000/api/film/add_watched_movies";
     
       if (add_List_Movies_Entity.come_from == "watchlist")
      urllike ="http://127.0.0.1:8000/api/film/add_watchlist_movies";

  final response = await http.post(
    Uri.parse("$urllike"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${add_List_Movies_Entity.token}',
    },
    body: jsonEncode({
      "imdbid": "${imdbId}",
    }),
  );

  final services = jsonDecode(response.body);
  print(services["status"]);
  if ( services["status"] == 200 ){
  var x = Add_List_Movies_Model(status: "${services["status"]}", message: "${services['message']}");



  return x;

  }

var x = Add_List_Movies_Model(status: "${services["status"]}",message: "TTT");
  return x;

}







Future<Add_List_Movies_Model> delete_list_find_movies(Add_List_Movies_Entity add_List_Movies_Entity) async {

    print("test_delete${add_List_Movies_Entity.come_from}");
    
    String url_api=add_List_Movies_Entity.come_from == "top_5_movies"? "http://127.0.0.1:8000/api/film/delete_top_5_movies"
     :
     add_List_Movies_Entity.come_from == "watched_list"?

      "http://127.0.0.1:8000/api/film/delete_wathced_list_movies": add_List_Movies_Entity.come_from == "watchlist" ?
      
      "http://127.0.0.1:8000/api/film/delete_watch_list_movies":
      
      
      
      "";
     print(url_api);

  final response = await http.post(
    Uri.parse("$url_api"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${add_List_Movies_Entity.token}',
    },
    body: jsonEncode({
      "imdbid": "${add_List_Movies_Entity.movie_id}",
    }),
  );

  final services = jsonDecode(response.body);
  print(services["status"]);
  if ( services["status"] == 200 ){
  var x = Add_List_Movies_Model(status: "${services["status"]}", message: "${services['message']}");



  return x;

  }

var x = Add_List_Movies_Model(status: "${services["status"]}",message: "TTT");
  return x;


}



  Future<List<Watched_List_Movies_Model>> get_whatched_list_movies(Top_5_Movies_Entity top_5_Movies_Entity)async{

         List<Watched_List_Movies_Model> data_return=[];

    final response =  await get(Uri.parse("http://127.0.0.1:8000/api/film/get_wathced_list_movies"),
    
     headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${top_5_Movies_Entity.token}'
        },);

  var services=jsonDecode(response.body)['data'];

    
 
 for (var item in services){
  print("$item");
  var url= await get_image_film_by_id(item["imdp_id"]);

  data_return.add(Watched_List_Movies_Model(movies_id: item['imdp_id'],image_link: "${url[0]}",title: "${url[1]}", count: '${services.length}'),);
 }



    print(services);
    print(data_return);

  
    return data_return ;

  }




    Future<List<Watched_List_Movies_Model>> get_watch_list_movies(Top_5_Movies_Entity top_5_Movies_Entity)async{

      
    final response =  await get(Uri.parse("http://127.0.0.1:8000/api/film/get_watch_list_movies"),
    
     headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${top_5_Movies_Entity.token}'
        },);

  var services=jsonDecode(response.body)['data'];
         List<Watched_List_Movies_Model> data_return=[];

    
 
 for (var item in services){
  print("$item");
  var url= await get_image_film_by_id(item["imdp_id"]);

  data_return.add(Watched_List_Movies_Model(movies_id: item['imdp_id'],image_link: "${url[0]}",title: "${url[1]}", count: '${services.length}'),);
 }



    print(services);
    print(data_return);

  
    return data_return ;

  }



    Future<List<Watched_List_Movies_Model>> get_popular_list_watch_list_movies(Top_5_Movies_Entity top_5_Movies_Entity)async{

      
    final response =  await get(Uri.parse("http://127.0.0.1:8000/api/film/get_popular_friends_list_movies"),
    
     headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${top_5_Movies_Entity.token}'
        },);

  var services=jsonDecode(response.body)['data'];
         List<Watched_List_Movies_Model> data_return=[];

    
 
 for (var item in services){
  print("$item");
  var url= await get_image_film_by_id(item["imdp_id"]);

  data_return.add(Watched_List_Movies_Model(movies_id: item['imdp_id'],image_link: "${url[0]}",title: "${url[1]}", count: '${services.length}'),);
 }



    print(services);
    print(data_return);

  
    return data_return ;

  }




Future<Detail_MoviesModel> loadPageData(id) async {
  final Map<String, String> headers = {
    'X-RapidAPI-Key': '',
    'X-RapidAPI-Host': 'online-movie-database.p.rapidapi.com',
  };

  final Map<String, String> _params = {
    'tconst': '$id',
  };
  final _uri = Uri.https(
    'online-movie-database.p.rapidapi.com',
    '/title/get-full-credits',
    _params,
  );

  final _response = await http.get(_uri, headers: headers);

  if (_response.statusCode == 200) {
    var dir = jsonDecode(_response.body)["crew"]["director"][0]["name"];
    var year = '${jsonDecode(_response.body)["base"]["year"]}';
    var image = jsonDecode(_response.body)["base"]["image"]["url"];
    var title = jsonDecode(_response.body)["base"]["title"];

    var director = dir;
  final Map<String, String> _headers = {
    'X-RapidAPI-Key': '',
    'X-RapidAPI-Host': 'online-movie-database.p.rapidapi.com',
  };

  final Map<String, String> __params = {
    'tconst': '$id',
  };
  final __uri = Uri.https(
    'online-movie-database.p.rapidapi.com',
    '/title/get-overview-details',
    __params,
  );

  final __response = await http.get(__uri, headers: _headers);  
    var description = jsonDecode(__response.body)["plotOutline"]["text"];
        var genres = jsonDecode(__response.body)["genres"];
        var rating = jsonDecode(__response.body)["ratings"]["rating"];
        var ratingCount = jsonDecode(__response.body)["ratings"]["ratingCount"];

  


    Detail_MoviesModel film = Detail_MoviesModel(
      moviesId: id,
      title: title,
      year: year,
      imageLink: image,
      directedBy: director,
      descritption: description,
      genres: genres,
      rating: rating,
      ratingCount:ratingCount

    );

    print("Director: $dir");
    print("title: $title");

    print("year: $year");
    print("image: $image");
 

    return film;
  } else {
    // Handle the case when the request fails
    print("Error: ${_response.statusCode}");
    throw Exception("Failed to load data");
  }
}



Future<Review_MoviesModel> get_review_movies(Review_MoviesTrigerState Review_triger) async {

    
    //String url_api="http://127.0.0.1:8000/api/review/get_review";
/*
  final response = await http.get(
    Uri.parse("$url_api"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${Review_triger.token}',
    },
    body: jsonEncode({
      "imdbid": "${Review_triger.imdbid}",
    }),
  );*/

    final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${Review_triger.token}',
  };

  final Map<String, String> __params = {
    "imdbid": "${Review_triger.imdbid}",
  };
  final __uri = Uri.http(
    '127.0.0.1:8000',
    '/api/review/get_review',
    __params,
  );

  final response = await http.get(__uri, headers: _headers);  

  final services = jsonDecode(response.body);
  print(services["status"]);
    print(services["data"]);

    

  if ( services["status"] == 200 ){

   List<Review_Model> list_reviews=[];
   for (var i in services["data"]){
    print(i);
    var x=Review_Model(writer_name: i["writer"], rating: i["rating"].toString(), data: i["date"], likes: i["likes"].toString(), Disliles: i["dislikes"].toString(),body: i["body"], image_link: i["writer_image"]);
           list_reviews.add(x);


   }
   print(list_reviews);


    
  var x = Review_MoviesModel(reviews: list_reviews, count: '${list_reviews.length}', moyen: '${calculateAverageRating(list_reviews)}');




  return x;

  }

var x = Review_MoviesModel( reviews: [], count: '', moyen: '');
  return x;


}






Future<Stream_AvaibilityModel> get_Steam_avaibility(Stream_MoviesTrigerState Review_triger) async {
  final Map<String, String> _headers = {
    'X-RapidAPI-Key': '',
    'X-RapidAPI-Host': 'streaming-availability.p.rapidapi.com',
  };

  final Map<String, String> __params = {
    "imdb_id": "${Review_triger.imdbid}",
    "output_language": 'en',
  };

  final __uri = Uri.https(
    'streaming-availability.p.rapidapi.com',
    '/get',
    __params,
  );

  final response = await http.get(__uri, headers: _headers);
  final services = jsonDecode(response.body)["result"]["streamingInfo"]["us"];
  //print(services["result"]["streamingInfo"]["us"]);
 List<Movie_streamModel> t = [];
    for (var k in services){
        
        print('${k}');
        print("lena=${streaming_platform["prime"]}");
        Movie_streamModel x=Movie_streamModel(image_url_platform: '${streaming_platform["${k["service"]}"]}', movie_url: '${k["link"]}');
        t.add(x);
        } 
    print(t);
    print("finishhhhhhh");
 
 return Stream_AvaibilityModel(movies_stream: t, trailer_url: "trailer_url");
}











}