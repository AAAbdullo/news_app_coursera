import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=us&category=general&pageSize=20&apiKey=10297c0436284d039f15e6bbfe61e5c0');
  final response = await http.get(url);
  print(response.statusCode);
  print(response.body);
}
