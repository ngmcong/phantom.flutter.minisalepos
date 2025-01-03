import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:minisalepos/viewcommon.dart';
import 'package:minisalepos/viewproduct.dart';

import 'dataentities.dart';

class InwardInvoiceView extends StatefulWidget {
  const InwardInvoiceView({super.key});

  @override
  State<InwardInvoiceView> createState() => _InwardInvoiceViewState();
}

class _InwardInvoiceViewState extends State<InwardInvoiceView> {
  late Future<List<InwardInvoice>> datasource;
  List<InwardInvoice> datasourceValues = [];
  List<InwardInvoice> selectedValues = [];
  late Future<List<Supplier>> suppliers;
  var inwardCommon = InwardCommon();

  Future<List<InwardInvoice>> loadDatas() async {
    final response = await http.get(Uri.parse('$httpAddress/Inward'));
    if (response.statusCode == 200) {
      List listJson = jsonDecode(response.body);
      var listObject = listJson.map((e) => InwardInvoice.fromJson(e)).toList();
      return listObject;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<Supplier>> loadSupplier() async {
    final response = await http.get(
      Uri.parse('$httpAddress/Inward/LoadSuppliers'),
    );
    if (response.statusCode == 200) {
      List listJson = jsonDecode(response.body);
      var listObject = listJson.map((e) => Supplier.fromJson(e)).toList();
      return listObject;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<InwardInvoice> saveData(InwardInvoice data) async {
    var body = jsonEncode(data.toJson());
    final response = await http.post(
      Uri.parse('$httpAddress/Inward'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return InwardInvoice.fromJson(jsonDecode(response.body));
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
  var txtInwardDate = TextEditingController();
  DateTime? inwardDate = DateTime.now();
  int? supplierId;
  bool confirmInward = false;
  Future<void> _dialogBuilder(
    BuildContext context,
    int? dataId,
    String? dataCode,
    DateTime? inwardDate,
    List<ProductExt> dataDetails,
  ) async {
    this.dataId = dataId;
    this.dataCode = dataCode;
    this.inwardDate = inwardDate;
    details = dataDetails;
    txtPurchaseDate.text = dateTimeToString(purchaseDate ?? DateTime.now());
    txtInwardDate.text = dateTimeToString(inwardDate);
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
                      SizedBox(width: 80, child: const Text('NCC:')),
                      Expanded(
                        child: FutureBuilder(
                          future: suppliers,
                          builder: (context, snapshot) {
                            return DropdownButton<int>(
                              hint: Text("Chọn nhà cung cấp"),
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
                                          value: fc.supplierID,
                                          child: Text(fc.supplierName ?? ""),
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
                        child: const Text('Xác nhận nhập hàng:'),
                      ),
                      Checkbox(
                        value: confirmInward,
                        onChanged: (value) {
                          setState(() {
                            confirmInward = value == true;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 80, child: const Text('Ngày nhập:')),
                      Expanded(
                        child: TextField(
                          controller: txtInwardDate,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập ngày nhập',
                          ),
                          readOnly: true,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!confirmInward) return;
                          inwardDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025),
                            initialDate: DateTime.now(),
                            helpText: 'Nhập ngày đặt',
                            cancelText: 'Đóng',
                            confirmText: 'Chọn',
                          );
                          txtInwardDate.text = dateTimeToString(inwardDate);
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
                                false,
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
                      DataColumn(
                        label: Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Màu sắc',
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
                                'Kích cỡ',
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
                                                false,
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
                                  DataCell(
                                    Text(
                                      colorDatas
                                              .where(
                                                (c) =>
                                                    c.code == fc.productColor,
                                              )
                                              .firstOrNull
                                              ?.name ??
                                          "",
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      sizeDatas
                                              .where(
                                                (c) => c.code == fc.productSize,
                                              )
                                              .firstOrNull
                                              ?.name ??
                                          "",
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
                    var data = InwardInvoice();
                    data.inwardInvoiceID = this.dataId;
                    data.inwardPOCode = this.dataCode;
                    data.supplierID = supplierId;
                    data.purchaseDate = purchaseDate;
                    if (confirmInward) data.inwardDate = inwardDate;
                    data.isChecked = false;
                    data.inwardInvoiceDetails =
                        details
                            .map(
                              (e) => InwardInvoiceDetail(
                                inwardInvoiceID: data.inwardInvoiceID,
                                inQuantity: e.qty,
                                inBuyingPrice: e.productPrice,
                                product: e,
                              ),
                            )
                            .toList();
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

  bool isFirstLoad = false;
  @override
  Widget build(BuildContext context) {
    if (!isFirstLoad) {
      isFirstLoad = true;
      datasource = loadDatas();
      products = loadProducts();
      suppliers = loadSupplier();
      colors = loadColors();
      sizes = loadSizes();
    }
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<List<InwardInvoice>>(
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
                                'Ngày nhập',
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
                                                    fc.inwardDate != null &&
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
                                                  supplierId = fc.supplierID;
                                                  purchaseDate =
                                                      fc.purchaseDate;
                                                  inwardDate = fc.inwardDate;
                                                  details =
                                                      fc.inwardInvoiceDetails?.map((
                                                        e,
                                                      ) {
                                                        var productExt =
                                                            ProductExt();
                                                        productExt.qty =
                                                            e.inQuantity;
                                                        productExt.productID =
                                                            e
                                                                .product
                                                                ?.productID;
                                                        productExt.productCode =
                                                            e
                                                                .product
                                                                ?.productCode;
                                                        productExt.productName =
                                                            e
                                                                .product
                                                                ?.productName;
                                                        productExt
                                                                .productPrice =
                                                            e.inBuyingPrice;
                                                        return productExt;
                                                      }).toList() ??
                                                      [];
                                                  confirmInward =
                                                      inwardDate != null;
                                                  _dialogBuilder(
                                                    context,
                                                    fc.inwardInvoiceID,
                                                    fc.inwardPOCode,
                                                    fc.inwardDate,
                                                    details,
                                                  );
                                                },
                                              ),
                                            ),
                                            Text(fc.inwardPOCode ?? ""),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(dateTimeToString(fc.purchaseDate)),
                                      ),
                                      DataCell(
                                        Text(dateTimeToString(fc.inwardDate)),
                                      ),
                                      DataCell(
                                        Text(dateTimeToString(fc.paidDate)),
                                      ),
                                      DataCell(
                                        Text(
                                          NumberFormat(
                                            "###,###",
                                            "en_US",
                                          ).format(fc.invoiceAmount ?? 0),
                                        ),
                                      ),
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
                  inwardDate = null;
                  txtInwardDate.clear();
                  confirmInward = false;
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
                  inwardCommon.paymentDialogBuilder(context, selectedValues);
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
