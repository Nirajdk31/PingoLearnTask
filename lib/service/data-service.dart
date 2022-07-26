import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataService with ChangeNotifier {
  Map<String, dynamic> _movieList = {
  "title": "Movie Name",
  "release_date": "Release Date",
  "rating": "Rating",
  "story": "Story",
  "image":
  "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg"};

  Map<String, dynamic> get movieList => _movieList;

  Future<Map> getMovies(String keyword, BuildContext context) async {
    String url =
        "https://api.themoviedb.org/3/search/movie?api_key=bb657a881f0772af5d92ebc9d6d19807&language=en-US&query=$keyword&page=1&include_adult=false";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print(data);
        var temp = {
          "title": data["results"][0]["original_title"],
          "release_date": data["results"][0]["release_date"],
          "rating": data["results"][0]["vote_average"],
          "story": data["results"][0]["overview"],
          "image":
              "https://www.themoviedb.org/t/p/w600_and_h900_bestv2${data["results"][0]["poster_path"]}"
        };

        _movieList = temp;
        //API SUCCESS
      } else {
        //ERROR BLOCK
      }
    } catch (error) {
      print(error);
    }
    notifyListeners();
    return _movieList;
  }
}
