import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

final sampleDkshBillModel = DkshBillModel(
  page: '1',
  time: '08:51:23',
  issuedBranch: '00122',
  contactInfo: 'สำนักงานใหญ่ 091-890-3153',
  storeName: 'นามวัฒน์อะไหล่',
  address: '\'156-157  ม.2 ต.กังแอน อ.ปราสาท',
  addressTwo: 'จ.กำแพงเพชร',
  taxPayerIdNumber: '1650200025093 / sample text',
  orderNumber: 'B0',
  section: '27',
  no: 'S32467',
  date: '07/02/2023',
  customerId: 'A700743',
  salespersonCode: '10351241',
  billingCode: '10351241',
  productList: <DkshProductModel>[
    DkshProductModel(
      productCode: '100845598',
      productList: 'เฮลิกส์ ULTRA 0W-40 12X1L_SK',
      soldAmount: '1/0',
      freeAmount: '0/0',
      amountBeforeVAT: '1,380.00',
      discountBeforeVAT: '441.60',
      amountAfterVAT: '1,004.09',
      pricePerCanAfterVAT: '83.67',
    ),
    DkshProductModel(
      productCode: '100845598',
      productList: 'ริมูล่าR1 40 CC/SC_REV 4X4L',
      soldAmount: '1/0',
      freeAmount: '0/0',
      amountBeforeVAT: '1,380.00',
      discountBeforeVAT: '441.60',
      amountAfterVAT: '1,004.09',
      pricePerCanAfterVAT: '83.67',
    ),
    DkshProductModel(
      productCode: '100845598',
      productList: 'คูแลนท์LL พลัส พร้อมใช้ 4X4L',
      soldAmount: '1/0',
      freeAmount: '0/0',
      amountBeforeVAT: '1,380.00',
      discountBeforeVAT: '441.60',
      amountAfterVAT: '1,004.09',
      pricePerCanAfterVAT: '83.67',
    ),
    DkshProductModel(
      productCode: '100845598',
      productList: 'ของแถม เสื้อโปโล ADV 4T',
      soldAmount: '1/0',
      freeAmount: '0/0',
      amountBeforeVAT: '1,380.00',
      discountBeforeVAT: '441.60',
      amountAfterVAT: '1,004.09',
      pricePerCanAfterVAT: '83.67',
    ),
  ],
  totalMoneyByLetters: 'สี่พันหนึ่งร้อยแปด​สิบห้าบาทแปด​สิบสี่สตางค์',
  netSalesAfterVAT: '2,008.18',
  netSalesBeforeVAT: '1,876.80',
  percentVAT: '7.00',
  percentSpecialDiscount: '0.00',
  amountVAT: '131.38',
  amountSpecialDiscount: '0.00',
  deliveryAt: 'This is a sample text',
  deliveryAddress: 'This is a sample text also',
);

