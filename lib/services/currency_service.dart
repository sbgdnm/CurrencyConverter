import 'dart:convert'; // Для работы с JSON
import 'package:http/http.dart' as http; // Для HTTP-запросов

class CurrencyService {
  /// API-ключ
  final String apiKey = '4281d3cb8d8d093df3c4606926358b09';

  /// Метод для получения курсов валют, сайт бесплатная версия и имеется только 100запросов на месяц :)
  Future<Map<String, double>> fetchRates() async {
    final url = 'http://api.currencylayer.com/live?access_key=$apiKey';

    try {
      // Выполняем GET-запрос
      final response = await http.get(Uri.parse(url));

      // Проверяем статус ответа
      if (response.statusCode == 200) {
        // Парсим JSON-ответ
        final Map<String, dynamic> data = json.decode(response.body);

        // Проверяем успешность запроса
        if (data['success'] != true) {
          throw Exception('Ошибка API: ${data['error']['info']}');
        }

        // Возвращаем только курсы валют
        return (data['quotes'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key.substring(3), value.toDouble()),
        );
      } else {
        throw Exception(
            'Ошибка загрузки данных: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Ошибка сети: $error');
    }
  }
}
