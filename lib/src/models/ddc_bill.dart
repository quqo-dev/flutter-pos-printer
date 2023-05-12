class CustomerPriceModel {
  final String no;
  final String date;
  final String customerId;
  final String customerName;
  final String price;
  final String diValue;
  final String doValue;
  final String netAmount;
  final String tax;
  final String total;
  final String st;
  final String l;

  CustomerPriceModel({
    required this.no,
    required this.date,
    required this.customerId,
    required this.customerName,
    required this.price,
    required this.diValue,
    required this.doValue,
    required this.netAmount,
    required this.tax,
    required this.total,
    required this.st,
    required this.l,
  });
}

class BillStatusModel {
  final String name;
  final String quantity;
  final String price;
  final String diValue;
  final String doValue;
  final String netAmount;
  final String tax;
  final String total;
  final String st;
  final String l;

  BillStatusModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.diValue,
    required this.doValue,
    required this.netAmount,
    required this.tax,
    required this.total,
    required this.st,
    required this.l,
  });
}

class PaymentTypeModel {
  final String name;
  final String batchNo;
  final String price;
  final String diValue;
  final String doValue;
  final String netAmount;
  final String tax;
  final String total;
  final String l;

  PaymentTypeModel({
    required this.name,
    required this.batchNo,
    required this.price,
    required this.diValue,
    required this.doValue,
    required this.netAmount,
    required this.tax,
    required this.total,
    required this.l,
  });
}

class VisitCustomerModel {
  final String name;
  final String soldAmount;
  final String soldPercent;
  final String orderAmount;
  final String orderPercent;
  final String notSoldAmount;
  final String notSoldPercent;
  final String total;

  VisitCustomerModel({
    required this.name,
    required this.soldAmount,
    required this.soldPercent,
    required this.orderAmount,
    required this.orderPercent,
    required this.notSoldAmount,
    required this.notSoldPercent,
    required this.total,
  });
}

class SummaryModel {
  final String firstName;
  final String secondName;
  final String quantity;
  final String price;
  final String total;

  SummaryModel({
    required this.firstName,
    required this.secondName,
    required this.quantity,
    required this.price,
    required this.total,
  });
}

class DdcBillModel {
  final String page;
  final String smNumber;
  final String date;
  final String time;
  final String dateCreatedFrom;
  final String dateCreatedTo;
  final String status;
  final List<CustomerPriceModel> customerPriceList;
  final List<BillStatusModel> billStatusList;
  final List<PaymentTypeModel> paymentTypeList;
  final List<VisitCustomerModel> visitCustomerList;
  final String adjCode;
  final String billCode;
  final String billDCode;
  final String intCode;
  final String trnCode;
  final List<SummaryModel> paymentByTransporterList;
  final List<SummaryModel> orderSummaryList;
  final String totalBalance;
  final String totalCashBalance;
  final String creditBalance;

  DdcBillModel({
    required this.page,
    required this.smNumber,
    required this.date,
    required this.time,
    required this.dateCreatedFrom,
    required this.dateCreatedTo,
    required this.status,
    required this.customerPriceList,
    required this.billStatusList,
    required this.paymentTypeList,
    required this.visitCustomerList,
    required this.adjCode,
    required this.billCode,
    required this.billDCode,
    required this.intCode,
    required this.trnCode,
    required this.paymentByTransporterList,
    required this.orderSummaryList,
    required this.totalBalance,
    required this.totalCashBalance,
    required this.creditBalance,
  });
}
