import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:minisalepos/dataentities.dart';

class ProductExt extends Product {
  int? qty;

  ProductExt();

  factory ProductExt.fromJson(Map<String, dynamic> json) {
    var retVal = ProductExt();
    retVal.productID = json['productID'];
    retVal.productCode = json['productCode'];
    retVal.productSerial = json['productSerial'];
    retVal.productName = json['productName'];
    retVal.productImage = json['productImage'];
    retVal.productColor = json['productColor'];
    retVal.productSize = json['productSize'];
    retVal.productPrice = checkDouble(json['productPrice']);
    retVal.unitCode = json['unitCode'];
    retVal.subGroup = json['subGroup'];
    retVal.description = json['description'];
    retVal.isDisabled = json['isDisabled'];
    retVal.productPartnerPrice = checkDouble(json['productPartnerPrice']);
    retVal.qty = json['qty'];
    return retVal;
  }
}

Future<bool> savePaymentData(PaidInwardInvoiceModel data) async {
  var body = jsonEncode(data.toJson());
  final response = await http.post(
    Uri.parse('$httpAddress/Inward/PaidInvoice'),
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

class DataID {
  int? id;
  String? color;
  String? size;

  DataID(this.id, {this.color, this.size});
}

late Future<List<Product>> products;
late Future<List<CodeDetail>> colors;
late Future<List<CodeDetail>> sizes;
List<CodeDetail> colorDatas = [];
List<CodeDetail> sizeDatas = [];
Product? product;
Product? newProduct;
var txtPrice = TextEditingController();
var txtQty = TextEditingController();
List<ProductExt> details = [];
bool isSetSalePrice = false;
String? colorCode;
String? sizeCode;
Future<void> productDialogBuilder(
  BuildContext context,
  Function callback,
  DataID? dataId,
  int? qty,
  bool isSetSalePrice,
) async {
  isSetSalePrice = isSetSalePrice;
  return showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('THÔNG TIN SẢN PHẨM'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(width: 80, child: const Text('Mặt hàng:')),
                    Expanded(
                      child: FutureBuilder(
                        future: products,
                        builder: (context, snapshot) {
                          if (dataId != null) {
                            product = snapshot.data?.firstWhere(
                              (element) => element.productID == dataId.id,
                            );
                            txtQty.text = qty.toString();
                            setState(() {
                              colors = colors;
                              sizes = sizes;
                            });
                          }
                          return DropdownSearch<Product>(
                            selectedItem: product,
                            onChanged: (newValue) {
                              setState(() {
                                newProduct = newValue;
                                if (isSetSalePrice) {
                                  txtPrice.text = doubleToString(
                                    newProduct?.productPrice,
                                  );
                                }
                                colors = colors;
                                sizes = sizes;
                              });
                            },
                            items:
                                (filter, loadProps) =>
                                    snapshot.data == null
                                        ? []
                                        : snapshot.data!
                                            .where(
                                              (x) =>
                                                  !isSetSalePrice ||
                                                  (x.productPrice != null &&
                                                      x.productPrice! > 0),
                                            )
                                            .toList(),
                            itemAsString: (item) => item.productName ?? "",
                            compareFn: (item1, item2) {
                              return item1.productID == item2.productID;
                            },
                            popupProps: PopupProps.menu(showSearchBox: true),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: controlLineSpacing),
                Row(
                  children: [
                    SizedBox(width: 80, child: const Text('Giá:')),
                    Expanded(
                      child: TextField(
                        controller: txtPrice,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Nhập giá',
                        ),
                        readOnly: isSetSalePrice,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: controlLineSpacing),
                Row(
                  children: [
                    SizedBox(width: 80, child: const Text('Số lượng:')),
                    Expanded(
                      child: TextField(
                        controller: txtQty,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Nhập số lượng',
                        ),
                        onChanged: (value) {},
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: controlLineSpacing),
                Row(
                  children: [
                    SizedBox(width: 80, child: const Text('Màu:')),
                    Expanded(
                      child: FutureBuilder(
                        future: colors,
                        builder: (context, snapshot) {
                          colorDatas = snapshot.data ?? [];
                          return DropdownButton<String>(
                            hint: Text("Chọn nhà màu sắc"),
                            value: colorCode,
                            onChanged: (newValue) {
                              setState(() {
                                colorCode = newValue;
                              });
                            },
                            items:
                                snapshot.data
                                    ?.where(
                                      (c) => "|${newProduct?.productColor}|"
                                          .contains(c.code!),
                                    )
                                    .map(
                                      (fc) => DropdownMenuItem<String>(
                                        value: fc.code,
                                        child: Text(fc.name ?? ""),
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
                    SizedBox(width: 80, child: const Text('Kích cỡ:')),
                    Expanded(
                      child: FutureBuilder(
                        future: sizes,
                        builder: (context, snapshot) {
                          sizeDatas = snapshot.data ?? [];
                          return DropdownButton<String>(
                            hint: Text("Chọn nhà kích cỡ"),
                            value: sizeCode,
                            onChanged: (newValue) {
                              setState(() {
                                sizeCode = newValue;
                              });
                            },
                            items:
                                snapshot.data
                                    ?.where(
                                      (c) => "|${newProduct?.productSize}|"
                                          .contains(c.code!),
                                    )
                                    .map(
                                      (fc) => DropdownMenuItem<String>(
                                        value: fc.code,
                                        child: Text(fc.name ?? ""),
                                      ),
                                    )
                                    .toList(),
                          );
                        },
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
                  if (newProduct != null) product = newProduct;
                  if (product != null) {
                    ProductExt? sourceProduct;
                    if (dataId != null) {
                      sourceProduct = details.firstWhere(
                        (e) => e.isOne(
                          Product(
                            productID: dataId.id,
                            productColor: dataId.color,
                            productSize: dataId.size,
                          ),
                        ),
                      );
                      sourceProduct = ProductExt.fromJson(
                        jsonDecode(jsonEncode(product)),
                      );
                      sourceProduct.qty = int.parse(txtQty.text);
                      sourceProduct.productPrice = stringToDouble(
                        txtPrice.text,
                      );
                      sourceProduct.productColor = colorCode;
                      sourceProduct.productSize = sizeCode;
                      details[details.indexWhere(
                            (item) => item.isOne(
                              Product(
                                productID: dataId.id,
                                productColor: dataId.color,
                                productSize: dataId.size,
                              ),
                            ),
                          )] =
                          sourceProduct;
                    } else {
                      sourceProduct =
                          details.where((e) => e.isOne(product!)).firstOrNull;
                      if (sourceProduct != null) {
                        sourceProduct.qty = int.parse(txtQty.text);
                        sourceProduct.productPrice = stringToDouble(
                          txtPrice.text,
                        );
                        sourceProduct.productColor = colorCode;
                        sourceProduct.productSize = sizeCode;
                      } else {
                        var cloneProduct = ProductExt.fromJson(
                          jsonDecode(jsonEncode(product)),
                        );
                        cloneProduct.qty = int.parse(txtQty.text);
                        cloneProduct.productPrice = stringToDouble(
                          txtPrice.text,
                        );
                        cloneProduct.productColor = colorCode;
                        cloneProduct.productSize = sizeCode;
                        details.add(cloneProduct);
                      }
                    }
                    callback();
                    Navigator.of(context).pop();
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

class InwardCommon {
  InwardCommon();

  var txtDiscount = TextEditingController();
  String? totalPaymentAmount;
  var txtPaymentNote = TextEditingController();
  Future<void> paymentDialogBuilder(
    BuildContext context,
    List<InwardInvoice> selectedValues,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('THÔNG TIN THANH TOÁN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 100, child: const Text('Tổng giá trị:')),
                      Text(
                        doubleToString(
                          selectedValues.fold<double>(
                            0,
                            (sum, item) => sum + (item.invoiceAmount ?? 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 100, child: const Text('Chiết khấu:')),
                      Expanded(
                        child: TextField(
                          controller: txtDiscount,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập số tiền chiết khấu',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {
                              totalPaymentAmount = doubleToString(
                                selectedValues.fold<double>(
                                      0,
                                      (sum, item) =>
                                          sum + (item.invoiceAmount ?? 0),
                                    ) -
                                    double.parse(value),
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: const Text('Tổng số tiền thanh toán:'),
                      ),
                      Text(totalPaymentAmount ?? ""),
                    ],
                  ),
                  SizedBox(height: controlLineSpacing),
                  Row(
                    children: [
                      SizedBox(width: 100, child: const Text('Ghi chú:')),
                      Expanded(
                        child: TextField(
                          controller: txtPaymentNote,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập ghi chú',
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
                    var payData = PaidInwardInvoiceModel();
                    payData.invoiceIDCollection =
                        selectedValues.map((e) => e.inwardInvoiceID).toList();
                    payData.paymentNote = txtPaymentNote.text;
                    payData.totalPaymentAmount =
                        totalPaymentAmount == null
                            ? selectedValues.fold<double>(
                              0,
                              (sum, item) => sum + (item.invoiceAmount ?? 0),
                            )
                            : double.parse(totalPaymentAmount!);
                    payData.paymentDate = DateTime.now();
                    payData.payType = PayType.mH;
                    try {
                      savePaymentData(payData);
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
}
