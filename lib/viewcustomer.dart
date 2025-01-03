import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dataentities.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  late Future<List<Customer>> datasource;

  Future<Customer> saveData(Customer data) async {
    var body = jsonEncode(data.toJson());
    final response = await http.post(
      Uri.parse('$httpAddress/Customer'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  int? customerId;
  var txtCode = TextEditingController();
  var txtName = TextEditingController();
  var txtAddress = TextEditingController();
  var txtPhone = TextEditingController();
  Future<void> _dialogBuilder(BuildContext context, int? customerId) async {
    this.customerId = customerId;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('THÔNG TIN KHÁCH HÀNG'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 50, child: const Text('Mã:')),
                      Expanded(
                        child: TextField(
                          controller: txtCode,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập mã',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 50, child: const Text('Tên:')),
                      Expanded(
                        child: TextField(
                          controller: txtName,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập tên',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 50, child: const Text('Địa chỉ:')),
                      Expanded(
                        child: TextField(
                          controller: txtAddress,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập địa chỉ',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 50, child: const Text('SĐT:')),
                      Expanded(
                        child: TextField(
                          controller: txtPhone,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập SĐT',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Lưu'),
                  onPressed: () async {
                    var data = Customer();
                    data.customerID = this.customerId;
                    if (this.customerId != null) {
                      data.customerCode = txtCode.text;
                    }
                    data.customerName = txtName.text;
                    data.customerAddress = txtAddress.text;
                    data.customerPhoneNumber = txtPhone.text;
                    try {
                      await saveData(data);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    } catch (exception) {
                      showDialog(
                        context: context,
                        builder: (childContext) {
                          return AlertDialog(
                            title: const Text('LỖI'),
                            content: Text(exception.toString()),
                          );
                        },
                      );
                    }
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Thoát'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    datasource = loadCustomers();
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<List<Customer>>(
                future: datasource,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.blue,
                        ),
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.7,
                          ),
                          verticalInside: BorderSide(
                            color: Colors.grey,
                            width: 0.7,
                          ),
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.7,
                          ),
                          top: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.7,
                          ),
                          left: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.7,
                          ),
                          right: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.7,
                          ),
                        ),
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Expanded(
                              child: Row(
                                children: [
                                  SizedBox(width: 100),
                                  Text(
                                    'Mã',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Tên',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'SĐT',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Địa chỉ',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ],
                        rows:
                            snapshot.data!
                                .map(
                                  (fc) => DataRow(
                                    color: WidgetStateProperty.resolveWith((_) {
                                      return snapshot.data!.indexOf(fc) % 2 != 0
                                          ? Colors.grey.shade300
                                          : null;
                                    }),
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 32.0,
                                                ),
                                                onPressed: () {
                                                  txtCode.text =
                                                      fc.customerCode ?? "";
                                                  txtName.text =
                                                      fc.customerName ?? "";
                                                  _dialogBuilder(
                                                    context,
                                                    fc.customerID,
                                                  );
                                                },
                                              ),
                                            ),
                                            Text(fc.customerCode ?? ""),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(fc.customerName ?? "")),
                                      DataCell(
                                        Text(fc.customerPhoneNumber ?? ""),
                                      ),
                                      DataCell(Text(fc.customerAddress ?? "")),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    );
                  }
                  return Center(child: Image.asset('assets/loading.gif'));
                },
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              TextButton(
                onPressed: () => _dialogBuilder(context, null),
                child: Text('Thêm'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
