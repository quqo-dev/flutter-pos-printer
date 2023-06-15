class RrProductItem {
  final String productCode;
  final String description;
  final String perPack;
  final String unitCode;
  final String quantity;

  RrProductItem({
    required this.productCode,
    required this.description,
    required this.perPack,
    required this.unitCode,
    required this.quantity,
  });
}

class RrListItem {
  final String title;
  final List<RrProductItem> productList;

  RrListItem({
    required this.title,
    required this.productList,
  });
}

class RrsrReportModel {
  final String smNumber;
  final String date;
  final String time;
  final String subtitle;
  final String ref;
  final String fromWh;
  final String toWh;
  final List<RrListItem> rrList;

  RrsrReportModel({
    required this.smNumber,
    required this.date,
    required this.time,
    required this.subtitle,
    required this.ref,
    required this.fromWh,
    required this.toWh,
    required this.rrList,
  });
}
