class OrderSummanyItem {
  final String partNo;
  final String description;
  final String unit;
  final String perPack;
  final String price;
  final String sum;
  final String quantity;
  final String foc;
  final String discount;
  final String tax;
  final String amount;
  final String lite;
  final String invisiblePartNo; // not use to print
  final String invisibleOrderNumber; // not use to print

  OrderSummanyItem({
    required this.partNo,
    required this.description,
    required this.unit,
    required this.perPack,
    required this.price,
    required this.sum,
    required this.quantity,
    required this.foc,
    required this.discount,
    required this.tax,
    required this.amount,
    required this.lite,
    required this.invisiblePartNo,
    required this.invisibleOrderNumber,
  });
}

class OsrReportModel {
  final String page;
  final String smNumber;
  final String date;
  final String time;
  final String dateSelectedFrom;
  final String dateSelectedTo;
  final List<OrderSummanyItem> orderList;
  final String totalAmount;
  final String totalLit;
  final String referenceList;

  OsrReportModel({
    required this.page,
    required this.smNumber,
    required this.date,
    required this.time,
    required this.dateSelectedFrom,
    required this.dateSelectedTo,
    required this.orderList,
    required this.totalAmount,
    required this.totalLit,
    required this.referenceList,
  });
}
