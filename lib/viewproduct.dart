import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dataentities.dart';

Future<List<Product>> loadProducts() async {
  final response = await http.get(Uri.parse('$httpAddress/Product'));
  if (response.statusCode == 200) {
    List listJson = jsonDecode(response.body);
    var listObject = listJson.map((e) => Product.fromJson(e)).toList();
    listObject.sort((a, b) => a.productID! > b.productID! ? 1 : -1);
    return listObject;
  } else {
    throw Exception('Failed to load album');
  }
}

Future saveProductImages(int productId, List<String> productUrls) async {
  final response = await http.post(
    Uri.parse('$httpAddress/Product/SaveProductImages?productId=$productId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(productUrls),
  );
  if (response.statusCode != 200) {
    throw Exception(utf8.decode(response.bodyBytes));
  }
}

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  late Future<List<Product>> datasource;
  late Future<List<CodeDetail>> units;
  late Future<List<CodeDetail>> sizes;
  late Future<List<CodeDetail>> colors;
  String? unitCode;

  Future<List<ProductImage>> loadProductImages(int? productId) async {
    final response = await http.get(
      Uri.parse('$httpAddress/Product/GetProductImages?productId=$productId'),
    );
    if (response.statusCode == 200) {
      List listJson = jsonDecode(response.body);
      var listObject = listJson.map((e) => ProductImage.fromJson(e)).toList();
      productImageDatas = listObject;
      return listObject;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<CodeDetail>> loadUnits() async {
    final response = await http.get(Uri.parse('$httpAddress/Product/GetUnits'));
    if (response.statusCode == 200) {
      List listJson = jsonDecode(response.body);
      var listObject = listJson.map((e) => CodeDetail.fromJson(e)).toList();
      return listObject;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<Product> saveData(Product data) async {
    final response = await http.post(
      Uri.parse('$httpAddress/Product'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  List<List<T>> chunk<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    int len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      int size = i + chunkSize;
      chunks.add(list.sublist(i, size > len ? len : size));
    }
    return chunks;
  }

  int? productId;
  var txtCode = TextEditingController();
  var txtName = TextEditingController();
  var txtPrice = TextEditingController();
  List<CodeDetail> colorsDatas = [];
  List<CodeDetail> sizeDatas = [];
  Future<void> _dialogBuilder(
    BuildContext context,
    int? productId, {
    List<CodeDetail>? prodColors,
    List<CodeDetail>? prodSizes,
  }) async {
    var isFirstLoadColorDialog = false;
    var isFirstLoadSizeDialog = false;
    this.productId = productId;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('THÔNG TIN SẢN PHẨM'),
              content: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 5.0,
                      minWidth: 720.0,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                      maxWidth: 1000.0,
                    ),
                    child: DefaultTabController(
                      length: 3,
                      child: Scaffold(
                        appBar: AppBar(
                          bottom: TabBar(
                            tabs: [
                              Tab(text: "Thông tin"),
                              Tab(text: "Màu"),
                              Tab(text: "Kích cỡ"),
                            ],
                          ),
                          toolbarHeight: 0,
                        ),
                        body: TabBarView(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: controlLineSpacing),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      child: const Text('Mã:'),
                                    ),
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
                                    SizedBox(
                                      width: 35,
                                      child: const Text('Tên:'),
                                    ),
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
                                    SizedBox(
                                      width: 35,
                                      child: const Text('ĐVT:'),
                                    ),
                                    FutureBuilder(
                                      future: units,
                                      builder: (context, snapshot) {
                                        return DropdownButton<String>(
                                          hint: Text("Nhập ĐVT"),
                                          value: unitCode,
                                          onChanged: (newValue) {
                                            setState(() {
                                              unitCode = newValue;
                                            });
                                          },
                                          items:
                                              snapshot.data
                                                  ?.map(
                                                    (fc) => DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: fc.code,
                                                      child: Text(
                                                        fc.name ?? "",
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: controlLineSpacing),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      child: const Text('Giá:'),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: txtPrice,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Nhập giá',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]'),
                                          ),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            FutureBuilder(
                              future: colors,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (isFirstLoadColorDialog == false) {
                                    isFirstLoadColorDialog = true;
                                    colorsDatas = snapshot.data!;
                                    snapshot.data?.forEach((e) {
                                      e.isChecked =
                                          prodColors?.any(
                                            (c) => c.code == e.code,
                                          ) ==
                                          true;
                                    });
                                  }
                                  return Column(
                                    children:
                                        chunk(snapshot.data!, 6)
                                            .map(
                                              (e) => Row(
                                                children:
                                                    e
                                                        .map(
                                                          (c) => Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 120,
                                                                child: Row(
                                                                  children: [
                                                                    Checkbox(
                                                                      value:
                                                                          c.isChecked,
                                                                      onChanged: (
                                                                        value,
                                                                      ) {
                                                                        setState(() {
                                                                          c.isChecked =
                                                                              value ==
                                                                              true;
                                                                        });
                                                                      },
                                                                      tristate:
                                                                          false,
                                                                    ),
                                                                    Text(
                                                                      "${c.name}",
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                        .toList(),
                                              ),
                                            )
                                            .toList(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("Error");
                                }
                                return Text("Loading...");
                              },
                            ),
                            FutureBuilder(
                              future: sizes,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (isFirstLoadSizeDialog == false) {
                                    isFirstLoadSizeDialog = true;
                                    sizeDatas = snapshot.data!;
                                    snapshot.data?.forEach((e) {
                                      e.isChecked =
                                          prodSizes?.any(
                                            (c) => c.code == e.code,
                                          ) ==
                                          true;
                                    });
                                  }
                                  return Column(
                                    children:
                                        chunk(snapshot.data!, 6)
                                            .map(
                                              (e) => Row(
                                                children:
                                                    e
                                                        .map(
                                                          (c) => Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 120,
                                                                child: Row(
                                                                  children: [
                                                                    Checkbox(
                                                                      value:
                                                                          c.isChecked,
                                                                      onChanged: (
                                                                        value,
                                                                      ) {
                                                                        setState(() {
                                                                          c.isChecked =
                                                                              value ==
                                                                              true;
                                                                        });
                                                                      },
                                                                      tristate:
                                                                          false,
                                                                    ),
                                                                    Text(
                                                                      "${c.name}",
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                        .toList(),
                                              ),
                                            )
                                            .toList(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("Error");
                                }
                                return Text("Loading...");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    var data = Product();
                    data.productID = productId;
                    data.unitCode = unitCode;
                    data.productCode = txtCode.text;
                    data.productName = txtName.text;
                    data.productPrice =
                        txtPrice.text.isEmpty
                            ? null
                            : stringToDouble(txtPrice.text);
                    data.productColor = colorsDatas
                        .where((c) => c.isChecked)
                        .map((e) => e.code)
                        .join("|");
                    data.productSize = sizeDatas
                        .where((c) => c.isChecked)
                        .map((e) => e.code)
                        .join("|");
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

  var txtUrl = TextEditingController();
  late Future<List<ProductImage>> productImages;
  List<ProductImage> productImageDatas = [];
  Future<void> _dialogImageBuilder(BuildContext context, int? productId) async {
    productImages = loadProductImages(productId);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('HÌNH ẢNH SẢN PHẨM'),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder(
                      future: productImages,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height - 300,
                            ),
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    children: [
                                      Image.network(
                                        snapshot.data![index].productURL!,
                                        fit: BoxFit.cover,
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 32.0,
                                        ),
                                        onPressed: () {
                                          if (productImageDatas.any(
                                            (e) =>
                                                e.productURL ==
                                                snapshot
                                                    .data![index]
                                                    .productURL!,
                                          )) {
                                            setState(() {
                                              productImageDatas.remove(
                                                productImageDatas.firstWhere(
                                                  (e) =>
                                                      e.productURL ==
                                                      snapshot
                                                          .data![index]
                                                          .productURL!,
                                                ),
                                              );
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Text("Loading...");
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: [
                        TextField(
                          controller: txtUrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nhập URL',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 32.0),
                          onPressed: () {
                            if (!productImageDatas.any(
                              (e) => e.productURL == txtUrl.text,
                            )) {
                              setState(() {
                                productImageDatas.add(
                                  ProductImage(productURL: txtUrl.text),
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Lưu'),
                  onPressed: () async {
                    if (productImageDatas.isNotEmpty) {
                      saveProductImages(
                        productId!,
                        productImageDatas.map((e) => e.productURL!).toList(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thành công!")),
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
    datasource = loadProducts();
    units = loadUnits();
    colors = loadColors();
    sizes = loadSizes();
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<List<Product>>(
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
                                'Giá',
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
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 32.0,
                                                    ),
                                                    onPressed: () {
                                                      txtCode.text =
                                                          fc.productCode ?? "";
                                                      txtName.text =
                                                          fc.productName ?? "";
                                                      unitCode = fc.unitCode;
                                                      txtPrice.text =
                                                          doubleToString(
                                                            fc.productPrice ??
                                                                0,
                                                          );
                                                      _dialogBuilder(
                                                        context,
                                                        fc.productID,
                                                        prodColors:
                                                            fc.productColor
                                                                ?.split("|")
                                                                .map(
                                                                  (e) =>
                                                                      CodeDetail(
                                                                        code: e,
                                                                      ),
                                                                )
                                                                .toList(),
                                                        prodSizes:
                                                            fc.productSize
                                                                ?.split("|")
                                                                .map(
                                                                  (e) =>
                                                                      CodeDetail(
                                                                        code: e,
                                                                      ),
                                                                )
                                                                .toList(),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.image,
                                                      size: 32.0,
                                                    ),
                                                    onPressed: () {
                                                      _dialogImageBuilder(
                                                        context,
                                                        fc.productID,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(fc.productCode ?? ""),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(fc.productName ?? "")),
                                      DataCell(
                                        Text(
                                          NumberFormat(
                                            "###,###",
                                            "en_US",
                                          ).format(fc.productPrice ?? 0),
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
