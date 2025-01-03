import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

String httpAddress = "";
double controlLineSpacing = 5;

double? checkDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class Product {
  int? productID;
  String? productCode;
  String? productSerial;
  String? productName;
  String? productImage;
  String? productColor;
  String? productSize;
  double? productPrice;
  int? productVolume;
  String? unitCode;
  String? subGroup;
  String? description;
  bool? isDisabled;
  double? productPartnerPrice;

  Product({this.productID, this.productColor, this.productSize});
  Product.empty();

  factory Product.fromJson(Map<String, dynamic> json) {
    var retVal = Product();
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
    return retVal;
  }

  Map<String, dynamic> toJson() => {
    'productID': productID ?? 0,
    'productCode': productCode,
    'productName': productName,
    'unitCode': unitCode,
    'productPrice': productPrice,
    'productColor': productColor,
    'productSize': productSize,
  };

  bool isOne(Product obj) {
    return productID == obj.productID &&
        (productColor ?? "") == (obj.productColor ?? "") &&
        (productSize ?? "") == (obj.productSize ?? "");
  }
}

class CodeDetail {
  String? code;
  String? name;
  bool isChecked = false;

  CodeDetail({this.code});
  CodeDetail.empty();

  factory CodeDetail.fromJson(Map<String, dynamic> json) {
    var retVal = CodeDetail();
    retVal.code = json['code'];
    retVal.name = json['name'];
    return retVal;
  }
}

class Customer {
  int? customerID;
  String? customerCode;
  String? customerName;
  String? customerAddress;
  String? customerPhoneNumber;

  Customer();

  factory Customer.fromJson(Map<String, dynamic> json) {
    var retVal = Customer();
    retVal.customerID = json['customerID'];
    retVal.customerCode = json['customerCode'];
    retVal.customerName = json['customerName'];
    retVal.customerAddress = json['customerAddress'];
    retVal.customerPhoneNumber = json['customerPhoneNumber'];
    return retVal;
  }

  Map<String, dynamic> toJson() => {
    'customerID': customerID ?? 0,
    'customerCode': customerCode,
    'customerName': customerName,
    'customerAddress': customerAddress,
    'customerPhoneNumber': customerPhoneNumber,
  };
}

class InwardInvoice {
  int? inwardInvoiceID;
  int? supplierID;
  DateTime? purchaseDate;
  DateTime? inwardDate;
  double? invoiceAmount;
  int? paymentInvoiceID;
  String? inwardPOCode;
  DateTime? paidDate;
  bool? isChecked;
  DateTime? paymentDate;
  List<InwardInvoiceDetail>? inwardInvoiceDetails;

  InwardInvoice();

  factory InwardInvoice.fromJson(Map<String, dynamic> json) {
    try {
      var retVal = InwardInvoice();
      retVal.inwardInvoiceID = json['inwardInvoiceID'];
      retVal.supplierID = json['supplierID'];
      retVal.purchaseDate =
          json['purchaseDate'] == null
              ? null
              : DateTime.parse(json['purchaseDate']);
      retVal.inwardDate =
          json['inwardDate'] == null
              ? null
              : DateTime.parse(json['inwardDate']);
      retVal.invoiceAmount = checkDouble(json['invoiceAmount']);
      retVal.paymentInvoiceID = json['paymentInvoiceID'];
      retVal.inwardPOCode = json['inwardPOCode'];
      retVal.paidDate =
          json['paidDate'] == null ? null : DateTime.parse(json['paidDate']);
      retVal.paymentDate =
          json['paymentDate'] == null
              ? null
              : DateTime.parse(json['paymentDate']);
      List<dynamic> jsonIwardInvoiceDetails = json['inwardInvoiceDetails'];
      var details =
          jsonIwardInvoiceDetails
              .map((e) => InwardInvoiceDetail.fromJson(e))
              .toList();
      retVal.inwardInvoiceDetails = details;
      return retVal;
    } catch (exception) {
      log(exception.toString());
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'inwardInvoiceID': inwardInvoiceID ?? 0,
    'supplierID': supplierID,
    'purchaseDate': purchaseDate?.toIso8601String(),
    'inwardDate': inwardDate?.toIso8601String(),
    'invoiceAmount': invoiceAmount,
    'paymentInvoiceID': paymentInvoiceID,
    'inwardPOCode': inwardPOCode,
    'paidDate': paidDate,
    'paymentDate': paymentDate,
    'inwardInvoiceDetails':
        inwardInvoiceDetails?.map((e) => e.toJson()).toList(),
  };
}

class InwardInvoiceDetail {
  int? inwardInvoiceDetailID;
  int? inwardInvoiceID;
  int? productID;
  Product? product;
  double? inBuyingPrice;
  int? inQuantity;
  String? currentColorCode;
  String? currentSizeCode;

