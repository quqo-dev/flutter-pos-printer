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

  @override
  String toString() =>
      "${no};${date};${customerId};${customerName};${price};${diValue};${doValue};${netAmount};${tax};${total};${st};${l};";
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

  factory BillStatusModel.empty() => BillStatusModel(
        name: "",
        quantity: "",
        price: "",
        diValue: "",
        doValue: "",
        netAmount: "",
        tax: "",
        total: "",
        st: "",
        l: "",
      );

  BillStatusModel copyWith({
    String? name,
    String? quantity,
    String? price,
    String? diValue,
    String? doValue,
    String? netAmount,
    String? tax,
    String? total,
    String? st,
    String? l,
  }) =>
      BillStatusModel(
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        diValue: diValue ?? this.diValue,
        doValue: doValue ?? this.doValue,
        netAmount: netAmount ?? this.netAmount,
        tax: tax ?? this.tax,
        total: total ?? this.total,
        st: st ?? this.st,
        l: l ?? this.l,
      );

  @override
  String toString() =>
      "${name};${quantity};${price};${diValue};${doValue};${netAmount};${tax};${total};${st};${l};";
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

  factory PaymentTypeModel.empty() => PaymentTypeModel(
        name: "",
        batchNo: "",
        price: "",
        diValue: "",
        doValue: "",
        netAmount: "",
        tax: "",
        total: "",
        l: "",
      );

  PaymentTypeModel copyWith({
    String? name,
    String? batchNo,
    String? price,
    String? diValue,
    String? doValue,
    String? netAmount,
    String? tax,
    String? total,
    String? l,
  }) =>
      PaymentTypeModel(
        name: name ?? this.name,
        batchNo: batchNo ?? this.batchNo,
        price: price ?? this.price,
        diValue: diValue ?? this.diValue,
        doValue: doValue ?? this.doValue,
        netAmount: netAmount ?? this.netAmount,
        tax: tax ?? this.tax,
        total: total ?? this.total,
        l: l ?? this.l,
      );

  @override
  String toString() =>
      "${name};${batchNo};${price};${diValue};${doValue};${netAmount};${tax};${total};${l};";
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

  factory VisitCustomerModel.empty() => VisitCustomerModel(
        name: "",
        soldAmount: "",
        soldPercent: "",
        orderAmount: "",
        orderPercent: "",
        notSoldAmount: "",
        notSoldPercent: "",
        total: "",
      );

  VisitCustomerModel copyWith({
    String? name,
    String? soldAmount,
    String? soldPercent,
    String? orderAmount,
    String? orderPercent,
    String? notSoldAmount,
    String? notSoldPercent,
    String? total,
  }) =>
      VisitCustomerModel(
        name: name ?? this.name,
        soldAmount: soldAmount ?? this.soldAmount,
        soldPercent: soldPercent ?? this.soldPercent,
        orderAmount: orderAmount ?? this.orderAmount,
        orderPercent: orderPercent ?? this.orderPercent,
        notSoldAmount: notSoldAmount ?? this.notSoldAmount,
        notSoldPercent: notSoldPercent ?? this.notSoldPercent,
        total: total ?? this.total,
      );

  @override
  String toString() =>
      "${name};${soldAmount};${soldPercent};${orderAmount};${orderPercent};${notSoldAmount};${notSoldPercent};${total};";
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

  factory SummaryModel.empty() => SummaryModel(
        firstName: "",
        secondName: "",
        quantity: "",
        price: "",
        total: "",
      );

  SummaryModel copyWith({
    String? firstName,
    String? secondName,
    String? quantity,
    String? price,
    String? total,
  }) =>
      SummaryModel(
        firstName: firstName ?? this.firstName,
        secondName: secondName ?? this.secondName,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        total: total ?? this.total,
      );

  @override
  String toString() =>
      "${firstName};${secondName};${quantity};${price};${total};";
}

class DdcReportModel {
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
  final String cashBalance;
  final String creditBalance;
  final String qrBalance;

  DdcReportModel({
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
    required this.cashBalance,
    required this.creditBalance,
    required this.qrBalance,
  });

  @override
  String toString() =>
      "${page}; ${smNumber}; ${date}; ${time}; ${dateCreatedFrom}; ${dateCreatedTo}; ${status}; ${customerPriceList}; ${billStatusList}; ${paymentTypeList}; ${visitCustomerList}; ${adjCode}; ${billCode}; ${billDCode}; ${intCode}; ${trnCode}; ${paymentByTransporterList}; ${orderSummaryList}; ${totalBalance}; ${cashBalance}; ${creditBalance};";
}
