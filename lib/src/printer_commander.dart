import 'dart:io';

import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/enums.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/generator.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_column.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

/*
  BILL TYPE DESCRIPTION:
    "Dksh": DKSH
    "Ddc" : BILL REGISTER REPORT
    "Dssr": DAILY STOCK SUMMARY REPORT
    "Cclr": CUSTOMER CALLING LISTING REPORT
    "Btr": BILL TRANSACTION REPORT
    "Btl": BILL TRANSFER LISTING
    "Osr": ORDER SUMMARY REPORT
    "Csr": CHECKING STOCK REPORT
    "Rrsr": RETURN & RECEIPT STOCK REPORT
 */
enum BillType { Dksh, Ddc, Dssr, Cclr, Btr, Btl, Osr, Csr, Rrsr }

const int MAX_ROW_PER_PAGE = 64;
const int GAP_END_PAGE = 3;

const int MAX_ADDRESS_CHAR_PER_ROW = 40;
const int MAX_BILLING_PRODUCT_PER_PAGE = 7;
const int MAX_CCLR_ROW_PER_PAGE = 50;
const int MAX_DSSR_ROW_PER_PAGE = 50;
const int MAX_BTL_ROW_PER_PAGE = 50;
const int MAX_OSR_ROW_PER_PAGE = 48;
const int MAX_CSR_ROW_PER_PAGE = 60;
const int MAX_RRSR_ROW_PER_PAGE = 50;

const int DSSR_HEADER_ROW = 7;
const int BTR_HEADER_ROW = 7;
const int DDC_HEADER_ROW = 6;
const int CCLR_HEADER_ROW = 6;
const int BTL_HEADER_ROW = 6;
const int OSR_HEADER_ROW = 6;
const int CSR_HEADER_ROW = 6;
const int RRSR_HEADER_ROW = 6;

class PrinterCommander {
  static final printerManager = PrinterManager.instance;

  static void printBill({
    required BillType billType,
    required dynamic data,
    required BluetoothPrinter bluetoothPrinter,
  }) async {
    List<int> bytes = [];

    // Config default printer
    final profile = await CapabilityProfile.load(name: 'default');
    final Generator generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 500,
      isSmallFont: true,
    );

    switch (billType) {
      case BillType.Dksh:
        if (data is! DkshBillModel) {
          throw FormatException('Error! Type must be DkshBillModel');
        }

        generator.setGlobalFont(
          PosFontType.fontA,
          maxCharsPerLine: 500,
          isSmallFont: false,
        );

        final int pages =
            data.productList.length ~/ MAX_BILLING_PRODUCT_PER_PAGE +
                (data.productList.length % MAX_BILLING_PRODUCT_PER_PAGE != 0
                    ? 1
                    : 0);

        bytes = await _getDkshBillingContent(pages, generator, data);
        break;
      case BillType.Ddc:
        if (data is! DdcReportModel) {
          throw FormatException('Error! Type must be DdcBillModel');
        }

        bytes = await _getDdcReportContent(generator, data);
        break;
      case BillType.Dssr:
        if (data is! DssrReportModel) {
          throw FormatException('Error! Type must be DssrBillModel');
        }

        bytes = await _getDssrReportContent(generator, data);
        break;
      case BillType.Cclr:
        if (data is! CclrReportModel) {
          throw FormatException('Error! Type must be CclrBillModel');
        }

        bytes = await _getCclrReportContent(generator, data);
        break;
      case BillType.Btr:
        if (data is! BtrReportModel) {
          throw FormatException('Error! Type must be BtrBillModel');
        }

        bytes = await _getBtrReportContent(generator, data);
        break;
      case BillType.Btl:
        if (data is! BtlReportModel) {
          throw FormatException('Error! Type must be BtlBillModel');
        }

        bytes = await _getBtlReportContent(generator, data);
        break;
      case BillType.Osr:
        if (data is! OsrReportModel) {
          throw FormatException('Error! Type must be OsrBillModel');
        }

        bytes = await _getOsrReportContent(generator, data);
        break;
      case BillType.Csr:
        if (data is! CsrReportModel) {
          throw FormatException('Error! Type must be CsrBillModel');
        }

        bytes = await _getCsrReportContent(generator, data);
        break;
      case BillType.Rrsr:
        if (data is! RrsrReportModel) {
          throw FormatException('Error! Type must be RrsrReportModel');
        }

        bytes = await _getRrsrReportContent(generator, data);

        break;
      default:
        throw UnimplementedError();
    }