  InwardInvoiceDetail({
    this.inwardInvoiceDetailID,
    this.inwardInvoiceID,
    this.inBuyingPrice,
    this.inQuantity,
    this.product,
  });
  InwardInvoiceDetail.empty();

  factory InwardInvoiceDetail.fromJson(Map<String, dynamic> json) {
    try {
      var retVal = InwardInvoiceDetail();
      retVal.inwardInvoiceID = json['inwardInvoiceID'];
      retVal.inwardInvoiceDetailID = json['inwardInvoiceDetailID'];
      retVal.inBuyingPrice = json['inBuyingPrice'];
      retVal.inQuantity = json['inQuantity'];
      retVal.productID = json['productID'];
      retVal.product = Product.fromJson(json['product']);
      retVal.currentColorCode = json['currentColorCode'];
      retVal.currentSizeCode = json['currentSizeCode'];
      return retVal;
    } catch (exception) {
      log(exception.toString());
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'inwardInvoiceDetailID': inwardInvoiceDetailID ?? 0,
    'inwardInvoiceID': inwardInvoiceID ?? 0,
    'inBuyingPrice': inBuyingPrice,
    'inQuantity': inQuantity,
    'productID': productID,
    'product': product?.toJson(),
    'currentColorCode': currentColorCode,
    'currentSizeCode': currentSizeCode,
  };
}

class OutwardInvoice {
  int? outwardInvoiceID;
  int? customerID;
  DateTime? purchaseDate;
  DateTime? outwardDate;
  double? invoiceAmount;
  int? paymentInvoiceID;
  String? outwardPOCode;
  bool? isChecked;
  DateTime? paymentDate;
  List<OutwardInvoiceDetail>? outwardInvoiceDetails;

  OutwardInvoice();

  factory OutwardInvoice.fromJson(Map<String, dynamic> json) {
    try {
      var retVal = OutwardInvoice();
      retVal.outwardInvoiceID = json['outwardInvoiceID'];
      retVal.customerID = json['customerID'];
      retVal.purchaseDate =
          json['purchaseDate'] == null
              ? null
              : DateTime.parse(json['purchaseDate']);
      retVal.outwardDate =
          json['outwardDate'] == null
              ? null
              : DateTime.parse(json['outwardDate']);
      retVal.invoiceAmount = checkDouble(json['invoiceAmount']);
      retVal.paymentInvoiceID = json['paymentInvoiceID'];
      retVal.outwardPOCode = json['outwardPOCode'];
      retVal.paymentDate =
          json['paymentDate'] == null
              ? null
              : DateTime.parse(json['paymentDate']);
      List<dynamic> jsonIwardInvoiceDetails = json['outwardInvoiceDetails'];
      var details =
          jsonIwardInvoiceDetails
              .map((e) => OutwardInvoiceDetail.fromJson(e))
              .toList();
      retVal.outwardInvoiceDetails = details;
      return retVal;
    } catch (exception) {
      log(exception.toString());
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'outwardInvoiceID': outwardInvoiceID ?? 0,
    'customerID': customerID,
    'purchaseDate': purchaseDate?.toIso8601String(),
    'outwardDate': outwardDate?.toIso8601String(),
    'invoiceAmount': invoiceAmount,
    'paymentInvoiceID': paymentInvoiceID ?? 0,
    'outwardPOCode': outwardPOCode,
    'paymentDate': paymentDate,
    'outwardInvoiceDetails':
        outwardInvoiceDetails?.map((e) => e.toJson()).toList(),
  };
}

class OutwardInvoiceDetail {
  int? outwardInvoiceDetailID;
  int? outwardInvoiceID;
  int? productID;
  Product? product;
  double? productPrice;
  int? outQuantity;

