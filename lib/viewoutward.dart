import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:minisalepos/viewcommon.dart';
import 'package:minisalepos/viewproduct.dart';

import 'dataentities.dart';

class OutwardInvoiceView extends StatefulWidget {
  const OutwardInvoiceView({super.key});

  @override
  State<OutwardInvoiceView> createState() => _OutwardInvoiceViewState();
}

class _OutwardInvoiceViewState extends State<OutwardInvoiceView> {
  late Future<List<OutwardInvoice>> datasource;
  List<OutwardInvoice> datasourceValues = [];
  List<OutwardInvoice> selectedValues = [];
  late Future<List<Customer>> suppliers;
  var inwardCommon = InwardCommon();

  Future<List<OutwardInvoice>> loadDatas() async {
    final response = await http.get(Uri.parse('$httpAddress/Outward'));
    if (response.statusCode == 200) {
      List listJson = jsonDecode(response.body);
      var listObject = listJson.map((e) => OutwardInvoice.fromJson(e)).toList();
      return listObject;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<OutwardInvoice> saveData(OutwardInvoice data) async {
    var body = jsonEncode(data.toJson());
    final response = await http.post(
      Uri.parse('$httpAddress/Outward'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return OutwardInvoice.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        "[${response.reasonPhrase}] ${utf8.decode(response.bodyBytes)}",
      );
    }
  }

  Future<bool> exportData(OutwardInvoice data) async {
    var body = jsonEncode(data.toJson());
    final response = await http.post(
      Uri.parse('$httpAddress/Outward/ExportPurchaseOrder'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        "[${response.reasonPhrase}] ${utf8.decode(response.bodyBytes)}",
      );
    }
  }

  int? dataId;
  String? dataCode;
  var txtCode = TextEditingController();
  var txtPurchaseDate = TextEditingController();
  DateTime? purchaseDate = DateTime.now();
  var txtOutwardDate = TextEditingController();
  DateTime? outwardDate = DateTime.now();
  bool confirmOutward = false;
  int? supplierId;
  Future<void> _dialogBuilder(
    BuildContext context,
    int? dataId,
    String? dataCode,
    DateTime? outwardDate,
    List<ProductExt> dataDetails,
  ) async {
    this.dataId = dataId;
    this.dataCode = dataCode;
    this.outwardDate = outwardDate;
    details = dataDetails;
    txtPurchaseDate.text = dateTimeToString(purchaseDate ?? DateTime.now());
    txtOutwardDate.text = dateTimeToString(outwardDate);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('THÔNG TIN ĐẶT HÀNG'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 80, child: const Text('Khách hàng:')),
                      Expanded(
                        child: FutureBuilder(
                          future: suppliers,
                          builder: (context, snapshot) {
                            return DropdownButton<int>(
                              hint: Text("Chọn khách hàng"),
                              value: supplierId,
                              onChanged: (newValue) {
                                setState(() {
                                  supplierId = newValue;
                                });
                              },
                              items:
                                  snapshot.data
                                      ?.map(
                                        (fc) => DropdownMenuItem<int>(
                                          value: fc.customerID,
                                          child: Text(fc.customerName ?? ""),
                                        ),
                                      )
                                      .toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 80, child: const Text('Ngày đặt:')),
                      Expanded(
                        child: TextField(
                          controller: txtPurchaseDate,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập ngày đặt',
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: const Text('Xác nhận xuất hàng:'),
                      ),
                      Checkbox(
                        value: confirmOutward,
                        onChanged: (value) {
                          setState(() {
                            confirmOutward = value == true;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 80, child: const Text('Ngày xuất:')),
                      Expanded(
                        child: TextField(
                          controller: txtOutwardDate,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập ngày xuất',
                          ),
                          readOnly: true,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!confirmOutward) return;
                          outwardDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025),
                            initialDate: DateTime.now(),
                            helpText: 'Nhập ngày đặt',
                            cancelText: 'Đóng',
                            confirmText: 'Chọn',
                          );
                          txtOutwardDate.text = dateTimeToString(outwardDate);
                        },
                        icon: const Icon(Icons.calendar_view_day, size: 32.0),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      Text(
                        'Mặt hàng',
                        textAlign: TextAlign.left,
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 32.0),
                            onPressed: () {
                              newProduct = null;
                              product = null;
                              productDialogBuilder(
                                context,
                                () {
                                  setState(() {
                                    details = details;
                                  });
                                },
                                null,
                                null,
                                true,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Expanded(
                          child: Row(
                            children: [
                              SizedBox(width: 100),
                              Text(
                                'Mã',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Tên',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Giá',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Số lượng',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Thành tiền',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    rows:
                        details
                            .map(
                              (fc) => DataRow(
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
                                              txtPrice.text = doubleToString(
                                                fc.productPrice,
                                              );
                                              productDialogBuilder(
                                                context,
                                                () {
                                                  setState(() {
                                                    details = details;
                                                  });
                                                },
                                                DataID(
                                                  fc.productID,
                                                  color: fc.productColor,
                                                  size: fc.productSize,
                                                ),
                                                fc.qty,
                                                true,
                                              );
                                            },
                                          ),
                                        ),
                                        Text(fc.productCode ?? ""),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(fc.productName ?? "")),
                                  DataCell(
                                    Text(doubleToString(fc.productPrice)),
                                  ),
                                  DataCell(Text(fc.qty?.toString() ?? "")),
                                  DataCell(
                                    Text(
                                      doubleToString(
                                        (fc.productPrice ?? 0) * (fc.qty ?? 0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
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
                    var data = OutwardInvoice();
                    data.outwardInvoiceID = this.dataId;
                    data.outwardPOCode = this.dataCode;
                    data.customerID = supplierId;
                    data.purchaseDate = purchaseDate;
                    if (confirmOutward) data.outwardDate = outwardDate;
                    data.isChecked = false;
                    data.outwardInvoiceDetails =
                        details
                            .map(
                              (e) => OutwardInvoiceDetail(
                                outwardInvoiceID: data.outwardInvoiceID,
                                outQuantity: e.qty,
                                productPrice: e.productPrice,
                                product: e,
                              ),
                            )
                            .toList();
                    try {
                      if (confirmOutward) {
                        await exportData(data);
                      } else {
                        await saveData(data);
                      }
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

  bool isFirstLoad = false;
  @override
  Widget build(BuildContext context) {
    if (!isFirstLoad) {
      isFirstLoad = true;
      datasource = loadDatas();
      products = loadProducts();
      suppliers = loadCustomers();
      colors = loadColors();
      sizes = loadSizes();
    }
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<List<OutwardInvoice>>(
                future: datasource,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    datasourceValues = snapshot.data ?? [];
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
                        showCheckboxColumn: true,
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
                                'Ngày đặt',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Ngày xuất',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Ngày thanh toán',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Tổng tiền',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Người mua',
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
                                              width: 50,
                                              child: Visibility(
                                                visible:
                                                    fc.outwardDate != null &&
                                                    fc.paymentDate == null,
                                                child: Checkbox(
                                                  value: fc.isChecked == true,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      fc.isChecked =
                                                          value == true;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 32.0,
                                                ),
                                                onPressed: () {
                                                  purchaseDate =
                                                      fc.purchaseDate;
                                                  outwardDate = fc.outwardDate;
                                                  supplierId = fc.customerID;
                                                  details =
                                                      fc.outwardInvoiceDetails?.map(
                                                        (e) {
                                                          var productExt =
                                                              ProductExt();
                                                          productExt.qty =
                                                              e.outQuantity;
                                                          productExt.productID =
                                                              e
                                                                  .product
                                                                  ?.productID;
                                                          productExt
                                                              .productCode = e
                                                                  .product
                                                                  ?.productCode;
                                                          productExt
                                                              .productName = e
                                                                  .product
                                                                  ?.productName;
                                                          productExt
                                                              .productPrice = e
                                                                  .productPrice;
                                                          return productExt;
                                                        },
                                                      ).toList() ??
                                                      [];
                                                  confirmOutward =
                                                      outwardDate != null;
                                                  _dialogBuilder(
                                                    context,
                                                    fc.outwardInvoiceID,
                                                    fc.outwardPOCode,
                                                    fc.outwardDate,
                                                    details,
                                                  );
                                                },
                                              ),
                                            ),
                                            Text(fc.outwardPOCode ?? ""),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(dateTimeToString(fc.purchaseDate)),
                                      ),
                                      DataCell(
                                        Text(dateTimeToString(fc.outwardDate)),
                                      ),
                                      DataCell(
                                        Text(dateTimeToString(fc.paymentDate)),
                                      ),
                                      DataCell(
                                        Text(
                                          NumberFormat(
                                            "###,###",
                                            "en_US",
                                          ).format(fc.invoiceAmount ?? 0),
                                        ),
                                      ),
                                      DataCell(const Text('')),
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
                onPressed: () {
                  purchaseDate = DateTime.now();
                  outwardDate = null;
                  txtOutwardDate.clear();
                  confirmOutward = false;
                  _dialogBuilder(context, null, null, null, []);
                },
                child: Text('Đặt hàng'),
              ),
              TextButton(
                onPressed: () {
                  selectedValues =
                      datasourceValues
                          .where((e) => e.isChecked == true)
                          .toList();
                  if (selectedValues.isEmpty) return;
                  inwardCommon.paymentDialogBuilder(context, []);
                },
                child: Text('Thanh toán'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
