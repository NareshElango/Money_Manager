import 'package:flutter/material.dart';
import 'package:money_manager/db/dbhelper.dart';

class addpage extends StatefulWidget {
  const addpage({Key? key}) : super(key: key);

  @override
  State<addpage> createState() => _addpageState();
}

class _addpageState extends State<addpage> {
  DateTime selected = DateTime.now();
  late dbhelper help;
  int? amount;
  String note = "some expense";
  String type = "income";
  void initState() {
    super.initState();
    help = dbhelper();
    //help.init(); // Initialize the dbhelper
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101, 30),
    );

    if (picked != null && picked != selected) {
      setState(() {
        selected = picked;
      });
    }
  }

  bool isIncomeSelected = true;
  bool isExpenseSelected = false;

  Widget items() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.0, left: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: Icon(Icons.currency_rupee),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Amount',
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        try {
                          amount = int.parse(val);
                        } catch (e) {
                          print(e);
                        }
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, left: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 30.0),
                    child: Icon(Icons.notes_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Note For Transcation',
                        hintMaxLines: 2,
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        note = val;
                      },
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, left: 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 22.0),
                    child: Icon(Icons.date_range),
                  ),
                  TextButton(
                    onPressed: () {
                      selectDate(context);
                    },
                    child: Text(
                      "${selected.toLocal()}".split(' ')[0],
                      style: TextStyle(fontSize: 15.0, color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, left: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 30.0),
                child: Icon(Icons.compare_arrows_rounded),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isIncomeSelected = true;
                    isExpenseSelected = false;
                    type = "Income";
                  });
                },
                child: Text(
                  'Income',
                  style: TextStyle(
                    color: isIncomeSelected ? Colors.white : Colors.black,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    isIncomeSelected ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    isIncomeSelected = false;
                    isExpenseSelected = true;
                    type = "Expense";
                  });
                },
                child: Text(
                  'Expense',
                  style: TextStyle(
                    color: !isIncomeSelected ? Colors.white : Colors.black,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    !isIncomeSelected ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: OutlinedButton(
            onPressed: () async {
              // print(amount);
              // print(note);
              // print(type);
              // print(selected);
              if (amount != null && note.isNotEmpty) {
                dbhelper help = dbhelper();
                //await help._initBox();
                await help.addData(amount!, selected, note, type);
                print("added successfully");
              } else {
                print("some value is null");
              }
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 70.0, right: 70.0, top: 10.0, bottom: 10.0),
              child: Text(
                "Add transaction",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Transactions"),
      ),
      body: SingleChildScrollView(
        child: items(),
      ),
    );
  }
}
