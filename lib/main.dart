import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JSON',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureProvider<List<Office>>(
        initialData: OfficeProvider().offices,
        create: (_) async => OfficeProvider().getOfficesList(),
        child: const MyHomePage(title: 'Flutter JSON Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<List<Office>>(
              builder: (context, List<Office> offices, _) {
                return Expanded(
                  child: offices.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: offices.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text('${offices[index].name}'),
                                subtitle: Text('${offices[index].address}'),
                                leading:
                                    Image.network('${offices[index].image}'),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OfficesList {
  List<Office>
      offices; // лист, который типизирован классом офис, т.е. он может содержать в себе объекты класса офис
  OfficesList({required this.offices});
  OfficesList.fromJson(List<dynamic> json)
      : offices = json.map((office) => Office.fromJson(office)).toList();
}

class Office {
  final String name;
  final String address;
  final String image;

  Office({required this.name, required this.address, required this.image});

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office // возвращаем объект Office
        (
            name: json['name'] as String,
            address: json['address'] as String,
            image: json['image'] as String);
  }
}

class OfficeProvider {
  List<Office> offices = [];

  Future<List<Office>> getOfficesList() async {
    const String url = "https://about.google/static/data/locations.json";
    final response = await http.get(Uri.parse(url));

    Map<String, dynamic> jsonOfficeData = json.decode(response.body);
    offices = OfficesList.fromJson(jsonOfficeData['offices']).offices;

    if (response.statusCode == 200) {
      return offices;
    } else {
      throw Exception('Error: ${response.reasonPhrase}');
    }
  }

  /*Future<OfficesList> getOfficesList() async {
    const url = 'https://about.google/static/data/locations.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return OfficesList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error: ${response.reasonPhrase}');
    }
  } */
}
