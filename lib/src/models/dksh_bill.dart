class DkshProductModel {
  final String productCode;
  final String productList;
  final String soldAmount;
  final String freeAmount;
  final String amountBeforeVAT;
  final String discountBeforeVAT;
  final String amountAfterVAT;
  final String pricePerCanAfterVAT;

  DkshProductModel({
    required this.productCode,
    required this.productList,
    required this.soldAmount,
    required this.freeAmount,
    required this.amountBeforeVAT,
    required this.discountBeforeVAT,
    required this.amountAfterVAT,
    required this.pricePerCanAfterVAT,
  });
}

class DkshBillModel {
  final String page;
  final String time;
  final String issuedBranch;
  final String contactInfo;
  final String storeName;
  final String address;
  final String taxPayerIdNumber;
  final String orderNumber;
  final String section;
  final String no;
  final String date;
  final String customerId;
  final String salespersonCode;
  final String billingCode;
  final List<DkshProductModel> productList;
  final String totalMoneyByLetters;
  final String netSalesAfterVAT;
  final String netSalesBeforeVAT;
  final String percentVAT;
  final String percentSpecialDiscount;
  final String amountVAT;
  final String amountSpecialDiscount;
  final String deliveryAt;
  final String deliveryAddress;

  DkshBillModel({
    required this.page,
    required this.time,
    required this.issuedBranch,
    required this.contactInfo,
    required this.storeName,
    required this.address,
    required this.taxPayerIdNumber,
    required this.orderNumber,
    required this.section,
    required this.no,
    required this.date,
    required this.customerId,
    required this.salespersonCode,
    required this.billingCode,
    required this.productList,
    required this.totalMoneyByLetters,
    required this.netSalesAfterVAT,
    required this.netSalesBeforeVAT,
    required this.percentVAT,
    required this.percentSpecialDiscount,
    required this.amountVAT,
    required this.amountSpecialDiscount,
    required this.deliveryAt,
    required this.deliveryAddress,
  });
}