final sampleDdcBillModel = DdcReportModel(
  page: '1',
  smNumber: 'S/M 10351241',
  date: '08/02/2023',
  time: '08:48:05',
  dateCreatedFrom: '07/02/2023',
  dateCreatedTo: '07/02/2023',
  status: 'ALL',
  customerPriceList: <CustomerPriceModel>[
    CustomerPriceModel(
      no: 'S32467-27',
      date: '07/02/2023',
      customerId: 'A700743',
      customerName: 'บริษัท ชัยเจริญ 1992 จำกัด',
      price: '36,147.00',
      diValue: '11,477.70',
      doValue: '0.00',
      netAmount: '1,024,669.30',
      tax: '1,726.85',
      total: '26,396.15',
      st: 'C',
      l: '192',
      productQuantity: '10',
    ),
    CustomerPriceModel(
      no: 'S32467-27',
      date: '07/02/2023',
      customerId: 'A244437',
      customerName: 'บริษัท ชัยเจริญเทรดดิ้ง 1992 จำกัด',
      price: '998,136.00',
      diValue: '18,406.08',
      doValue: '0.00',
      netAmount: '979,729.92',
      tax: '68,681.09',
      total: '1,048,311.01',
      st: 'C',
      l: '121',
      productQuantity: '21',
    ),
  ],
  billStatusList: <BillStatusModel>[
    BillStatusModel(
      name: 'B',
      quantity: '0',
      price: '0.00',
      diValue: '0.00',
      doValue: '0.00',
      netAmount: '0.00',
      tax: '0.00',
      total: '0.00',
      st: '0.00',
      l: '0',
    ),
    BillStatusModel(
      name: 'C',
      quantity: '7',
      price: '1,014,719.30',
      diValue: '20,511.56',
      doValue: '0.00',
      netAmount: '994,207.74',
      tax: '69,594.54',
      total: '1,063,802.28',
      st: '165',
      l: '',
    ),
    BillStatusModel(
      name: 'X',
      quantity: '0',
      price: '0.00',
      diValue: '0.00',
      doValue: '0.00',
      netAmount: '0.00',
      tax: '0.00',
      total: '0.00',
      st: '0.00',
      l: '0',
    ),
    BillStatusModel(
      name: 'Z',
      quantity: '0',
      price: '0.00',
      diValue: '0.00',
      doValue: '0.00',
      netAmount: '0.00',
      tax: '0.00',
      total: '0.00',
      st: '0.00',
      l: '0',
    ),
    BillStatusModel(
      name: 'ALL',
      quantity: '7',
      price: '28,448.64',
      diValue: '4,115.84',
      doValue: '0.00',
      netAmount: '24,332.80',
      tax: '1,703.30',
      total: '26,036.10',
      st: '165',
      l: '',
    ),
  ],
  paymentTypeList: <PaymentTypeModel>[
    PaymentTypeModel(
      name: 'CASH 7 BILL',
      batchNo: '8A84C3207',
      price: '28,448.64',
      diValue: '4,115.84',
      doValue: '0.00',
      netAmount: '24,332.80',
      tax: '1,703.30',
      total: '26,036.10',
      l: '165',
    ),
    PaymentTypeModel(
      name: 'CREDIT 0 BILL',
      batchNo: '8A64D',
      price: '0.00',
      diValue: '0.00',
      doValue: '0.00',
      netAmount: '0.00',
      tax: '0.00',
      total: '0.00',
      l: '0',
    ),
    PaymentTypeModel(
      name: '',
      batchNo: '',
      price: '1,028,448.64',
      diValue: '14,115.84',
      doValue: '0.00',
      netAmount: '1,924,332.80',
      tax: '61,703.30',
      total: '1,026,036.10',
      l: '165',
    ),
  ],
  visitCustomerList: <VisitCustomerModel>[
    VisitCustomerModel(
      name: 'VISIT CUSTOMER MTD',
      soldAmount: '25',
      soldPercent: '20.49',
      orderAmount: '9',
      orderPercent: '7.38',
      notSoldAmount: '88',
      notSoldPercent: '72.13',
      total: '372',
    ),
    VisitCustomerModel(
      name: 'VISIT CUSTOMER',
      soldAmount: '7',
      soldPercent: '36.84',
      orderAmount: '0',
      orderPercent: '0.00',
      notSoldAmount: '12',
      notSoldPercent: '63.16',
      total: '372',
    ),
  ],
  adjCode: 'A520001',
  billCode: 'S32474',
  billDCode: 'SD3239',
  intCode: 'T520001',
  trnCode: 'M520001',
  paymentByTransporterList: <SummaryModel>[
    SummaryModel(
      firstName: 'L',
      secondName: 'SM',
      quantity: '7',
      price: '26,036.10',
      total: '165',
    ),
    SummaryModel(
      firstName: '',
      secondName: 'Total',
      quantity: '',
      price: '26,036.10',
      total: '165',
    ),
  ],
  orderSummaryList: <SummaryModel>[
    SummaryModel(
      firstName: '',
      secondName: 'Total',
      quantity: '',
      price: '0.00',
      total: '0.00',
    ),
  ],
  totalBalance: '26,036.10',
  cashBalance: '26,036.10',
  creditBalance: '0.00',
  qrBalance: '0.00',
);

