import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/homepage.dart';

class Find extends StatefulWidget {
  const Find({Key? key}) : super(key: key);

  @override
  State<Find> createState() => _FindState();
}

class _FindState extends State<Find> {
  TextEditingController _search = TextEditingController();
  List<dynamic> res = [];
  int total = 0;
  Future<void> getData() async {
    try {
      String datee = _search.text.trim();
      print("Searching for date: $datee");

      var box = await Hive.openBox('money');
      List<dynamic> da = box.values.where((element) {
        DateTime? date = element['Date'] as DateTime?;
        String formattedDate =
            date != null ? '${date.day}-${date.month}-${date.year}' : 'N/A';
        return formattedDate == datee;
      }).toList();

      setState(() {
        res = da;
      });

      if (da.isNotEmpty) {
        print("Elements found: ${da.length}");
      } else {
        print("No elements found for date: $datee");
      }
    } catch (e) {
      print("Error while fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => homepage()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search by Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: TextButton(
                  onPressed: getData,
                  child: const Text(
                    "Search",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                ),
                child: ListView.builder(
                  itemCount: res.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        res[index]['Note'].toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                      //leading: Text(res[index]['Date'].toString()),
                      trailing: Text(res[index]['amount'].toString(),
                          style: TextStyle(fontSize: 020)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
