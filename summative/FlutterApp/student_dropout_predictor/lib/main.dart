import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'splash_screen.dart';

void main() => runApp(DropoutPredictorApp());

class DropoutPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Dropout Predictor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashToMain(),
      debugShowCheckedModeBanner: false, // Add this line
    );
  }
}

class SplashToMain extends StatefulWidget {
  @override
  State<SplashToMain> createState() => _SplashToMainState();
}

class _SplashToMainState extends State<SplashToMain> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    PredictionTab(),
    AboutTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Predict'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PredictionTab extends StatefulWidget {
  @override
  State<PredictionTab> createState() => _PredictionTabState();
}

class _PredictionTabState extends State<PredictionTab> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'age_at_enrollment': TextEditingController(),
    'gender': TextEditingController(),
    'scholarship_holder': TextEditingController(),
    'first_sem_grade': TextEditingController(),
    'second_sem_grade': TextEditingController(),
    'debtor': TextEditingController(),
    'tuition_fees_up_to_date': TextEditingController(),
    'parents_avg_education': TextEditingController(),
    'financial_stress': TextEditingController(),
    'low_family_education': TextEditingController(),
  };
  String result = '';

  Future<void> predict() async {
    if (!_formKey.currentState!.validate()) return;
    final input = {
      'age_at_enrollment': int.parse(controllers['age_at_enrollment']!.text),
      'gender': int.parse(controllers['gender']!.text),
      'scholarship_holder': int.parse(controllers['scholarship_holder']!.text),
      'first_sem_grade': double.parse(controllers['first_sem_grade']!.text),
      'second_sem_grade': double.parse(controllers['second_sem_grade']!.text),
      'debtor': int.parse(controllers['debtor']!.text),
      'tuition_fees_up_to_date': int.parse(controllers['tuition_fees_up_to_date']!.text),
      'parents_avg_education': double.parse(controllers['parents_avg_education']!.text),
      'financial_stress': int.parse(controllers['financial_stress']!.text),
      'low_family_education': int.parse(controllers['low_family_education']!.text),
    };
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input),
      );
      if (response.statusCode == 200) {
        setState(() {
          result = jsonDecode(response.body)['prediction'];
        });
      } else {
        setState(() {
          result = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Student Dropout Predictor', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Input fields as cards
                ...controllers.entries.map((entry) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                        border: InputBorder.none,
                      ),
                      keyboardType: entry.key.contains('grade') || entry.key.contains('education')
                          ? TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                )),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: predict,
                  child: Text('Predict'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                SizedBox(height: 16),
                if (result.isNotEmpty)
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        result,
                        style: TextStyle(fontSize: 22, color: Colors.blueAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Student Dropout Predictor\n\nEnter student data to predict the risk of dropout, enrollment, or graduation.\n\nPowered by Machine Learning & FastAPI.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}