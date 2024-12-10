import 'package:flutter/material.dart';
import 'services/currency_service.dart';
///github: sbgdnm
void main() {
  runApp(const CurrencyConverterApp());
}

/// Главный класс приложения
class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Отключаем баннер "Debug"
      title: 'Конвертер валют', // Название приложения
      theme: ThemeData(
        primarySwatch: Colors.blue, // Основной цвет темы
      ),
      home: const CurrencyConverterScreen(), // Главный экран приложения
    );
  }
}

/// Экран конвертера валют
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

/// Состояние экрана конвертера валют
class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  // Контроллер для отслеживания текста в поле ввода
  final TextEditingController _amountController = TextEditingController();
  final CurrencyService _currencyService = CurrencyService(); // экземпляр сервиса

  // Исходная валюта
  String _fromCurrency = 'USD'; // По умолчанию USD
  // Целевая валюта
  String _toCurrency = 'EUR';   // По умолчанию EUR

  double? _result; // Хранит результат конвертации

  // Список доступных валют для выбора
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY' , 'KZT' , 'RUB' , 'AED' , 'ALL' , 'UZS' , 'UAH' , 'EGP'];

  /// Метод для выполнения конвертации валют
  /// Здесь используется простая логика с фиксированным курсом
  // *void _convert() {
  //   setState(() {
  //     // Преобразуем введенное значение в число
  //     double amount = double.tryParse(_amountController.text) ?? 0;
  //
  //     // Список фиктивных курсов для демонстрации
  //     final exchangeRates = {
  //       'USD': {'EUR': 0.85, 'GBP': 0.75, 'JPY': 110.0, 'USD': 1.0},
  //       'EUR': {'USD': 1.18, 'GBP': 0.88, 'JPY': 129.0, 'EUR': 1.0},
  //       'GBP': {'USD': 1.34, 'EUR': 1.14, 'JPY': 150.0, 'GBP': 1.0},
  //       'JPY': {'USD': 0.0091, 'EUR': 0.0078, 'GBP': 0.0067, 'JPY': 1.0},
  //     };
  //
  //     // Получаем коэффициент для выбранных валют
  //     double rate = exchangeRates[_fromCurrency]?[_toCurrency] ?? 1.0;
  //
  //     // Вычисляем результат
  //     _result = amount * rate;
  //   });
  // }
  ///реализация через API
  void _convert() async {
    if (_amountController.text.isEmpty) {
      setState(() {
        _result = null;
      });
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0;

    setState(() {
      _result = null;
    });

    try {
      // Получаем курсы валют
      Map<String, double> rates = await _currencyService.fetchRates();

      // Вычисляем коэффициент
      double fromRate = rates[_fromCurrency] ?? 1.0;
      double toRate = rates[_toCurrency] ?? 1.0;

      if (fromRate == 0 || toRate == 0) {
        throw Exception('Не удалось найти курс для выбранной валюты');
      }

      // Конвертируем валюту
      setState(() {
        _result = (amount / fromRate) * toRate;
      });
    } catch (e) {
      setState(() {
        _result = null;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'), // Заголовок приложения
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Отступы вокруг содержимого
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Поле ввода суммы
            TextField(
              controller: _amountController, // Привязываем контроллер для ввода текста
              keyboardType: TextInputType.number, // Только числовой ввод
              decoration: const InputDecoration(
                labelText: 'Введите сумму', // Подпись для поля ввода
                border: OutlineInputBorder(), // Обрамление поля ввода
              ),
            ),
            const SizedBox(height: 16), // Отступ между элементами
            // Выпадающие списки для выбора валют
            Row(
              children: [
                Expanded(
                  // Список для выбора исходной валюты
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency, // Текущая выбранная валюта
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency), // Название валюты
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!; // Обновляем выбранную валюту
                        _result = null; // Сбрасываем результат
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Из', // Подпись для выпадающего списка
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Отступ между списками
                Expanded(
                  // Список для выбора целевой валюты
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!; // Обновляем выбранную валюту
                        _result = null; // Сбрасываем результат
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'В', // Подпись для выпадающего списка
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Отступ между элементами
            // Кнопка "Конвертировать"
            ElevatedButton(
              onPressed: _convert, // Вызываем метод при нажатии
              child: const Text('Конвертировать'), // Текст на кнопке
            ),
            const SizedBox(height: 16),
            // Отображение результата, если он доступен
            if (_result != null)
              Text(
                'Результат: $_result $_toCurrency', // Отображаем результат
                style: const TextStyle(fontSize: 18), // Размер текста
              ),
          ],
        ),
      ),
    );
  }
}