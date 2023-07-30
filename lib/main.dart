import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.amber,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ),
      ),
      home: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Search'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: ImageSearchForm(),
    );
  }
}

class ImageSearchForm extends StatefulWidget {
  @override
  ImageSearchFormState createState() {
    return ImageSearchFormState();
  }
}

class ImageSearchFormState extends State<ImageSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _url;

  Future<String> fetchImageUrl(String searchTerm) async {
    String apiUrl = 'https://api.unsplash.com/search/photos?query=$searchTerm';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Client-ID xxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['results'].isEmpty) {
        throw Exception('No images found');
      }
      return data['results'][0]['urls']['small'];
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _controller,
                  style: TextStyle(color: Colors.amber),
                  decoration: InputDecoration(
                    labelText: 'Enter search term',
                    labelStyle: TextStyle(color: Colors.amber),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      fetchImageUrl(_controller.text).then((imageUrl) {
                        setState(() {
                          _url = imageUrl;
                        });
                      }).catchError((error) {
                        print('Error occurred: $error');
                      });
                    }
                    FocusScope.of(context).unfocus();
                  },
                  child: Text('Get Image'),
                ),
                SizedBox(height: 20),
                _url == null
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3.0,
                          ),
                        ),
                        child: Image.network(_url!),
                      ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
