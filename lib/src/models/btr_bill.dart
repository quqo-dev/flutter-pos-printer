class FirstRowModel {
  final String noProduct;
  final String effectiveDate;
  final String createdDate;
  final String customerName;
  final String price;
  final String discount;
  final String deliveryOrderFee;
  final String tax;
  final String total;
  final String sts;

  FirstRowModel({
    required this.noProduct,
    required this.effectiveDate,
    required this.createdDate,
    required this.customerName,
    required this.price,
    required this.discount,
    required this.deliveryOrderFee,
    required this.tax,
    required this.total,
    required this.sts,
  });
}

class TableModel {
  final String product;
  final String name;
  final String pack;
  final String order;
  final String foc;
  final String pricePerUnit;
  final String price;
  final String percentDiscount;
  final String discount;
  final String total;

  TableModel({
    required this.product,
    required this.name,
    required this.pack,
    required this.order,
    required this.foc,
    required this.pricePerUnit,
    required this.price,
    required this.percentDiscount,
    required this.discount,
    required this.total,
  });
}

class TransactionModel {
  final FirstRowModel firstRowData;
  final List<TableModel> tableData;

  TransactionModel({
    required this.firstRowData,
    required this.tableData,
  });
}

class BtrBillModel {
  final String page;
  final String smNumber;
  final String date;
  final String time;
  final String dateSelectedFrom;
  final String dateSelectedTo;
  final List<TransactionModel> transactionList;
  final FirstRowModel totalRow;

  BtrBillModel({
    required this.page,
    required this.smNumber,
    required this.date,
    required this.time,
    required this.dateSelectedFrom,
    required this.dateSelectedTo,
    required this.transactionList,
    required this.totalRow,
  });
}
