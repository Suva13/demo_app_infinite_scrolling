import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> data = <String>[];
  final _scrollController = ScrollController();
  final int limit = 25;
  int pageNo = 0;
  bool hasMore = true;

  bool isLoading = false;

  feacth() async {
    if (isLoading) return;
    isLoading = true;
    pageNo++;

    var url = Uri.parse(
        "https://jsonplaceholder.typicode.com/posts/?_limit=$limit&_page=$pageNo");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      setState(() {
        if (jsonResponse.length < limit) hasMore = false;

        data.addAll(jsonResponse.map<String>((value) {
          return "Item ${value['id']}";
        }));

        isLoading = false;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  void initState() {
    feacth();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        feacth();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: ListView.builder(
          controller: _scrollController,
          itemCount: data.length + 1,
          itemBuilder: (context, index) {
            if (index < data.length) {
              return ListTile(
                title: Text(
                  data[index],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Center(
                  child: hasMore
                      ? const CircularProgressIndicator(
                          color: Colors.pink,
                        )
                      : Container(),
                ),
              );
            }
          },
        ));
  }
}
