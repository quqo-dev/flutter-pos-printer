class TransferItem {
  final String transferNo;
  final String locFrom;
  final String locTo;
  final String productCode;
  final String description;
  final String unitCode;
  final String perPack;
  final String quantity;
  final String unitPrice;
  final String amount;
  final String status;

  TransferItem({
    required this.transferNo,
    required this.locFrom,
    required this.locTo,
    required this.productCode,
    required this.description,
    required this.unitCode,
    required this.perPack,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    required this.status,
  });
}

class BtlReportModel {
  final String page;
  final String smNumber;
  final String date;
  final String time;
  final String reportNo;
  final List<TransferItem> transferList;
  final String totalRecord;
  final String totalAmount;

  BtlReportModel({
    required this.page,
    required this.smNumber,
    required this.date,
    required this.time,
    required this.reportNo,
    required this.transferList,
    required this.totalRecord,
    required this.totalAmount,
  });
}
