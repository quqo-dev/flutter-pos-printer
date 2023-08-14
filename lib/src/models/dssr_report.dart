class StockModel {
  final String id;
  final String name;
  final String wh;
  final String perPack;
  final String openBal;
  final String sale;
  final String goodsReturn;
  final String transfIn;
  final String transfOut;
  final String focX;
  final String focY;
  final String closeBal;
  final String onhand;
  final String sortSequence;

  StockModel({
    required this.id,
    required this.name,
    required this.wh,
    required this.perPack,
    required this.openBal,
    required this.sale,
    required this.goodsReturn,
    required this.transfIn,
    required this.transfOut,
    required this.focX,
    required this.focY,
    required this.closeBal,
    required this.onhand,
    required this.sortSequence,
  });
}

class DssrReportModel {
  final String page;
  final String smNumber;
  final String date;
  final String time;
  final String selectedDate;
  final List<StockModel> stockList;
  final String total;

  DssrReportModel({
    required this.page,
    required this.smNumber,
    required this.date,
    required this.time,
    required this.selectedDate,
    required this.stockList,
    required this.total,
  });
}
