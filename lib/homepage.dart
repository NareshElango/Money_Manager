import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_manager/addpage.dart';
import 'package:money_manager/db/dbhelper.dart';
import 'package:money_manager/find.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final dbhelper dbHelper = dbhelper();
  int totbal = 0;
  int totinc = 0;
  int totexp = 0;

  @override
  void initState() {
    super.initState();
    dbHelper.init();
    fetchData();
  }

  Map<String, dynamic> data = {};

  void fetchData() async {
    final fetchedData = await dbHelper.fetch();
    setState(() {
      data = fetchedData;
      getTotalBalance(data);
    });
  }

  void getTotalBalance(Map entireData) {
    totexp = 0;
    totbal = 0;
    totinc = 0;
    entireData.forEach((key, value) {
      if (value['Type'] == 'Income') {
        totinc += value['amount'] as int;
        totbal += value['amount'] as int;
      } else if (value['Type'] == 'Expense') {
        totexp += value['amount'] as int;
        totbal -= value['amount'] as int;
      }
    });
  }

  // void resetValues() {
  //   setState(() {
  //     totbal = 0;
  //     totinc = 0;
  //     totexp = 0;
  //   });
  // }

  Widget addButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 40, bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                    context, MaterialPageRoute(builder: (context) => addpage()))
                .whenComplete(() {
              setState(() {
                fetchData();
              });
            });
          },
          child: Icon(Icons.add),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        ),
      ),
    );
  }

  void resetvalues() async {
    var b = await Hive.openBox('money');
    await b.clear();
    setState(() {
      totbal = 0;
      totexp = 0;
      totinc = 0;
    });
  }

  void alertdialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure you want to reset all the values?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () {
                    resetvalues();
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              alertdialog();
            },
          ),
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Find()));
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dbHelper.fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No values Found"),
              );
            }
            getTotalBalance(snapshot.data!);
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome User",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        margin: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.grey, Colors.blueAccent]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Total Balance",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "₹$totbal",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    card("₹$totinc"),
                                    card1("₹$totexp"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Recent Expenses",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Map data = snapshot.data!.values.toList()[index];
                          DateTime? date = data['Date'] as DateTime?;
                          String formattedDate = date != null
                              ? '${date.day}-${date.month}-${date.year}'
                              : 'N/A';

                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    data['Note'] ?? '',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                  ),
                                  subtitle: Text(
                                    "  " + data['Type'] ?? ' ',
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                  ),
                                  trailing: Text(
                                    data['amount'] != null
                                        ? data['amount'].toString()
                                        : 'N/A',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  leading: Text(
                                    formattedDate,
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
        },
      ),
      floatingActionButton: addButton(),
    );
  }
}

Widget card(String val) {
  return Column(
    children: [
      Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(100.0)),
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(6.0),
        child: Icon(
          Icons.arrow_downward,
          color: Color.fromARGB(255, 255, 162, 1),
          size: 30,
        ),
      ),
      Text(
        val,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

Widget card1(String val) {
  return Column(
    children: [
      Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(6.0),
        child: Icon(
          Icons.arrow_upward_outlined,
          color: Color.fromARGB(255, 255, 1, 1),
          size: 30,
        ),
      ),
      Text(
        val,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
