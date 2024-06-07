import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CitySelectionScreen(),
    );
  }
}

class CitySelectionScreen extends StatelessWidget {
  final Map<String, String> cities = {
    'Kampala': 'Uganda',
    'Juba': 'South Sudan',
    'Nairobi': 'Kenya',
    'Kigali': 'Rwanda',
    'Dodoma': 'Tanzania'
  };

  CitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select City'),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          String city = cities.keys.elementAt(index);
          return ListTile(
            title: Text(city),
            subtitle: Text(cities[city]!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherDetailsScreen(city: city),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WeatherDetailsScreen extends StatelessWidget {
  final String city;

  const WeatherDetailsScreen({super.key, required this.city});

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    const apiKey = '2369675f61bc42fe83e115355240306';
    final response = await http.get(Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=1'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Details for $city'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchWeather(city),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final weather = snapshot.data;
            final location = weather?['location'];
            final current = weather?['current'];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${location['name']}, ${location['country']}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temperature: ${current['temp_c']}°C',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Condition: ${current['condition']['text']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wind: ${current['wind_kph']} kph',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Humidity: ${current['humidity']}%',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
