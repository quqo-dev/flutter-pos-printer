class StockItem {
  final String productCode;
  final String description;
  final String perPack;
  final String unitCode;
  final String baseUnit;
  final String onHandGood;
  final String onCarGood;
  final String location;

  StockItem({
    required this.productCode,
    required this.description,
    required this.perPack,
    required this.unitCode,
    required this.baseUnit,
    required this.onHandGood,
    required this.onCarGood,
    required this.location,
  });
}

class CsrReportModel {
  final String page;
  final String smNumber;
  final String date;
  final String time;
  final String createDate;
  final List<StockItem> stockList;
  final String totalRecord;

  CsrReportModel({
    required this.page,
    required this.smNumber,
    required this.date,
    required this.time,
    required this.createDate,
    required this.stockList,
    required this.totalRecord,
  });
}
