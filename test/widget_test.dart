import 'dart:convert';
import 'package:http/http.dart' as http;

class FindMoviesModel {
  String moviesId;
  String title;
  String imageLink;
  String year;
  String directedBy;
  String descritption;
  List<String> genres;
  int rating;
    int  ratingCount;
  FindMoviesModel({
    required this.moviesId,
    required this.title,
    required this.imageLink,
    required this.year,

    required this.directedBy,
    required this.descritption,
    required this.genres,
    required this.rating,
    required this.ratingCount,

  });
}

Future<FindMoviesModel> loadPageData(id) async {
  final Map<String, String> headers = {
    'X-RapidAPI-Key': 'test-key',
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
    print(jsonDecode(_response.body));
    var dir = jsonDecode(_response.body)["crew"]["director"][0]["name"];
    print(jsonDecode(_response.body)["base"]["year"]);
    var year = '${jsonDecode(_response.body)["base"]["year"]}';
    var image = jsonDecode(_response.body)["base"]["image"]["url"];
    var title = jsonDecode(_response.body)["base"]["title"];

    var director = dir;
  final Map<String, String> _headers = {
    'X-RapidAPI-Key': 'test-key',
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

   print(description);
   print(genres);
   print(rating);
   print(ratingCount);


    FindMoviesModel film = FindMoviesModel(
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

void main() async {
  try {
    FindMoviesModel result = await loadPageData("tt0110475");
    print("Result: $result");
  } catch (e) {
    print("Error: $e");
  }
}
