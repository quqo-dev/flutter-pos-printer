class CallingModel {
  final String date;
  final String custCode;
  final String custName;
  final String reason;
  final String typeOfShop;
  final String time;

  CallingModel({
    required this.date,
    required this.custCode,
    required this.custName,
    required this.reason,
    required this.typeOfShop,
    required this.time,
  });
}

class CclrReportModel {
  final String page;
  final String smNumber;
  final String date;
  final String time;
  final String dateSelectedFrom;
  final String dateSelectedTo;
  final List<CallingModel> callingList;
  final String total;
  final String grandTotal;

  CclrReportModel({
    required this.page,
    required this.smNumber,
    required this.date,
    required this.time,
    required this.dateSelectedFrom,
    required this.dateSelectedTo,
    required this.callingList,
    required this.total,
    required this.grandTotal,
  });
}
