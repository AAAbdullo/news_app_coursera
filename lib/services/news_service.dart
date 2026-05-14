import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  // Replace with your actual NewsAPI key from https://newsapi.org
  static const String _apiKey = '10297c0436284d039f15e6bbfe61e5c0';
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> getTopHeadlines(
      {String country = 'us', String category = 'general'}) async {
    final url = Uri.parse(
      '$_baseUrl/top-headlines?country=$country&category=$category&pageSize=20&apiKey=$_apiKey',
    );

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List articles = data['articles'] ?? [];
        return articles
            .map((a) => Article.fromJson(a))
            .where((a) => a.title != '[Removed]')
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Article>> searchNews(String query) async {
    final url = Uri.parse(
      '$_baseUrl/everything?q=${Uri.encodeComponent(query)}&sortBy=publishedAt&pageSize=20&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List articles = data['articles'] ?? [];
        return articles
            .map((a) => Article.fromJson(a))
            .where((a) => a.title != '[Removed]')
            .toList();
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