  OutwardInvoiceDetail({
    this.outwardInvoiceDetailID,
    this.outwardInvoiceID,
    this.productPrice,
    this.outQuantity,
    this.product,
  });
  OutwardInvoiceDetail.empty();

  factory OutwardInvoiceDetail.fromJson(Map<String, dynamic> json) {
    try {
      var retVal = OutwardInvoiceDetail();
      retVal.outwardInvoiceID = json['outwardInvoiceID'];
      retVal.outwardInvoiceDetailID = json['outwardInvoiceDetailID'];
      retVal.productPrice = json['productPrice'];
      retVal.outQuantity = json['outQuantity'];
      retVal.productID = json['productID'];
      retVal.product = Product.fromJson(json['product']);
      return retVal;
    } catch (exception) {
      log(exception.toString());
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'outwardInvoiceDetailID': outwardInvoiceDetailID ?? 0,
    'outwardInvoiceID': outwardInvoiceID ?? 0,
    'productPrice': productPrice,
    'outQuantity': outQuantity,
    'productID': productID,
    'product': product?.toJson(),
  };
}

class Supplier {
  int? supplierID;
  String? supplierCode;
  String? supplierName;
  String? supplierAddress;
  String? supplierPhoneNumber;

  Supplier();

  factory Supplier.fromJson(Map<String, dynamic> json) {
    try {
      var retVal = Supplier();
      retVal.supplierID = json['supplierID'];
      retVal.supplierCode = json['supplierCode'];
      retVal.supplierName = json['supplierName'];
      retVal.supplierAddress = json['supplierAddress'];
      retVal.supplierPhoneNumber = json['supplierPhoneNumber'];
      return retVal;
    } catch (exception) {
      log(exception.toString());
      rethrow;
    }
  }
}

enum PayType { mH, bH }

class PaidInwardInvoiceModel {
  List<int?>? invoiceIDCollection;
  DateTime? paymentDate;
  double? totalPaymentAmount;
  String? paymentNote;
  String? paymentInvoiceCode;
  PayType? payType;

  Map<String, dynamic> toJson() => {
    'invoiceIDCollection': invoiceIDCollection,
    'paymentDate': paymentDate?.toIso8601String(),
    'totalPaymentAmount': totalPaymentAmount,
    'paymentNote': paymentNote,
    'paymentInvoiceCode': paymentInvoiceCode,
    'payType': payType == PayType.mH ? 0 : 1,
  };
}

String dateTimeToString(DateTime? dateTime) {
  return dateTime != null && dateTime.year > 2000
      ? DateFormat('dd/MM/yyyy').format(dateTime)
      : "";
}

String doubleToString(double? value) {
  return NumberFormat("###,###", "en_US").format(value ?? 0);
}

double? stringToDouble(String? value) {
  if (value == null) return null;
  return double.tryParse(value.replaceAll(",", ""));
}

Future<List<Customer>> loadCustomers() async {
  final response = await http.get(Uri.parse('$httpAddress/Customer'));
  if (response.statusCode == 200) {
    List listJson = jsonDecode(response.body);
    var listObject = listJson.map((e) => Customer.fromJson(e)).toList();
    return listObject;
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<CodeDetail>> loadColors() async {
  final response = await http.get(
    Uri.parse('$httpAddress/CodeDetail/LoadColors'),
  );
  if (response.statusCode == 200) {
    List listJson = jsonDecode(response.body);
    var listObject = listJson.map((e) => CodeDetail.fromJson(e)).toList();
    return listObject;
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<CodeDetail>> loadSizes() async {
  final response = await http.get(
    Uri.parse('$httpAddress/CodeDetail/LoadSizes'),
  );
  if (response.statusCode == 200) {
    List listJson = jsonDecode(response.body);
    var listObject = listJson.map((e) => CodeDetail.fromJson(e)).toList();
    return listObject;
  } else {
    throw Exception('Failed to load album');
  }
}

class ProductImage {
  int? productID;
  String? productURL;

  ProductImage({this.productURL});
  ProductImage.empty();

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    try {
      var retVal = ProductImage();
      retVal.productID = json['productID'];
      retVal.productURL = json['productURL'];
      return retVal;
    } catch (exception) {
      log(exception.toString());
      rethrow;
    }
  }
}
