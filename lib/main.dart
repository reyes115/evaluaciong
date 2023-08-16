import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wear/wear.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: ClockScreen(),
      ),
    );
  }
}

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Stream<DateTime> dateTimeStream;
  late Timer timer;
  bool isActiveMode = true;
  String weather = '';
  double temperature = 0;

  @override
  void initState() {
    super.initState();
    dateTimeStream = Stream<DateTime>.periodic(const Duration(seconds: 1), (_) {
      return DateTime.now();
    });
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
    fetchWeather();
  }

  void fetchWeather() async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=Queretaro,mx&appid=a52cc700aa46ffdd3630c1df00306fdf&units=metric'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final temperature = data['main']['temp'];
      final condition = data['weather'][0]['description'];
      setState(() {
        weather = '$condition, ${temperature.toStringAsFixed(1)}°C';
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      builder: (context, mode, child) {
        if (mode == WearMode.active) {
          isActiveMode = true;
        } else {
          isActiveMode = false;
        }

        return Stack(
          children: [
            Background(isActiveMode: isActiveMode),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<DateTime>(
                    stream: dateTimeStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Image.asset(
                              'assets/images/nube.png',
                              width: 15,
                              height: 15,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${temperature.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isActiveMode ? Colors.black : Colors.white,
                              ),
                            ),
                            DateTimeText(
                              dateTime: snapshot.data!,
                              isActiveMode: isActiveMode,
                            ),
                          ],
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  final bool isActiveMode;

  Background({required this.isActiveMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isActiveMode ? Colors.white : Colors.black,
    );
  }
}

class DateTimeText extends StatelessWidget {
  final DateTime dateTime;
  final bool isActiveMode;

  DateTimeText({required this.dateTime, required this.isActiveMode});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
    String formattedTime = DateFormat('hh:mm').format(dateTime);

    return Column(
      children: [
        Text(
          formattedTime,
          style: TextStyle(
              fontSize: 45,
              color: isActiveMode ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        Text(
          formattedDate,
          style: TextStyle(
              fontSize: 12,
              color: isActiveMode ? Colors.black : Colors.white,
              fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