    _printEscPos(bytes, generator, bluetoothPrinter);
  }

  static Future<List<int>> _getDkshBillingContent(
    int totalPages,
    Generator generator,
    DkshBillModel data,
  ) async {
    List<int> bytes = [];

    for (int outerIdx = 0; outerIdx < totalPages; outerIdx++) {
      bytes += generator.emptyLines(1);

      bytes += generator.row([
        PosColumn(width: 3),
        PosColumn(
          width: 9,
          text: getTabs(1) +
              data.issuedBranch +
              getTabs(4) +
              'Page ${outerIdx + 1}  Time ${data.time}',
        ),
      ]);

      bytes += generator
          .textEncoded(await getThaiEncoded(getTabs(6) + data.contactInfo));

      bytes += generator.emptyLines(1);

      bytes += generator.row([
        PosColumn(width: 1),
        PosColumn(
          width: 5,
          textEncoded: await getThaiEncoded(data.storeName),
        ),
        PosColumn(width: 2),
        PosColumn(width: 2),
        PosColumn(
          width: 2,
          text: data.no,
        ),
      ]);

      bytes += generator.row([
        PosColumn(width: 1),
        PosColumn(
          width: 5,
          textEncoded: await getThaiEncoded(data.address),
        ),
        PosColumn(
          width: 2,
          text: data.orderNumber,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          width: 2,
          text: getTabs(2) + data.section,
        ),
        PosColumn(
          width: 2,
          text: data.date,
        ),
      ]);

      // address 2
      // if (data.address.length > MAX_ADDRESS_CHAR_PER_ROW) {
      bytes += generator.row([
        PosColumn(width: 1),
        PosColumn(
          width: 11,
          textEncoded: await getThaiEncoded(data.addressTwo),
        ),
      ]);
      // } else {
      //   bytes += generator.emptyLines(1);
      // }

      bytes += generator.row([
        PosColumn(width: 2),
        PosColumn(
          width: 4,
          textEncoded: await getThaiEncoded(data.taxPayerIdNumber),
        ),
        PosColumn(
          width: 2,
          text: data.customerId,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          width: 2,
          text: getTabs(2) + data.salespersonCode,
        ),
        PosColumn(
          width: 2,
          text: data.billingCode,
        ),
      ]);

      bytes += generator.emptyLines(3);

      int currentListItem = 0;

      for (int listIdx = 0; listIdx < MAX_BILLING_PRODUCT_PER_PAGE; listIdx++) {
        final int currentListIdx =
            outerIdx * MAX_BILLING_PRODUCT_PER_PAGE + listIdx;

        if (currentListIdx >= data.productList.length) break;

        currentListItem++;
        final DkshProductModel item = data.productList[currentListIdx];

        bytes += generator.textEncoded(
          await getThaiEncoded(
            ' ${fillSpaceText(item.productCode, 9)} ${fillSpaceText(item.productList, 28)} ' +
                '${getRightAlignedText(item.soldAmount, 5)} ${getRightAlignedText(item.freeAmount, 5)} ' +
                '${fillSpaceText(getRightAlignedText(item.amountBeforeVAT, 12), 12)} ${fillSpaceText(getRightAlignedText(item.discountBeforeVAT, 9), 9)}' +
                '${fillSpaceText(getRightAlignedText(item.amountAfterVAT, 12), 12)}${fillSpaceText(getRightAlignedText(item.pricePerCanAfterVAT, 9), 9)}',
          ),
        );
      }

      // The rest empty lines of table
      bytes += generator.emptyLines(
        MAX_BILLING_PRODUCT_PER_PAGE - currentListItem,
      );

      // Spacing for the next row
      bytes += generator.emptyLines(3);

      bytes += generator.textEncoded(
        await getThaiEncoded(
            "${getTabs(37)} ${getRightAlignedText(data.netSalesAfterVAT, 11)}"),
      );

      bytes += generator.emptyLines(1);

      bytes += generator.textEncoded(
        await getThaiEncoded(
            "${getTabs(1)}${fillSpaceText(data.totalMoneyByLetters, 73)}${getRightAlignedText(data.netSalesBeforeVAT, 11)}"),
      );

      bytes += generator.emptyLines(1);

      bytes += generator.textEncoded(
        await getThaiEncoded(
          "${getTabs(31)}${fillSpaceText(data.percentVAT, 4)}${getTabs(4)} ${getRightAlignedText(data.amountVAT, 11)}",
        ),
      );

      bytes += generator.emptyLines(1);

      // bytes += generator.row([
      //   PosColumn(width: 6),
      //   PosColumn(
      //     width: 1,
      //     text: getTabs(6) + data.percentSpecialDiscount,
      //   ),
      //   PosColumn(
      //     width: 1,
      //     text:
      //         getTabs(6) + getRightAlignedText(data.amountSpecialDiscount, 11),
      //     styles: const PosStyles(align: PosAlign.right),
      //   ),
      //   PosColumn(width: 4)
      // ]);

      bytes += generator.emptyLines(4);

      bytes += generator
          .textEncoded(await getThaiEncoded(getTabs(4) + data.deliveryAt));
      bytes += generator
          .textEncoded(await getThaiEncoded(getTabs(4) + data.deliveryAddress));

      if (outerIdx < totalPages - 1) {
        bytes += generator.emptyLines(3);
      }
    }

    return bytes;
  }

  static Future<List<int>> _getDdcReportContent(
    Generator generator,
    DdcReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    void _checkEndPage() {
      if (currentRow >= MAX_ROW_PER_PAGE - GAP_END_PAGE) {
        currentPage++;
        bytes += generator.emptyLines(4);
        currentRow = 0;
        bytes += _getDdcHeader(generator, currentPage, data);
        currentRow += DDC_HEADER_ROW;
      }
    }

    // Header section
    bytes += _getDdcHeader(generator, currentPage, data);
    currentRow += DDC_HEADER_ROW;

    // 1st table
    for (final customerPrice in data.customerPriceList) {
      bytes += generator.textEncoded(
        await getThaiEncoded(
          '${fillSpaceText(customerPrice.no.replaceAll(' ', ''), 12)} ' +
              '${fillSpaceText(customerPrice.date, 10)} ' +
              '${fillSpaceText(customerPrice.customerId, 7)} ' +
              '${fillSpaceText(customerPrice.customerName, 17)}' +
              '${fillSpaceText(getRightAlignedText(customerPrice.price, 12), 12)} ' +
              '${fillSpaceText(getRightAlignedText(customerPrice.diValue, 9), 9)} ' +
              '${fillSpaceText(getRightAlignedText(customerPrice.doValue, 5), 5)} ' +
              '${fillSpaceText(getRightAlignedText(customerPrice.netAmount, 12), 12)} ' +
              '${fillSpaceText(getRightAlignedText(customerPrice.tax, 9), 9)} ' +
              '${fillSpaceText(getRightAlignedText(customerPrice.total, 12), 12)} ' +
              '${customerPrice.st}${fillSpaceText(getRightAlignedText(customerPrice.l, 3), 3)}' +
              '${fillSpaceText(getRightAlignedText(customerPrice.productQuantity, 2), 2)}',
        ),
      );

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);
    currentRow++;
    _checkEndPage();

    // 2nd table
    for (final bill in data.billStatusList) {
      bytes += generator.row([
        PosColumn(width: 1, text: 'STATUS ${bill.name}'),
        PosColumn(width: 1, text: '   ${bill.quantity} BILL'),
        PosColumn(width: 1, text: '    TOTAL==>'),
        PosColumn(width: 1),
        PosColumn(
            width: 1,
            text: getTabs(3) + ' ' + getRightAlignedText(bill.price, 12)),
        PosColumn(
            width: 1, text: getTabs(5) + getRightAlignedText(bill.diValue, 9)),
        PosColumn(
            width: 1,
            text: getTabs(3) + ' ' + getRightAlignedText(bill.doValue, 8)),
        PosColumn(
            width: 1,
            text: getTabs(2) + ' ' + getRightAlignedText(bill.netAmount, 12)),
        PosColumn(
            width: 1, text: getTabs(4) + getRightAlignedText(bill.tax, 9)),
        PosColumn(
            width: 1,
            text: getTabs(3) + ' ' + getRightAlignedText(bill.total, 12)),
        PosColumn(width: 1),
        PosColumn(width: 1, text: ' ' + getRightAlignedText(bill.quantity, 2)),
      ]);

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);
    currentRow++;
    _checkEndPage();

    // 3rd table
    for (final payment in data.paymentTypeList) {
      bytes += generator.row([
        PosColumn(width: 1, text: payment.name),
        PosColumn(width: 1),
        PosColumn(width: 1, text: '    TOTAL==>BATCH NO.:${payment.batchNo}'),
        PosColumn(width: 1),
        PosColumn(
            width: 1,
            text: getTabs(3) + ' ' + getRightAlignedText(payment.price, 12)),
        PosColumn(
            width: 1,
            text: getTabs(5) + getRightAlignedText(payment.diValue, 9)),
        PosColumn(
            width: 1,
            text: getTabs(3) + ' ' + getRightAlignedText(payment.doValue, 8)),
        PosColumn(
            width: 1,
            text:
                getTabs(2) + ' ' + getRightAlignedText(payment.netAmount, 12)),
        PosColumn(
            width: 1, text: getTabs(4) + getRightAlignedText(payment.tax, 9)),
        PosColumn(
            width: 1,
            text: getTabs(3) + ' ' + getRightAlignedText(payment.total, 12)),
        PosColumn(width: 1),
        PosColumn(width: 1, text: ' ' + getRightAlignedText(payment.l, 3)),
      ]);

      currentRow++;
      _checkEndPage();
    }

    for (final visitCustomer in data.visitCustomerList) {
      bytes += generator.row([
        PosColumn(width: 1, text: visitCustomer.name),
        PosColumn(width: 1),
        PosColumn(width: 1, text: '    TOTAL==>'),
        PosColumn(
          width: 8,
          text: getTabs(2) +
              getRightAlignedText(visitCustomer.soldAmount, 4) +
              getRightAlignedText('(${visitCustomer.soldPercent}%)', 9) +
              'SOLD  ' +
              getRightAlignedText(visitCustomer.orderAmount, 4) +
              getRightAlignedText('(${visitCustomer.orderPercent}%)', 9) +
              'ORDER  ' +
              getRightAlignedText(visitCustomer.notSoldAmount, 4) +
              getRightAlignedText('(${visitCustomer.notSoldPercent}%)', 9) +
              'NOT SOLD/ ' +
              visitCustomer.total,
        ),
        PosColumn(width: 1),
      ]);

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);
    currentRow++;
    _checkEndPage();

    // 4th table
    bytes += generator.text(
      'ADJ = ${data.adjCode}' +
          getTabs(2) +
          'BILL = ${data.billCode}' +
          getTabs(2) +
          'BILLD = ${data.billDCode}' +
          getTabs(2) +
          'INT = ${data.intCode}' +
          getTabs(2) +
          'TRN = ${data.trnCode}',
    );
    currentRow++;
    _checkEndPage();

    bytes += generator.text('*** Payment by Transporter(s) ***');
    currentRow++;
    _checkEndPage();

    for (final paymentByTransporter in data.paymentByTransporterList) {
      // last row
      if (paymentByTransporter.secondName == 'Total') {
        bytes += generator.hr(len: 120);
      }

      bytes += generator.row([
        PosColumn(width: 1, text: paymentByTransporter.firstName),
        PosColumn(width: 1, text: paymentByTransporter.secondName),
        PosColumn(width: 1),
        PosColumn(
            width: 1,
            text: paymentByTransporter.quantity.isEmpty
                ? ''
                : '(${paymentByTransporter.quantity})'),
        PosColumn(
            width: 1,
            text: getRightAlignedText(paymentByTransporter.price, 12)),
        PosColumn(
            width: 7, text: getTabs(4) + '(${paymentByTransporter.total})'),
      ]);

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.text('*** Order Summary(s) ***');
    currentRow++;
    _checkEndPage();

    for (final orderSummary in data.orderSummaryList) {
      // last row
      if (orderSummary.secondName == 'Total') {
        bytes += generator.hr(len: 120);
        currentRow++;
        _checkEndPage();
      }

      bytes += generator.row([
        PosColumn(width: 1, text: orderSummary.firstName),
        PosColumn(width: 1, text: orderSummary.secondName),
        PosColumn(width: 1),
        PosColumn(
            width: 1,
            text: orderSummary.quantity.isEmpty
                ? ''
                : '(${orderSummary.quantity})'),
        PosColumn(width: 1, text: getRightAlignedText(orderSummary.price, 12)),
        PosColumn(width: 7, text: getTabs(4) + '(${orderSummary.total})'),
      ]);
      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Total balance  ${data.totalBalance}  baht');
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Total cash balance  ${data.cashBalance}  baht' +
        getTabs(2) +
        'Cash payment........................................................baht');
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Total credit balance  ${data.creditBalance}  baht' +
        getTabs(2) +
        'Credit card payment slip amount........  Leaves value...............baht');
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Total QR balance  ${data.qrBalance}  baht' +
        getTabs(2) +
        'QR payment..........................................................baht');
    currentRow++;
    _checkEndPage();

    bytes += generator.text(
        'Pay by............................  Get paid by............................');
    currentRow++;
    _checkEndPage();

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static List<int> _getDdcHeader(
    Generator generator,
    int page,
    DdcReportModel data,
  ) {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page ${page}', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(19) + 'BILL REGISTER REPORT (DDC)',
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 10,
        text: getTabs(12) +
            'Date Created From ${data.dateCreatedFrom} To ${data.dateCreatedTo} | Status ALL',
      ),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    bytes += generator.row([
      PosColumn(width: 1, text: 'NO'),
      PosColumn(width: 1, text: '   DATE'),
      PosColumn(width: 1, text: '    CUST'),
      PosColumn(width: 1, text: '  NAME'),
      PosColumn(
          width: 1, text: getTabs(3) + ' ' + getRightAlignedText('PRICE', 12)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('D/I', 9)),
      PosColumn(
          width: 1, text: getTabs(3) + ' ' + getRightAlignedText('D/O', 8)),
      PosColumn(
          width: 1,
          text: getTabs(2) + ' ' + getRightAlignedText('NET_AMT', 12)),
      PosColumn(width: 1, text: getTabs(4) + getRightAlignedText('TAX', 9)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('TOT', 9)),
      PosColumn(width: 1, text: getTabs(4) + ' ' + 'ST'),
      PosColumn(width: 1, text: getTabs(1) + 'L'),
    ]);

    bytes += generator.hr(len: 120);

    return bytes;
  }

  static Future<List<int>> _getDssrReportContent(
    Generator generator,
    DssrReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    void _checkEndPage() {
      if (currentRow >= MAX_ROW_PER_PAGE - GAP_END_PAGE) {
        currentPage++;
        bytes += generator.hr(len: 120, ch: '=');
        bytes += generator.emptyLines(3);
        currentRow = 0;
        bytes += _getDssrHeader(generator, currentPage, data);
        currentRow += DSSR_HEADER_ROW;
      }
    }

    // Header section
    bytes += _getDssrHeader(generator, currentPage, data);
    currentRow += DSSR_HEADER_ROW;

    for (final stock in data.stockList) {
      bytes += generator.textEncoded(
        await getThaiEncoded(
          '${fillSpaceText(stock.id, 9)} ${fillSpaceText(stock.name, 30)} ' +
              '${getTabs(1)} ${stock.wh} ${getRightAlignedText(stock.perPack, 5)} ' +
              '${getRightAlignedText(stock.openBal, 8)} ' +
              '${getRightAlignedText(stock.sale, 8)} ' +
              '${getRightAlignedText(stock.goodsReturn, 8)} ' +
              '${getRightAlignedText(stock.transfIn, 8)} ' +
              '${getRightAlignedText(stock.transfOut, 8)} ' +
              '${getRightAlignedText(stock.closeBal, 8)} ' +
              '${getRightAlignedText(stock.onhand, 8)}',
        ),
      );

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120, ch: '=');
    currentRow++;
    _checkEndPage();

    bytes += generator.text('NO OF PRODUCT : ${data.stockList.length} LIST');
    currentRow++;
    _checkEndPage();

    bytes += generator.hr(len: 120, ch: '=');
    currentRow++;

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static List<int> _getDssrHeader(
    Generator generator,
    int page,
    DssrReportModel data,
  ) {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page $page', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(19) + 'DAILY STOCK SUMMARY REPORT',
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 10,
        text: getTabs(16) + 'Selected Date : ${data.selectedDate} All Products',
      ),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120, ch: '=');

    bytes += generator.row([
      PosColumn(width: 1, text: 'PRODUCT'),
      PosColumn(width: 2, text: 'NAME'),
      PosColumn(
        width: 9,
        text: getTabs(6) +
            getRightAlignedText('W/H', 5) +
            ' ' +
            getRightAlignedText('PER', 5) +
            getRightAlignedText('OPEN', 9) +
            getRightAlignedText('SALE', 9) +
            getRightAlignedText('GOODS', 9) +
            getRightAlignedText('TRANSF', 9) +
            getRightAlignedText('TRANSF', 9) +
            getRightAlignedText('CLOSE', 9) +
            getRightAlignedText('ONHAND', 9),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(width: 2),
      PosColumn(
        width: 9,
        text: getTabs(6) +
            getRightAlignedText('', 5) +
            ' ' +
            getRightAlignedText('PACK', 5) +
            getRightAlignedText('BAL', 9) +
            getRightAlignedText('', 9) +
            getRightAlignedText('RETURNS', 9) +
            getRightAlignedText('IN', 9) +
            getRightAlignedText('OUT', 9) +
            getRightAlignedText('BAL', 9),
      ),
    ]);

    bytes += generator.hr(len: 120, ch: '=');

    return bytes;
  }

  static Future<List<int>> _getCclrReportContent(
    Generator generator,
    CclrReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    void _checkEndPage() {
      if (currentRow >= MAX_ROW_PER_PAGE - GAP_END_PAGE) {
        currentPage++;
        bytes += generator.hr(len: 120, ch: '=');
        bytes += generator.emptyLines(3);
        currentRow = 0;
        bytes += _getCclrHeader(generator, currentPage, data);
        currentRow += CCLR_HEADER_ROW;
      }
    }

    // Header section
    bytes += _getCclrHeader(generator, currentPage, data);
    currentRow += CCLR_HEADER_ROW;

    for (final callingItem in data.callingList) {
      bytes += generator.textEncoded(
        await getThaiEncoded(
          '${callingItem.date}${getTabs(1)}${callingItem.custCode}' +
              '${getTabs(1)} ${fillSpaceText(callingItem.custName, 41)}' +
              '${fillSpaceText(callingItem.reason, 19)}' +
              '${getTabs(2)}${fillSpaceText(callingItem.typeOfShop, 24)}' +
              '${callingItem.time}',
        ),
      );

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120, ch: '=');
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Total ${data.total}');
    currentRow++;
    _checkEndPage();

    bytes += generator.hr(len: 120, ch: '=');
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Grand Total ${data.grandTotal}');
    currentRow++;

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static List<int> _getCclrHeader(
    Generator generator,
    int page,
    CclrReportModel data,
  ) {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page $page', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(19) + 'CUSTOMER CALLING LISTING REPORT',
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 10,
        text: getTabs(16) +
            'Date Selected From ${data.dateSelectedFrom} To ${data.dateSelectedTo}',
      ),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120, ch: '=');

    bytes += generator.row([
      PosColumn(width: 1, text: 'DATE'),
      PosColumn(width: 1, text: getTabs(1) + 'CUST.CODE'),
      PosColumn(width: 4, text: getTabs(1) + 'CUSTOMER NAME'),
      PosColumn(width: 2, text: getTabs(1) + 'REASON'),
      PosColumn(width: 2, text: getTabs(2) + 'TYPE OF SHOP'),
      PosColumn(width: 2, text: getTabs(3) + ' ' + 'TIME'),
    ]);

    bytes += generator.hr(len: 120, ch: '=');

    return bytes;
  }

  static Future<List<int>> _getBtrReportContent(
    Generator generator,
    BtrReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    void _checkEndPage() {
      if (currentRow >= MAX_ROW_PER_PAGE - GAP_END_PAGE) {
        currentPage++;
        bytes += generator.emptyLines(4);
        currentRow = 0;
        bytes += _getBtrHeader(generator, currentPage, data);
        currentRow += BTR_HEADER_ROW;
      }
    }

    // Header section
    bytes += _getBtrHeader(generator, currentPage, data);
    currentRow = BTR_HEADER_ROW;

    for (final transaction in data.transactionList) {
      bytes += generator.textEncoded(
        await getThaiEncoded(
          '${fillSpaceText(transaction.firstRowData.noProduct.replaceAll(' ', ''), 10)}${getTabs(1)}' +
              '${fillSpaceText(transaction.firstRowData.effectiveDate, 10)}${getTabs(1)}' +
              '${fillSpaceText(transaction.firstRowData.createdDate, 10)}${getTabs(1)} ' +
              '${fillSpaceText(transaction.firstRowData.customerName, 21)}' +
              '${fillSpaceText(getRightAlignedText(transaction.firstRowData.price, 12), 12)}${getTabs(1)}' +
              '${fillSpaceText(getRightAlignedText(transaction.firstRowData.discount, 9), 9)}${getTabs(1)}' +
              '${fillSpaceText(getRightAlignedText(transaction.firstRowData.deliveryOrderFee, 9), 9)}' +
              '${fillSpaceText(getRightAlignedText(transaction.firstRowData.tax, 9), 9)}' +
              '${fillSpaceText(getRightAlignedText(transaction.firstRowData.total, 10), 10)}' +
              '${fillSpaceText(getRightAlignedText(transaction.firstRowData.sts, 9), 9)}',
        ),
      );

      currentRow++;
      _checkEndPage();

      for (final tableItem in transaction.tableData) {
        bytes += generator.textEncoded(
          await getThaiEncoded(
            '${fillSpaceText(tableItem.product, 10)}${getTabs(1)}' +
                '${fillSpaceText(tableItem.name, 34)}${getTabs(1)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.pack, 4), 4)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.order, 6), 6)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.foc, 12), 12)}${getTabs(1)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.pricePerUnit, 9), 9)}${getTabs(1)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.price, 9), 9)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.percentDiscount, 9), 9)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.discount, 10), 10)}' +
                '${fillSpaceText(getRightAlignedText(tableItem.total, 9), 9)}',
          ),
        );

        currentRow++;
        _checkEndPage();
      }

      bytes += generator.hr(len: 120);
      currentRow++;
      _checkEndPage();
    }

    bytes += generator.row([
      PosColumn(width: 1, text: 'TOTAL ==>'),
      PosColumn(width: 4),
      PosColumn(
          width: 1,
          text: getTabs(4) + ' ' + getRightAlignedText(data.totalRow.price, 9)),
      PosColumn(
          width: 1,
          text: getTabs(5) +
              ' ' +
              getRightAlignedText(data.totalRow.discount, 8)),
      PosColumn(
          width: 1,
          text: getTabs(5) +
              ' ' +
              getRightAlignedText(data.totalRow.deliveryOrderFee, 8)),
      PosColumn(
          width: 1,
          text: getTabs(5) + getRightAlignedText(data.totalRow.tax, 7)),
      PosColumn(
          width: 3,
          text: getTabs(4) + ' ' + getRightAlignedText(data.totalRow.total, 8)),
    ]);

    bytes += generator.hr(len: 120);
    currentRow += 2;

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static List<int> _getBtrHeader(
    Generator generator,
    int page,
    BtrReportModel data,
  ) {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page $page', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(20) +
            (data.isPreOrder
                ? 'ORDER TRANSACTION REPORT'
                : 'BILL TRANSACTION REPORT'),
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 10,
        text: getTabs(17) +
            'Date From ${data.dateSelectedFrom} To ${data.dateSelectedTo}',
      ),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120, ch: '=');

    bytes += generator.row([
      PosColumn(width: 1, text: 'NO PRODUCT'),
      PosColumn(width: 1, text: getTabs(1) + 'EFF. DATE'),
      PosColumn(width: 1, text: getTabs(2) + 'CRT. DATE'),
      PosColumn(width: 1, text: getTabs(3) + 'CUST. NAME'),
      PosColumn(width: 1),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('PRICE', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText(' D/I', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText(' D/O', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText(' TAX', 7)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('TOTAL', 8)),
      PosColumn(width: 2, text: getTabs(4) + getRightAlignedText('STS', 8)),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'PRODUCT'),
      PosColumn(width: 1, text: getTabs(1) + 'NAME'),
      PosColumn(width: 1),
      PosColumn(width: 1),
      PosColumn(
          width: 1,
          text: getTabs(3) +
              getRightAlignedText('PACK', 5) +
              getTabs(1) +
              getRightAlignedText('ORDER', 5)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('FOC', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText(' PRC/U', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText(' PRICE', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText(' %DI', 7)),
      PosColumn(
          width: 1, text: getTabs(5) + getRightAlignedText('DISCOUNT', 8)),
      PosColumn(width: 2, text: getTabs(4) + getRightAlignedText('TOTAL', 8)),
    ]);

    bytes += generator.hr(len: 120, ch: '=');

    return bytes;
  }

  static Future<List<int>> _getBtlReportContent(
    Generator generator,
    BtlReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    void _checkEndPage() {
      if (currentRow >= MAX_ROW_PER_PAGE - GAP_END_PAGE) {
        currentPage++;
        bytes += generator.hr(len: 120, ch: '=');
        bytes += generator.emptyLines(3);
        currentRow = 0;
        bytes += _getBtlHeader(generator, currentPage, data);
        currentRow += BTL_HEADER_ROW;
      }
    }

    // Header section
    bytes += _getBtlHeader(generator, currentPage, data);
    currentRow += BTL_HEADER_ROW;

    for (final transferData in data.transferList) {
      bytes += generator.textEncoded(
        await getThaiEncoded(
          '${fillSpaceText(transferData.transferNo, 10)} ${getTabs(1)}' +
              '${fillSpaceText(transferData.locFrom, 4)}${getTabs(3)}' +
              '${fillSpaceText(transferData.locTo, 4)}${getTabs(2)}' +
              '${fillSpaceText(transferData.productCode, 9)} ${getTabs(1)}' +
              '${fillSpaceText(transferData.description, 30)}${getTabs(1)}' +
              '${fillSpaceText(getRightAlignedText(transferData.unitCode, 4), 4)}${getTabs(2)}' +
              '${fillSpaceText(getRightAlignedText(transferData.perPack, 4), 4)} ' +
              '${fillSpaceText(getRightAlignedText(transferData.quantity, 6), 6)}' +
              '${fillSpaceText(getRightAlignedText(transferData.unitPrice, 10), 10)}' +
              '${fillSpaceText(getRightAlignedText(transferData.amount, 11), 11)} ' +
              '${fillSpaceText(getRightAlignedText(transferData.status, 2), 2)}',
        ),
      );

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);
    currentRow++;
    _checkEndPage();

    bytes += generator.row([
      PosColumn(width: 1, text: 'Total ${data.totalRecord} Record(s)'),
      PosColumn(width: 8, text: ''),
      PosColumn(
        width: 1,
        text: getTabs(5) +
            ' ' +
            getRightAlignedText(
              data.totalAmount,
              10,
            ),
      ),
      PosColumn(width: 2, text: ''),
    ]);
    currentRow++;
    _checkEndPage();

    bytes += generator.hr(len: 120);
    currentRow++;

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static List<int> _getBtlHeader(
    Generator generator,
    int page,
    BtlReportModel data,
  ) {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page $page', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(21) + 'BILL TRANSFER LISTING',
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 10,
        text: getTabs(17) +
            'Date From ${data.dateSelectedFrom} To ${data.dateSelectedTo}',
      ),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    bytes += generator.row([
      PosColumn(width: 1, text: 'TRN NO'),
      PosColumn(width: 1, text: getTabs(1) + ' ' + 'LOC.FROM'),
      PosColumn(width: 1, text: getTabs(1) + ' ' + 'TO'),
      PosColumn(width: 1, text: 'PRODUCT'),
      PosColumn(width: 1, text: ' ' + 'DESCRIPTION'),
      PosColumn(
          width: 1,
          text: getTabs(8) + ' ' + getRightAlignedText('UNIT CODE', 10)),
      PosColumn(
          width: 1, text: getTabs(8) + ' ' + getRightAlignedText('PERPACK', 8)),
      PosColumn(
          width: 1, text: getTabs(6) + ' ' + getRightAlignedText('QTY', 8)),
      PosColumn(
          width: 1, text: getTabs(6) + ' ' + getRightAlignedText('UNIT P', 8)),
      PosColumn(
          width: 1, text: getTabs(5) + ' ' + getRightAlignedText('AMOUNT', 10)),
      PosColumn(
          width: 1, text: getTabs(3) + ' ' + getRightAlignedText('STA', 8)),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    return bytes;
  }

  static Future<List<int>> _getOsrReportContent(
    Generator generator,
    OsrReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    void _checkEndPage() {
      if (currentRow >= MAX_ROW_PER_PAGE - GAP_END_PAGE) {
        currentPage++;
        bytes += generator.hr(len: 120, ch: '=');
        bytes += generator.emptyLines(3);
        currentRow = 0;
        bytes += _getOsrHeader(generator, currentPage, data);
        currentRow += OSR_HEADER_ROW;
      }
    }

    // Header section
    bytes += _getOsrHeader(generator, currentPage, data);
    currentRow += OSR_HEADER_ROW;

    for (final orderData in data.orderList) {
      bytes += generator.textEncoded(
        await getThaiEncoded(
          '${fillSpaceText(orderData.partNo, 9)} ${fillSpaceText(orderData.description, 30)}' +
              '${getTabs(1)} ${fillSpaceText(orderData.unit, 3)}' +
              '${getTabs(3)}${fillSpaceText(getRightAlignedText(orderData.perPack, 4), 4)} ' +
              '${fillSpaceText(getRightAlignedText(orderData.price, 12), 12)} ${fillSpaceText(getRightAlignedText(orderData.quantity, 5), 5)} ' +
              '${fillSpaceText(getRightAlignedText(orderData.foc, 4), 4)} ${fillSpaceText(getRightAlignedText(orderData.discount, 10), 10)} ' +
              '${fillSpaceText(getRightAlignedText(orderData.tax, 10), 10)} ${fillSpaceText(getRightAlignedText(orderData.amount, 12), 12)} ' +
              '${fillSpaceText(getRightAlignedText(orderData.lite, 4), 4)}',
        ),
      );

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);
    currentRow++;
    _checkEndPage();

    bytes += generator.row([
      PosColumn(width: 2, text: 'Total Amount'),
      PosColumn(
        width: 1,
        text: getTabs(2) + getRightAlignedText(data.totalAmount, 12),
      ),
      PosColumn(width: 9, text: ''),
    ]);
    currentRow++;
    _checkEndPage();

    bytes += generator.row([
      PosColumn(width: 2, text: 'Total Lit:'),
      PosColumn(
        width: 1,
        text: getTabs(2) + getRightAlignedText(data.totalLit, 12),
      ),
      PosColumn(width: 9, text: ''),
    ]);
    currentRow++;
    _checkEndPage();

    bytes += generator.emptyLines(1);
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Reference in ==>');
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Bill');
    currentRow++;
    _checkEndPage();

    bytes += generator.text(data.referenceList);
    currentRow++;
    _checkEndPage();

    bytes += generator.text('Order');
    currentRow++;

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static List<int> _getOsrHeader(
    Generator generator,
    int page,
    OsrReportModel data,
  ) {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page $page', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(21) + 'ORDER SUMMARY REPORT',
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 10,
        text: getTabs(16) +
            'Date Selected From ${data.dateSelectedFrom} To ${data.dateSelectedTo}',
      ),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    bytes += generator.row([
      PosColumn(width: 1, text: 'PART NO'),
      PosColumn(width: 1, text: 'DESCRIPTION'),
      PosColumn(width: 1, text: getTabs(11) + 'UNIT'),
      PosColumn(
          width: 1, text: getTabs(8) + ' ' + getRightAlignedText('PERPACK', 8)),
      PosColumn(
          width: 1, text: getTabs(8) + ' ' + getRightAlignedText('PRICE', 10)),
      PosColumn(
          width: 1, text: getTabs(8) + ' ' + getRightAlignedText('QTY', 6)),
      PosColumn(width: 1, text: getTabs(6) + getRightAlignedText('FOC', 6)),
      PosColumn(width: 1, text: getTabs(4) + getRightAlignedText('D/I', 10)),
      PosColumn(
          width: 1, text: getTabs(4) + ' ' + getRightAlignedText('TAX', 10)),
      PosColumn(
          width: 1, text: getTabs(5) + ' ' + getRightAlignedText('AMOUNT', 10)),
      PosColumn(
          width: 1, text: getTabs(5) + ' ' + getRightAlignedText('LITE', 5)),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    return bytes;
  }

  static Future<List<int>> _getCsrReportContent(
    Generator generator,
    CsrReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    void _checkEndPage() {
      if (currentRow >= MAX_ROW_PER_PAGE - GAP_END_PAGE) {
        currentPage++;
        bytes += generator.hr(len: 120, ch: '=');
        bytes += generator.emptyLines(3);
        currentRow = 0;
        bytes += _getCsrHeader(generator, currentPage, data);
        currentRow += CSR_HEADER_ROW;
      }
    }

    bytes += _getCsrHeader(generator, currentPage, data);
    currentRow = CSR_HEADER_ROW;

    for (final stockData in data.stockList) {
      bytes += generator.textEncoded(
        await getThaiEncoded(
          "${fillSpaceText(stockData.productCode, 9)} ${fillSpaceText(stockData.description, 30)}${getTabs(2)} " +
              "${fillSpaceText(getRightAlignedText(stockData.perPack, 4), 4)}${getTabs(4)}" +
              "${fillSpaceText(getRightAlignedText(stockData.unitCode, 4), 4)}${getTabs(6)}" +
              "${fillSpaceText(getRightAlignedText(stockData.onHandGood, 8), 8)}${getTabs(5)} " +
              "${fillSpaceText(getRightAlignedText(stockData.onCarGood, 8), 8)}${getTabs(5)} " +
              "${fillSpaceText(getRightAlignedText(stockData.location, 6), 6)}",
        ),
      );

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);
    currentRow++;
    _checkEndPage();

    bytes += generator.text("Total: ${data.totalRecord} Record(s)");
    currentRow++;

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static List<int> _getCsrHeader(
    Generator generator,
    int page,
    CsrReportModel data,
  ) {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page $page', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(21) + 'CHECKING STOCK REPORT',
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 10,
        text: getTabs(21) + 'Product Group: To',
      ),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    bytes += generator.row([
      PosColumn(width: 1, text: 'PRODUCT'),
      PosColumn(width: 3, text: 'DESCRIPTION'),
      PosColumn(width: 1, text: getRightAlignedText('PERPACK', 8)),
      PosColumn(width: 1, text: getRightAlignedText('UNIT CODE', 10)),
      PosColumn(
          width: 2,
          text: getTabs(3) + ' ' + getRightAlignedText('ON_HAND_GOOD', 12)),
      PosColumn(
          width: 2,
          text: getTabs(2) + ' ' + getRightAlignedText('ON_CAR_GOOD', 12)),
      PosColumn(
          width: 1,
          text: getTabs(1) + ' ' + getRightAlignedText('LOCATION', 10)),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    return bytes;
  }

  static Future<List<int>> _getRrsrReportContent(
    Generator generator,
    RrsrReportModel data,
  ) async {
    List<int> bytes = [];
    int currentPage = 1;
    int currentRow = 0;

    // call this function whenever add a new line
    Future<void> _checkEndPage() async {
      if (currentRow >= MAX_RRSR_ROW_PER_PAGE) {
        // add the footer to every end of page
        bytes += generator.emptyLines(2);

        bytes += generator.text(
          'S/M :............................' +
              getTabs(3) +
              'A/M :............................' +
              getTabs(3) +
              'W/H OR ADM :............................',
        );

        bytes += generator.emptyLines(2);

        bytes += generator.text(
          'Date:............................' +
              getTabs(3) +
              'Date:............................' +
              getTabs(3) +
              'Date:...................................',
        );

        currentRow += 6;
        bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow);

        currentPage++;
        currentRow = RRSR_HEADER_ROW;
        bytes += await _getRrsrHeader(generator, currentPage, data);
      }
    }

    // Header section
    bytes += await _getRrsrHeader(generator, currentPage, data);
    currentRow = RRSR_HEADER_ROW;

    bytes += generator.text('FROM W/H: ${data.fromWh} TO ${data.toWh}');
    currentRow += 1;

    for (final rrData in data.rrList) {
      bytes += generator.emptyLines(2);
      currentRow += 2;
      await _checkEndPage();

      final String title = '*****  ${rrData.title}  *****';
      bytes += generator.textEncoded(await getThaiEncoded(title));
      bytes += generator.hr(len: title.length);
      currentRow += 2;
      await _checkEndPage();

      for (final product in rrData.productList) {
        bytes += generator.textEncoded(
          await getThaiEncoded(
            "${fillSpaceText(product.productCode, 9)} ${fillSpaceText(product.description, 30)}${getTabs(2)} " +
                "${fillSpaceText(getRightAlignedText(product.perPack, 4), 4)}${getTabs(4)}" +
                "${fillSpaceText(getRightAlignedText(product.unitCode, 4), 4)}${getTabs(3)}" +
                "${fillSpaceText(getRightAlignedText(product.quantity, 8), 8)}",
          ),
        );

        bytes += generator.hr(len: 120);

        currentRow += 2;
        await _checkEndPage();
      }
    }

    // last page's footer section
    bytes += generator.emptyLines(2);
    currentRow += 2;
    await _checkEndPage();

    bytes += generator.text(
      'S/M :............................' +
          getTabs(3) +
          'A/M :............................' +
          getTabs(3) +
          'W/H OR ADM :............................',
    );
    currentRow++;
    await _checkEndPage();

    bytes += generator.emptyLines(2);
    currentRow += 2;
    await _checkEndPage();

    bytes += generator.text(
      'Date:............................' +
          getTabs(3) +
          'Date:............................' +
          getTabs(3) +
          'Date:...................................',
    );
    currentRow++;
    await _checkEndPage();

    // move to a new page when finish
    if (currentRow < MAX_ROW_PER_PAGE) {
      bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow - 2);
    }

    return bytes;
  }

  static Future<List<int>> _getRrsrHeader(
    Generator generator,
    int page,
    RrsrReportModel data,
  ) async {
    List<int> bytes = [];

    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page $page', 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Date ${data.date} Time ${data.time}'),
      PosColumn(
        width: 9,
        text: getTabs(20) + 'RETURN & RECEIPT STOCK REPORT',
      ),
      PosColumn(
        width: 2,
        text: getRightAlignedText(data.smNumber, 14),
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 8),
      PosColumn(
          width: 2,
          textEncoded: await getThaiEncoded('*****  ${data.subtitle}  *****')),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Ref.: ${data.ref}', 14),
      ),
    ]);

    bytes += generator.hr(len: 120);

    bytes += generator.row([
      PosColumn(width: 1, text: 'PRODUCT'),
      PosColumn(width: 3, text: 'DESCRIPTION'),
      PosColumn(width: 1, text: getRightAlignedText('PERPACK', 8)),
      PosColumn(width: 1, text: getRightAlignedText('UNIT CODE', 10)),
      PosColumn(
        width: 2,
        text: getTabs(1) + getRightAlignedText(' PHYSICAL QUANTITY', 12),
      ),
      PosColumn(width: 4),
    ]);

    bytes += generator.hr(len: 120);

    return bytes;
  }

  // static List<int> _getRrsrFooter(Generator generator) {
  //   List<int> bytes = [];

  //   bytes += generator.emptyLines(2);

  //   bytes += generator.text(
  //     'S/M :............................' +
  //         getTabs(3) +
  //         'A/M :............................' +
  //         getTabs(3) +
  //         'W/H OR ADM :............................',
  //   );

  //   bytes += generator.emptyLines(2);

  //   bytes += generator.text(
  //     'Date:............................' +
  //         getTabs(3) +
  //         'Date:............................' +
  //         getTabs(3) +
  //         'Date:...................................',
  //   );

  //   return bytes;
  // }

  static void _printEscPos(
    List<int> bytes,
    Generator generator,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    bytes += generator.cut();

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
          type: PrinterType.usb,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
          type: PrinterType.bluetooth,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
            autoConnect: true,
          ),
        );
        break;
      default:
        break;
    }

    if ((bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
            Platform.isAndroid) ||
        (bluetoothPrinter.typePrinter == PrinterType.usb &&
            Platform.isWindows)) {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    } else {
      throw UnsupportedError("Only available on Android device");
    }
  }
}
