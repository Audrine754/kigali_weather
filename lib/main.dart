import 'package:flutter/material.dart';

import 'weather.dart';

void main() {
  runApp(const WeatherApp());
}

IconData iconFor(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code <= 3) return Icons.cloud;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 95) return Icons.thunderstorm;
  if (code >= 51) return Icons.water_drop;
  return Icons.help_outline;
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  City city = cities.first;
  Weather? weather;
  bool loading = true;
  String? error;
  bool offline = false; // true when showing saved weather

  @override
  void initState() {
    super.initState();
    start();
  }

  // Step 7: load the saved city first, then its weather
  Future<void> start() async {
    final saved = await readCity();
    if (!mounted) return;
    setState(() {
      city = saved;
    });
    await load();
  }

  Future<void> load() async {
    final requested = city;
    try {
      final result = await fetchWeather(requested);
      await saveWeather(requested, result); // step 8: save every success
      if (!mounted || requested != city) return; // user changed city meanwhile
      setState(() {
        weather = result;
        loading = false;
        error = null;
        offline = false;
      });
    } catch (e) {
      final saved = await readWeather(requested);
      if (!mounted || requested != city) return;
      setState(() {
        loading = false;
        weather = saved;
        offline = saved != null;
        error = saved == null
            ? 'Could not load the weather. Check your internet connection.'
            : null;
      });
    }
  }

  void selectCity(City chosen) {
    saveCity(chosen);
    setState(() {
      city = chosen;
      loading = true;
      error = null;
      offline = false;
    });
    load();
  }

  void retry() {
    setState(() {
      loading = true;
      error = null;
    });
    load();
  }

  Widget buildChips() {
    return Wrap(
      spacing: 8,
      children: [
        for (final c in cities)
          ChoiceChip(
            label: Text(c.name),
            selected: c.name == city.name,
            onSelected: (_) => selectCity(c),
          ),
      ],
    );
  }

  Widget buildBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Offline: showing the weather saved at ${weather!.time.split('T').last}.',
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget buildContent() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            Text(error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: retry, child: const Text('Retry')),
          ],
        ),
      );
    }
    final w = weather!;
    return Column(
      children: [
        if (offline) buildBanner(),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(iconFor(w.code), size: 96, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  '${w.temperature.round()}°C',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(describe(w.code), style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.water_drop_outlined),
                        Text('${w.humidity}%'),
                        const Text('Humidity'),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.air),
                        Text('${w.wind} km/h'),
                        const Text('Wind'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Updated at ${w.time.split('T').last}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${city.name} Weather')),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            buildChips(),
            const SizedBox(height: 16),
            buildContent(),
          ],
        ),
      ),
    );
  }
}