final sampleDssrBillModel = DssrReportModel(
  page: '1',
  smNumber: 'S/M 10351241',
  date: '08/02/02023',
  time: '08:34:37',
  selectedDate: '08/02/2023',
  stockList: <StockModel>[
    StockModel(
      id: '100845611',
      name: 'คูแลนท์LL พลัส พร้อมใช้ 4X4L',
      wh: '8A64',
      perPack: '12',
      openBal: '1324/133',
      sale: '456/61',
      goodsReturn: '5451/103',
      transfIn: '8451/473',
      transfOut: '5451/103',
      focX: '0/0',
      focY: '0/0',
      closeBal: '1243/537',
      onhand: '1243/537',
    ),
    StockModel(
      id: '100845611',
      name: 'คูแลนท์LL พลัส พร้อมใช้ 4X4L',
      wh: '8A64',
      perPack: '24',
      openBal: '2/3',
      sale: '0/0',
      goodsReturn: '0/0',
      transfIn: '0/0',
      transfOut: '0/0',
      focX: '0/0',
      focY: '0/0',
      closeBal: '12/0',
      onhand: '0/8',
    )
  ],
  total: '65',
);

final sampleCclrBillModel = CclrReportModel(
  page: '1',
  smNumber: 'S/M 10351241',
  date: '08/02/02023',
  time: '08:34:37',
  dateSelectedFrom: '07/02/2023',
  dateSelectedTo: '07/02/2023',
  callingList: <CallingModel>[
    CallingModel(
      date: '07/02/2023',
      custCode: 'CA244687',
      custName: 'นามวัฒน์อะไหล่',
      reason: '8 ตดิ ตอ่ ไมไ่ ด ้',
      typeOfShop: 'C6 Branded IWS Car6',
      time: '11:36:11',
    ),
    CallingModel(
      date: '07/02/2023',
      custCode: 'CA244687',
      custName: 'ห้างหุ้นส่วนจำกัด มงคลเจริญ (มี) น๊อต 2020',
      reason: '8 รอตัดสนิ ใจ / รอเช็ค Stock',
      typeOfShop: 'C6 Branded IWS Car6',
      time: '11:36:11',
    ),
  ],
  total: '12',
  grandTotal: '54',
);

final sampleBtrBillModel = BtrReportModel(
  page: '1',
  smNumber: 'S/M 10351241',
  date: '08/02/02023',
  time: '08:34:37',
  dateSelectedFrom: '07/02/2023',
  dateSelectedTo: '07/02/2023',
  transactionList: List<TransactionModel>.generate(
    1,
    (index) => TransactionModel(
      firstRowData: FirstRowModel(
        noProduct: 'QD042001 - 1',
        effectiveDate: '07/02/2023',
        createdDate: '07/02/2023',
        customerName: 'คุณพรรัตน์  ประภานวรัตน์',
        price: '2,760.00',
        discount: '883.20',
        deliveryOrderFee: '0.00',
        tax: '131.38',
        total: '2,008.18',
        sts: 'C',
      ),
      tableData: <TableModel>[
        TableModel(
          product: '100845598',
          name: 'ของแถมHX ULTA_ล็อค&ล็อค',
          pack: '12',
          order: '1/0',
          foc: '0/0',
          pricePerUnit: '1,380.00',
          price: '1,380.00',
          percentDiscount: '32.00',
          discount: '441.60',
          total: '1,004.09',
        ),
        TableModel(
          product: '100974445',
          name: 'แอดวานซ์4TAX7 10W40MA2 12X0.8L',
          pack: '12',
          order: '13/5',
          foc: '0/0',
          pricePerUnit: '1,380.00',
          price: '1,380.00',
          percentDiscount: '32.00',
          discount: '441.60',
          total: '1,004.09',
        ),
      ],
    ),
  ),
  totalRow: FirstRowModel(
    noProduct: 'TOTAL ==>',
    effectiveDate: '',
    createdDate: '',
    customerName: '',
    price: '28,448.64',
    discount: '4,115.84',
    deliveryOrderFee: '0.00',
    tax: '1,703.30',
    total: '26,036.10',
    sts: '',
  ),
  isPreOrder: false,
);

