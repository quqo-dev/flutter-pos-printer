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
const int MAX_ADDRESS_CHAR_PER_ROW = 40;
const int MAX_BILLING_PRODUCT_PER_PAGE = 8;
const int MAX_CCLR_ROW_PER_PAGE = 50;
const int MAX_DSSR_ROW_PER_PAGE = 50;
const int MAX_BTL_ROW_PER_PAGE = 50;
const int MAX_OSR_ROW_PER_PAGE = 48;
const int MAX_CSR_ROW_PER_PAGE = 60;
const int MAX_RRSR_ROW_PER_PAGE = 50;

const int BTR_HEADER_ROW = 7;
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

        final int pages = data.stockList.length ~/ MAX_DSSR_ROW_PER_PAGE +
            (data.stockList.length % MAX_DSSR_ROW_PER_PAGE != 0 ? 1 : 0);

        bytes = await _getDssrReportContent(pages, generator, data);
        break;
      case BillType.Cclr:
        if (data is! CclrReportModel) {
          throw FormatException('Error! Type must be CclrBillModel');
        }

        final int pages = data.callingList.length ~/ MAX_CCLR_ROW_PER_PAGE +
            (data.callingList.length % MAX_CCLR_ROW_PER_PAGE != 0 ? 1 : 0);

        bytes = await _getCclrReportContent(pages, generator, data);
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

        final int pages = data.transferList.length ~/ MAX_BTL_ROW_PER_PAGE +
            (data.transferList.length % MAX_BTL_ROW_PER_PAGE != 0 ? 1 : 0);

        bytes = await _getBtlReportContent(pages, generator, data);
        break;
      case BillType.Osr:
        if (data is! OsrReportModel) {
          throw FormatException('Error! Type must be OsrBillModel');
        }

        final int pages = data.orderList.length ~/ MAX_OSR_ROW_PER_PAGE +
            (data.orderList.length % MAX_OSR_ROW_PER_PAGE != 0 ? 1 : 0);

        bytes = await _getOsrReportContent(pages, generator, data);
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
          textEncoded: await getThaiEncoded(
            data.address.length <= MAX_ADDRESS_CHAR_PER_ROW
                ? data.address
                : data.address.substring(0, MAX_ADDRESS_CHAR_PER_ROW),
          ),
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
      if (data.address.length > MAX_ADDRESS_CHAR_PER_ROW) {
        bytes += generator.row([
          PosColumn(width: 1),
          PosColumn(
            width: 11,
            textEncoded: await getThaiEncoded(
                data.address.substring(MAX_ADDRESS_CHAR_PER_ROW)),
          ),
        ]);
      } else {
        bytes += generator.emptyLines(1);
      }

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
            ' ${fillSpaceText(item.productCode, 9)} ${fillSpaceText(item.productList, 28)}' +
                ' ${getRightAlignedText(item.soldAmount, 5)} ${getRightAlignedText(item.freeAmount, 5)}' +
                '${getRightAlignedText(item.amountBeforeVAT, 11)} ${getRightAlignedText(item.discountBeforeVAT, 8)}' +
                '${getRightAlignedText(item.amountAfterVAT, 11)}${getRightAlignedText(item.pricePerCanAfterVAT, 8)}',
          ),
        );
      }

      // The rest empty lines of table
      bytes += generator.emptyLines(
        MAX_BILLING_PRODUCT_PER_PAGE - currentListItem,
      );

      // Spacing for the next row
      bytes += generator.emptyLines(2);

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

      bytes += generator.emptyLines(3);

      bytes += generator
          .textEncoded(await getThaiEncoded(getTabs(4) + data.deliveryAt));
      bytes += generator
          .textEncoded(await getThaiEncoded(getTabs(4) + data.deliveryAddress));

      if (outerIdx < totalPages - 1) {
        bytes += generator.emptyLines(4);
      }
    }

    return bytes;
  }

  static Future<List<int>> _getDdcReportContent(
    Generator generator,
    DdcReportModel data,
  ) async {
    List<int> bytes = [];

    // Header section
    bytes += generator.row([
      PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
      PosColumn(width: 9),
      PosColumn(
        width: 2,
        text: getRightAlignedText('Page ${data.page}', 14),
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
      PosColumn(width: 1, text: 'DATE'),
      PosColumn(width: 1, text: getTabs(3) + ' ' + 'CUST'),
      PosColumn(width: 1, text: getTabs(2) + ' ' + 'NAME'),
      PosColumn(width: 1, text: getTabs(7) + getRightAlignedText('PRICE', 11)),
      PosColumn(
          width: 1, text: getTabs(8) + ' ' + getRightAlignedText('D/I', 8)),
      PosColumn(
          width: 1, text: getTabs(6) + ' ' + getRightAlignedText('D/O', 8)),
      PosColumn(
          width: 1, text: getTabs(5) + getRightAlignedText('NET_AMT', 10)),
      PosColumn(
          width: 1, text: getTabs(5) + ' ' + getRightAlignedText('TAX', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('TOT', 9)),
      PosColumn(width: 1, text: getTabs(4) + ' ' + 'ST'),
      PosColumn(width: 1, text: ' ' + 'L'),
    ]);

    bytes += generator.hr(len: 120);

    // 1st table
    for (final customerPrice in data.customerPriceList) {
      bytes += generator.row([
        PosColumn(width: 1, text: customerPrice.no),
        PosColumn(width: 1, text: customerPrice.date),
        PosColumn(width: 1, text: getTabs(3) + ' ' + customerPrice.customerId),
        PosColumn(
          width: 1,
          textEncoded: await getThaiEncoded(
              getTabs(2) + ' ' + customerPrice.customerName),
        ),
        PosColumn(
            width: 1,
            text: getTabs(7) + getRightAlignedText(customerPrice.price, 11)),
        PosColumn(
            width: 1,
            text: getTabs(8) +
                ' ' +
                getRightAlignedText(customerPrice.diValue, 8)),
        PosColumn(
            width: 1,
            text: getTabs(6) +
                ' ' +
                getRightAlignedText(customerPrice.doValue, 8)),
        PosColumn(
            width: 1,
            text:
                getTabs(5) + getRightAlignedText(customerPrice.netAmount, 10)),
        PosColumn(
            width: 1,
            text: getTabs(5) + ' ' + getRightAlignedText(customerPrice.tax, 8)),
        PosColumn(
            width: 1,
            text: getTabs(5) + getRightAlignedText(customerPrice.total, 9)),
        PosColumn(width: 1, text: ' ' + getTabs(4) + customerPrice.st),
        PosColumn(width: 1, text: ' ' + customerPrice.l),
      ]);
    }

    bytes += generator.hr(len: 120);

    // 2nd table
    for (final bill in data.billStatusList) {
      bytes += generator.row([
        PosColumn(width: 1, text: 'STATUS ${bill.name}'),
        PosColumn(width: 1, text: '${bill.quantity} BILL'),
        PosColumn(width: 1, text: getTabs(3) + ' ' + 'TOTAL==>'),
        PosColumn(width: 1),
        PosColumn(
            width: 1, text: getTabs(7) + getRightAlignedText(bill.price, 11)),
        PosColumn(
            width: 1,
            text: getTabs(8) + ' ' + getRightAlignedText(bill.diValue, 8)),
        PosColumn(
            width: 1,
            text: getTabs(6) + ' ' + getRightAlignedText(bill.doValue, 8)),
        PosColumn(
            width: 1,
            text: getTabs(5) + getRightAlignedText(bill.netAmount, 10)),
        PosColumn(
            width: 1,
            text: getTabs(5) + ' ' + getRightAlignedText(bill.tax, 8)),
        PosColumn(
            width: 1, text: getTabs(5) + getRightAlignedText(bill.total, 9)),
        PosColumn(width: 1),
        PosColumn(width: 1, text: ' ' + getRightAlignedText(bill.quantity, 2)),
      ]);
    }

    bytes += generator.hr(len: 120);

    // 3rd table
    for (final payment in data.paymentTypeList) {
      bytes += generator.row([
        PosColumn(width: 1, text: payment.name),
        PosColumn(width: 1),
        PosColumn(
            width: 1,
            text: getTabs(3) + ' TOTAL==>BATCH NO.:${payment.batchNo}'),
        PosColumn(width: 1),
        PosColumn(
            width: 1,
            text: getTabs(7) + getRightAlignedText(payment.price, 11)),
        PosColumn(
            width: 1,
            text: getTabs(8) + ' ' + getRightAlignedText(payment.diValue, 8)),
        PosColumn(
            width: 1,
            text: getTabs(6) + ' ' + getRightAlignedText(payment.doValue, 8)),
        PosColumn(
            width: 1,
            text: getTabs(5) + getRightAlignedText(payment.netAmount, 10)),
        PosColumn(
            width: 1,
            text: getTabs(5) + ' ' + getRightAlignedText(payment.tax, 8)),
        PosColumn(
            width: 1, text: getTabs(5) + getRightAlignedText(payment.total, 9)),
        PosColumn(width: 1),
        PosColumn(width: 1, text: ' ' + getRightAlignedText(payment.l, 3)),
      ]);
    }

    for (final visitCustomer in data.visitCustomerList) {
      bytes += generator.row([
        PosColumn(width: 1, text: visitCustomer.name),
        PosColumn(width: 1),
        PosColumn(width: 1, text: getTabs(3) + ' TOTAL==>'),
        PosColumn(width: 1),
        PosColumn(
          width: 8,
          text: getRightAlignedText(visitCustomer.soldAmount, 4) +
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
      ]);
    }

    bytes += generator.hr(len: 120);

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

    bytes += generator.text('*** Payment by Transporter(s) ***');

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
    }

    bytes += generator.text('*** Order Summary(s) ***');

    for (final orderSummary in data.orderSummaryList) {
      // last row
      if (orderSummary.secondName == 'Total') {
        bytes += generator.hr(len: 120);
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
    }

    bytes += generator.hr(len: 120);

    // templates
    // bytes += generator.text(
    //     'CASH SALES   - Running Number FORM-USAGE FROM.................. TO .................. TOTAL...... BILL(S)');
    // bytes += generator.text(
    //     '             - Running Number FORM-CANCELATION NO.................................... TOTAL...... BILL(S)');
    // bytes += generator.text(
    //     'CREDIT SALES - Running Number FORM-USAGE FROM.................. TO .................. TOTAL...... BILL(S)');
    // bytes += generator.text(
    //     '             - Running Number FORM-CANCELATION NO.................................... TOTAL...... BILL(S)');
    // bytes += generator.text(
    //     'NOTE: THE RUNNING NUMBER FROM IS AT THE RIGHT BOTTOM OF INVOICE');

    // bytes += generator.hr(len: 120);

    // bytes += generator.text(
    //     'Collection Sheet.............A' + getTabs(2) + 'Text.............A');
    // bytes += generator.text(
    //     'Sample text.............text.............text.............A Text.............text   Sample text.............baht');
    // bytes += generator.text(
    //     'Sample text.............text.............text.............A Text.............text');
    // bytes +=
    //     generator.text('Sample text.............Sample text.............baht');
    // bytes += generator.text(
    //     'Sample text.............Sample text.............baht Sample text.............baht Sample text.............');

    // bytes += generator.hr(len: 120);

    bytes += generator.text('Total balance  ${data.totalBalance}  baht');
    bytes += generator.text('Total cash balance  ${data.totalCashBalance}  baht' +
        getTabs(2) +
        'Cash payment........................................................baht');
    bytes += generator.text('Total credit balance  ${data.creditBalance}  baht' +
        getTabs(2) +
        'Credit card payment slip amount........  Leaves value...............baht');
    bytes += generator.text(
        'Pay by............................  Get paid by............................');

    bytes += generator.hr(len: 120);

    return bytes;
  }

  static Future<List<int>> _getDssrReportContent(
    int totalPages,
    Generator generator,
    DssrReportModel data,
  ) async {
    List<int> bytes = [];

    for (int outerIdx = 0; outerIdx < totalPages; outerIdx++) {
      // Header section
      bytes += generator.row([
        PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
        PosColumn(width: 9),
        PosColumn(
          width: 2,
          text: getRightAlignedText('Page ${outerIdx + 1}', 14),
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
          text:
              getTabs(16) + 'Selected Date : ${data.selectedDate} All Products',
        ),
        PosColumn(width: 1),
      ]);

      bytes += generator.hr(len: 120, ch: '=');

      bytes += generator.row([
        PosColumn(width: 1, text: 'PRODUCT'),
        PosColumn(width: 2, text: 'NAME'),
        PosColumn(
          width: 9,
          text: getTabs(5) +
              ' ' +
              getRightAlignedText('W/H', 6) +
              getRightAlignedText('PER', 5) +
              getRightAlignedText('OPEN', 6) +
              getRightAlignedText('SALE', 6) +
              getRightAlignedText('GOODS', 8) +
              getRightAlignedText('TRANSF', 7) +
              getRightAlignedText('TRANSF', 7) +
              getRightAlignedText('FOC', 5) +
              getRightAlignedText('', 5) +
              getRightAlignedText('CLOSE', 6) +
              getRightAlignedText('ONHAND', 6),
        ),
      ]);

      bytes += generator.row([
        PosColumn(width: 1),
        PosColumn(width: 2),
        PosColumn(
          width: 9,
          text: getTabs(5) +
              ' ' +
              getRightAlignedText('', 6) +
              getRightAlignedText('PACK', 5) +
              getRightAlignedText('BAL', 6) +
              getRightAlignedText('', 6) +
              getRightAlignedText('RETURNS', 8) +
              getRightAlignedText('IN', 7) +
              getRightAlignedText('OUT', 7) +
              getRightAlignedText('X', 5) +
              getRightAlignedText('Y', 5) +
              getRightAlignedText('BAL', 6),
        ),
      ]);

      bytes += generator.hr(len: 120, ch: '=');

      int currentListItem = 0;

      for (int listIdx = 0; listIdx < MAX_DSSR_ROW_PER_PAGE; listIdx++) {
        final int currentListIdx = outerIdx * MAX_DSSR_ROW_PER_PAGE + listIdx;

        if (currentListIdx >= data.stockList.length) break;

        currentListItem++;
        final StockModel stock = data.stockList[currentListIdx];

        bytes += generator.textEncoded(
          await getThaiEncoded(
            '${fillSpaceText(stock.id, 9)} ${fillSpaceText(stock.name, 30)} ' +
                '${getTabs(1)} ${stock.wh} ${getRightAlignedText(stock.perPack, 5)}' +
                '${getRightAlignedText(stock.openBal, 6)}${getRightAlignedText(stock.sale, 6)}' +
                '${getRightAlignedText(stock.goodsReturn, 8)}${getRightAlignedText(stock.transfIn, 7)}' +
                '${getRightAlignedText(stock.transfOut, 7)}${getRightAlignedText(stock.focX, 5)}' +
                '${getRightAlignedText(stock.focY, 5)}${getRightAlignedText(stock.closeBal, 6)}' +
                '${getRightAlignedText(stock.onhand, 6)}',
          ),
        );

        // bytes += generator.row([
        //   PosColumn(width: 1, text: stock.id),
        //   PosColumn(width: 2, textEncoded: await getThaiEncoded(stock.name)),
        //   PosColumn(
        //     width: 9,
        //     text: getTabs(5) +
        //         ' ' +
        //         getRightAlignedText(stock.wh, 6) +
        //         getRightAlignedText(stock.perPack, 5) +
        //         getRightAlignedText(stock.openBal, 6) +
        //         getRightAlignedText(stock.sale, 6) +
        //         getRightAlignedText(stock.goodsReturn, 8) +
        //         getRightAlignedText(stock.transfIn, 7) +
        //         getRightAlignedText(stock.transfOut, 7) +
        //         getRightAlignedText(stock.focX, 5) +
        //         getRightAlignedText(stock.focY, 5) +
        //         getRightAlignedText(stock.closeBal, 6) +
        //         getRightAlignedText(stock.onhand, 6),
        //   ),
        // ]);
      }

      // bytes += generator.hr(len: 120, ch: '=');

      // bytes += generator.text('NO OF PRODUCT : $currentListItem LIST');

      // bytes += generator.hr(len: 120, ch: '=');

      // if (outerIdx < totalPages - 1) {
      //   bytes += generator.emptyLines(4);
      // }
    }

    return bytes;
  }

  static Future<List<int>> _getCclrReportContent(
    int totalPages,
    Generator generator,
    CclrReportModel data,
  ) async {
    List<int> bytes = [];

    for (int outerIdx = 0; outerIdx < totalPages; outerIdx++) {
      // Header section
      bytes += generator.row([
        PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
        PosColumn(width: 9),
        PosColumn(
          width: 2,
          text: getRightAlignedText('Page ${outerIdx + 1}', 14),
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

      int currentListItem = 0;

      for (int listIdx = 0; listIdx < MAX_CCLR_ROW_PER_PAGE; listIdx++) {
        final int currentListIdx = outerIdx * MAX_CCLR_ROW_PER_PAGE + listIdx;

        if (currentListIdx >= data.callingList.length) break;

        currentListItem++;

        final CallingModel callingItem = data.callingList[currentListIdx];

        bytes += generator.textEncoded(
          await getThaiEncoded(
            '${callingItem.date}${getTabs(1)}${callingItem.custCode}' +
                '${getTabs(1)} ${fillSpaceText(callingItem.custName, 41)}' +
                '${fillSpaceText(callingItem.reason, 19)}' +
                '${getTabs(2)}${fillSpaceText(callingItem.typeOfShop, 24)}' +
                '${callingItem.time}',
          ),
        );
      }

      bytes += generator.hr(len: 120, ch: '=');

      bytes += generator.text('Total $currentListItem');

      bytes += generator.hr(len: 120, ch: '=');

      bytes += generator.text('Grand Total ${data.grandTotal}');

      if (outerIdx < totalPages - 1) {
        bytes += generator.emptyLines(4);
      }
    }

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
      if (currentRow >= MAX_ROW_PER_PAGE) {
        currentPage++;
        currentRow = BTR_HEADER_ROW;
        bytes += _getBtrHeader(generator, currentPage, data);
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
              '${fillSpaceText(transaction.firstRowData.customerName, 22)}' +
              '${getRightAlignedText(transaction.firstRowData.price, 11)} ' +
              '${getRightAlignedText(transaction.firstRowData.discount, 8)}${getTabs(1)}' +
              '${getRightAlignedText(transaction.firstRowData.deliveryOrderFee, 8)}' +
              '${getRightAlignedText(transaction.firstRowData.tax, 7)} ' +
              '${getRightAlignedText(transaction.firstRowData.total, 9)}' +
              '${getRightAlignedText(transaction.firstRowData.sts, 8)}',
        ),
      );

      currentRow++;
      _checkEndPage();

      for (final tableItem in transaction.tableData) {
        bytes += generator.textEncoded(
          await getThaiEncoded(
            '${fillSpaceText(tableItem.product, 10)}${getTabs(1)}' +
                '${fillSpaceText(tableItem.name, 34)}${getTabs(1)}' +
                '${getRightAlignedText(tableItem.pack, 4)}' +
                '${getRightAlignedText(tableItem.order, 7)} ' +
                '${getRightAlignedText(tableItem.foc, 8)}' +
                '${getRightAlignedText(tableItem.pricePerUnit, 9)}${getTabs(1)}' +
                '${getRightAlignedText(tableItem.price, 8)} ' +
                '${getRightAlignedText(tableItem.percentDiscount, 7)} ' +
                '${getRightAlignedText(tableItem.discount, 9)}' +
                '${getRightAlignedText(tableItem.total, 8)}',
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
          text: getTabs(5) + getRightAlignedText(data.totalRow.discount, 8)),
      PosColumn(
          width: 1,
          text: getTabs(5) +
              getRightAlignedText(data.totalRow.deliveryOrderFee, 8)),
      PosColumn(
          width: 1,
          text: getTabs(4) + ' ' + getRightAlignedText(data.totalRow.tax, 7)),
      PosColumn(
          width: 3,
          text: getTabs(4) + getRightAlignedText(data.totalRow.total, 8)),
    ]);

    bytes += generator.hr(len: 120);

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
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('D/I', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('D/O', 8)),
      PosColumn(
          width: 1, text: getTabs(4) + ' ' + getRightAlignedText('TAX', 7)),
      PosColumn(width: 1, text: getTabs(4) + getRightAlignedText('TOTAL', 8)),
      PosColumn(
          width: 2, text: getTabs(3) + ' ' + getRightAlignedText('STS', 8)),
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
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('PRC/U', 8)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('PRICE', 8)),
      PosColumn(
          width: 1, text: getTabs(4) + ' ' + getRightAlignedText('%DI', 7)),
      PosColumn(
          width: 1, text: getTabs(4) + getRightAlignedText('DISCOUNT', 8)),
      PosColumn(
          width: 2, text: getTabs(3) + ' ' + getRightAlignedText('TOTAL', 8)),
    ]);

    bytes += generator.hr(len: 120, ch: '=');

    return bytes;
  }

  static Future<List<int>> _getBtlReportContent(
    int totalPages,
    Generator generator,
    BtlReportModel data,
  ) async {
    List<int> bytes = [];

    for (int outerIdx = 0; outerIdx < totalPages; outerIdx++) {
      // Header section
      bytes += generator.row([
        PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
        PosColumn(width: 9),
        PosColumn(
          width: 2,
          text: getRightAlignedText('Page ${outerIdx + 1}', 14),
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

      // bytes += generator.row([
      //   PosColumn(width: 1),
      //   PosColumn(
      //     width: 10,
      //     text: getTabs(23) + 'No. ${data.reportNo}',
      //   ),
      //   PosColumn(width: 1),
      // ]);
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
            width: 1,
            text: getTabs(8) + ' ' + getRightAlignedText('PERPACK', 8)),
        PosColumn(
            width: 1, text: getTabs(6) + ' ' + getRightAlignedText('QTY', 8)),
        PosColumn(
            width: 1,
            text: getTabs(6) + ' ' + getRightAlignedText('UNIT P', 8)),
        PosColumn(
            width: 1,
            text: getTabs(5) + ' ' + getRightAlignedText('AMOUNT', 10)),
        PosColumn(
            width: 1, text: getTabs(3) + ' ' + getRightAlignedText('STA', 8)),
        PosColumn(width: 1),
      ]);

      bytes += generator.hr(len: 120);

      int currentListItem = 0;
      double currentTotalAmount = 0.0;

      for (int listIdx = 0; listIdx < MAX_BTL_ROW_PER_PAGE; listIdx++) {
        final int currentListIdx = outerIdx * MAX_BTL_ROW_PER_PAGE + listIdx;

        if (currentListIdx >= data.transferList.length) break;

        currentListItem++;
        final TransferItem transferData = data.transferList[currentListIdx];
        currentTotalAmount += getDoubleFromFormattedString(transferData.amount);

        bytes += generator.row([
          PosColumn(width: 1, text: transferData.transferNo),
          PosColumn(width: 1, text: getTabs(1) + ' ' + transferData.locFrom),
          PosColumn(width: 1, text: getTabs(1) + ' ' + transferData.locTo),
          PosColumn(width: 1, text: transferData.productCode),
          PosColumn(
            width: 1,
            textEncoded: await getThaiEncoded(' ' + transferData.description),
          ),
          PosColumn(
            width: 1,
            textEncoded: await getThaiEncoded(getTabs(8) +
                ' ' +
                getRightAlignedText(transferData.unitCode, 10)),
          ),
          PosColumn(
              width: 1,
              text: getTabs(8) +
                  ' ' +
                  getRightAlignedText(transferData.perPack, 8)),
          PosColumn(
              width: 1,
              text: getTabs(6) +
                  ' ' +
                  getRightAlignedText(transferData.quantity, 8)),
          PosColumn(
              width: 1,
              text: getTabs(6) +
                  ' ' +
                  getRightAlignedText(transferData.unitPrice, 8)),
          PosColumn(
              width: 1,
              text: getTabs(5) +
                  ' ' +
                  getRightAlignedText(transferData.amount, 10)),
          PosColumn(
              width: 1,
              text: getTabs(3) +
                  ' ' +
                  getRightAlignedText(transferData.status, 8)),
          PosColumn(width: 1),
        ]);
      }

      bytes += generator.hr(len: 120);

      bytes += generator.row([
        PosColumn(width: 1, text: 'Total $currentListItem Record(s)'),
        PosColumn(width: 8, text: ''),
        PosColumn(
          width: 1,
          text: getTabs(5) +
              ' ' +
              getRightAlignedText(
                formatCurrencyValue(
                  currentTotalAmount.toStringAsFixed(2),
                ),
                10,
              ),
        ),
        PosColumn(width: 2, text: ''),
      ]);

      bytes += generator.hr(len: 120);

      if (outerIdx < totalPages - 1) {
        bytes += generator.emptyLines(5);
      }
    }

    return bytes;
  }

  static Future<List<int>> _getOsrReportContent(
    int totalPages,
    Generator generator,
    OsrReportModel data,
  ) async {
    List<int> bytes = [];

    for (int outerIdx = 0; outerIdx < totalPages; outerIdx++) {
      // Header section
      bytes += generator.row([
        PosColumn(width: 1, text: 'DKSH (THAILAND) LIMITED'),
        PosColumn(width: 9),
        PosColumn(
          width: 2,
          text: getRightAlignedText('Page ${outerIdx + 1}', 14),
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
        PosColumn(width: 1, text: getTabs(12) + ' ' + 'UNIT'),
        PosColumn(
            width: 1, text: getTabs(10) + getRightAlignedText('PERPACK', 8)),
        PosColumn(
            width: 1, text: getTabs(10) + getRightAlignedText('PRICE', 10)),
        PosColumn(
            width: 1, text: getTabs(9) + ' ' + getRightAlignedText('QTY', 6)),
        PosColumn(width: 1, text: getTabs(7) + getRightAlignedText('FOC', 6)),
        PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('D/I', 10)),
        PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('TAX', 10)),
        PosColumn(
            width: 1, text: getTabs(5) + getRightAlignedText('AMOUNT', 10)),
        PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('LITE', 5)),
        PosColumn(width: 1),
      ]);

      bytes += generator.hr(len: 120);

      for (int listIdx = 0; listIdx < MAX_OSR_ROW_PER_PAGE; listIdx++) {
        final int currentListIdx = outerIdx * MAX_OSR_ROW_PER_PAGE + listIdx;

        if (currentListIdx >= data.orderList.length) break;

        final OrderSummanyItem orderData = data.orderList[currentListIdx];

        bytes += generator.row([
          PosColumn(width: 1, text: orderData.partNo),
          PosColumn(
            width: 1,
            textEncoded: await getThaiEncoded(orderData.description),
          ),
          PosColumn(
            width: 1,
            textEncoded:
                await getThaiEncoded(getTabs(12) + ' ' + orderData.unit),
          ),
          PosColumn(
              width: 1,
              text: getTabs(10) + getRightAlignedText(orderData.perPack, 8)),
          PosColumn(
              width: 1,
              text: getTabs(10) + getRightAlignedText(orderData.price, 10)),
          PosColumn(
              width: 1,
              text: getTabs(9) +
                  ' ' +
                  getRightAlignedText(orderData.quantity, 6)),
          PosColumn(
              width: 1,
              text: getTabs(7) + getRightAlignedText(orderData.foc, 6)),
          PosColumn(
              width: 1,
              text: getTabs(5) + getRightAlignedText(orderData.discount, 10)),
          PosColumn(
              width: 1,
              text: getTabs(5) + getRightAlignedText(orderData.tax, 10)),
          PosColumn(
              width: 1,
              text: getTabs(5) + getRightAlignedText(orderData.amount, 10)),
          PosColumn(
              width: 1,
              text: getTabs(5) + getRightAlignedText(orderData.lite, 5)),
          PosColumn(width: 1),
        ]);
      }

      if (outerIdx < totalPages - 1) {
        bytes += generator.emptyLines(10);
      } else {
        bytes += generator.hr(len: 120);

        bytes += generator.row([
          PosColumn(width: 2, text: 'Total Amount'),
          PosColumn(
            width: 1,
            text: getTabs(2) + getRightAlignedText(data.totalAmount, 12),
          ),
          PosColumn(width: 9, text: ''),
        ]);

        bytes += generator.row([
          PosColumn(width: 2, text: 'Total Lit:'),
          PosColumn(
            width: 1,
            text: getTabs(2) + getRightAlignedText(data.totalLit, 12),
          ),
          PosColumn(width: 9, text: ''),
        ]);

        bytes += generator.emptyLines(1);
        bytes += generator.text('Reference in ==>');
        bytes += generator.text('Bill');
        bytes += generator.text(data.referenceList);
        bytes += generator.text('Order');
      }
    }

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
      if (currentRow > MAX_CSR_ROW_PER_PAGE) {
        currentPage++;
        bytes += generator.emptyLines(MAX_ROW_PER_PAGE - currentRow);
        bytes += _getCsrHeader(generator, currentPage, data);
        currentRow = CSR_HEADER_ROW;
      }
    }

    bytes += _getCsrHeader(generator, currentPage, data);
    currentRow = CSR_HEADER_ROW;

    for (final stockData in data.stockList) {
      bytes += generator.row([
        PosColumn(width: 1, text: stockData.productCode),
        PosColumn(
          width: 3,
          textEncoded: await getThaiEncoded(stockData.description),
        ),
        PosColumn(width: 1, text: getRightAlignedText(stockData.perPack, 8)),
        PosColumn(
          width: 1,
          textEncoded:
              await getThaiEncoded(getRightAlignedText(stockData.unitCode, 10)),
        ),
        PosColumn(
            width: 2,
            text: getTabs(3) +
                ' ' +
                getRightAlignedText(stockData.onHandGood, 12)),
        PosColumn(
            width: 2,
            text: getTabs(2) +
                ' ' +
                getRightAlignedText(stockData.onCarGood, 12)),
        PosColumn(
            width: 1,
            text:
                getTabs(1) + ' ' + getRightAlignedText(stockData.location, 10)),
        PosColumn(width: 1),
      ]);

      currentRow++;
      _checkEndPage();
    }

    bytes += generator.hr(len: 120);

    bytes += generator.text("Total: ${data.totalRecord} Record(s)");

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
        bytes += _getRrsrFooter(generator);
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
        bytes += generator.row([
          PosColumn(width: 1, text: product.productCode),
          PosColumn(
            width: 3,
            textEncoded: await getThaiEncoded(product.description),
          ),
          PosColumn(width: 1, text: getRightAlignedText(product.perPack, 8)),
          PosColumn(
            width: 1,
            textEncoded:
                await getThaiEncoded(getRightAlignedText(product.unitCode, 10)),
          ),
          PosColumn(width: 2, text: getRightAlignedText(product.quantity, 12)),
          PosColumn(width: 4),
        ]);

        bytes += generator.hr(len: 120);

        currentRow += 2;
        await _checkEndPage();
      }
    }

    // last page's footer section
    bytes += _getRrsrFooter(generator);

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

  static List<int> _getRrsrFooter(Generator generator) {
    List<int> bytes = [];

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

    return bytes;
  }

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