final sampleBtlBillModel = BtlReportModel(
  page: '1',
  smNumber: 'S/M 10351241',
  date: '08/02/02023',
  time: '08:34:37',
  dateSelectedFrom: '07/02/2023',
  dateSelectedTo: '07/02/2023',
  reportNo: "M520001",
  transferList: List<TransferItem>.generate(
    2,
    (_) => TransferItem(
      transferNo: '4902577551',
      locFrom: '8A66',
      locTo: '8A64',
      productCode: '100540060',
      description: 'ริมูล่าR2 EXTRA 20W50_REV 2X6L',
      unitCode: 'TIN',
      perPack: '14',
      quantity: '2/12',
      unitPrice: '1,698.00',
      amount: '3,396.00',
      status: 'C',
    ),
  ),
  totalRecord: '8',
  totalAmount: '55,656.29',
);

final sampleOsrBillModel = OsrReportModel(
  page: '1',
  smNumber: 'S/M 10351241',
  date: '08/02/02023',
  time: '08:34:37',
  dateSelectedFrom: '07/02/2023',
  dateSelectedTo: '07/02/2023',
  orderList: <OrderSummanyItem>[
    OrderSummanyItem(
      partNo: '100844799',
      description: 'ADVANCE 4T ULTRA10W40 12X1L',
      unit: 'TIN',
      perPack: '12',
      price: '4,010.82',
      sum: '',
      quantity: '12/3',
      foc: '0/0',
      discount: '895.62',
      tax: '209.88',
      amount: '3,208.26',
      lite: '12',
    ),
    OrderSummanyItem(
      partNo: '100844799',
      description: 'ADVANCE 4T ULTRA10W40 12X1L 123456789',
      unit: 'TIN',
      perPack: '12',
      price: '24,010.82',
      sum: '',
      quantity: '12/3',
      foc: '0/0',
      discount: '895.62',
      tax: '1,209.88',
      amount: '343,208.26',
      lite: '120',
    ),
  ],
  totalAmount: '100,432.44',
  totalLit: '866.00',
  referenceList: '\'S4745166\',\'S4745266\'',
);

final sampleCsrBillModel = CsrReportModel(
  page: '1',
  smNumber: 'S/M 10351241',
  date: '08/02/02023',
  time: '08:34:37',
  stockList: List<StockItem>.generate(
    1,
    (index) => StockItem(
      productCode: '100844799',
      description: 'ADVANCE 4T ULTRA10W40 12X1L',
      perPack: (index + 1).toString(),
      unitCode: 'TIN',
      onHandGood: '122/33',
      onCarGood: '32/13',
      location: '8A46',
    ),
  ),
  totalRecord: '56',
);

final sampleRrsrReportModel = RrsrReportModel(
  smNumber: 'S/M 10351241',
  date: '08/02/02023',
  time: '08:34:37',
  subtitle: 'รอง',
  ref: 'RA4631GD',
  fromWh: '8A46',
  toWh: 'DEPOT',
  rrList: <RrListItem>[
    RrListItem(
      title: '02  Advance',
      productList: <RrProductItem>[
        RrProductItem(
          productCode: '100844799',
          description: 'ADVANCE 4T ULTRA10W40 12X1L',
          perPack: '12',
          unitCode: 'TIN',
          quantity: '0/3',
        ),
        RrProductItem(
          productCode: '100844711',
          description: 'ADVANCE 4T ULTRA10W40 12X1L.8L',
          perPack: '12',
          unitCode: 'TIN',
          quantity: '3/6',
        ),
        RrProductItem(
          productCode: '100844711',
          description: 'ADVANCE 4T ULTRA10W40 12X1L',
          perPack: '12',
          unitCode: 'TIN',
          quantity: '1/2',
        ),
      ],
    ),
  ],
);
