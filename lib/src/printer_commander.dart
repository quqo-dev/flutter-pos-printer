import 'dart:io';
import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/commands.dart';
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
 */
enum BillType { Dksh, Ddc, Dssr, Cclr, Btr, Btl, Osr, Csr }

const int MAX_BILLING_PRODUCT_LIST_ROW = 8;
const int MAX_ADDRESS_CHAR_PER_ROW = 40;

class PrinterCommander {
  static final printerManager = PrinterManager.instance;

  static void printBill({
    required BillType billType,
    required dynamic data,
    required BluetoothPrinter bluetoothPrinter,
  }) async {
    List<int> bytes = [];
    late Generator generator;

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    switch (billType) {
      case BillType.Dksh:
        if (data is! DkshBillModel) {
          throw FormatException('Error! Type must be DkshBillModel');
        }

        generator = Generator(PaperSize.mmCustom, profile);
        generator.setGlobalFont(PosFontType.fontA, maxCharsPerLine: 1000);

        final int pages =
            data.productList.length ~/ MAX_BILLING_PRODUCT_LIST_ROW +
                (data.productList.length % MAX_BILLING_PRODUCT_LIST_ROW != 0
                    ? 1
                    : 0);

        bytes = await _getDkshBillingContent(pages, generator, data);

        break;
      case BillType.Ddc:
        if (data is! DdcBillModel) {
          throw FormatException('Error! Type must be DdcBillModel');
        }
        _printDdcBill(data, bluetoothPrinter);
        break;
      case BillType.Dssr:
        if (data is! DssrBillModel) {
          throw FormatException('Error! Type must be DssrBillModel');
        }
        _printDssrBill(data, bluetoothPrinter);
        break;
      case BillType.Cclr:
        if (data is! CclrBillModel) {
          throw FormatException('Error! Type must be CclrBillModel');
        }
        _printCclrBill(data, bluetoothPrinter);
        break;
      case BillType.Btr:
        if (data is! BtrBillModel) {
          throw FormatException('Error! Type must be BtrBillModel');
        }
        _printBtrBill(data, bluetoothPrinter);
        break;
      case BillType.Btl:
        if (data is! BtlBillModel) {
          throw FormatException('Error! Type must be BtlBillModel');
        }
        _printBtlBill(data, bluetoothPrinter);
        break;
      case BillType.Osr:
        if (data is! OsrBillModel) {
          throw FormatException('Error! Type must be OsrBillModel');
        }
        _printOsrBill(data, bluetoothPrinter);
        break;
      case BillType.Csr:
        if (data is! CsrBillModel) {
          throw FormatException('Error! Type must be CsrBillModel');
        }
        _printCsrBill(data, bluetoothPrinter);
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
      bytes += cSmallLineSpace.codeUnits;

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

      for (int listIdx = 0; listIdx < MAX_BILLING_PRODUCT_LIST_ROW; listIdx++) {
        final int currentListIdx =
            outerIdx * MAX_BILLING_PRODUCT_LIST_ROW + listIdx;

        if (currentListIdx >= data.productList.length) break;

        currentListItem++;
        final DkshProductModel item = data.productList[currentListIdx];

        bytes += generator.row([
          PosColumn(
            width: 3,
            textEncoded: await getThaiEncoded(
                ' ${item.productCode} ${item.productList}'),
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            width: 1,
            text: getTabs(5) + ' ' + item.soldAmount,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            width: 1,
            text: getTabs(4) + ' ' + item.freeAmount,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            width: 1,
            text: getTabs(2) +
                ' ' +
                getRightAlignedText(item.amountBeforeVAT, 11),
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            width: 1,
            text: getTabs(4) +
                ' ' +
                getRightAlignedText(item.discountBeforeVAT, 9),
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            width: 1,
            text: getTabs(6) + getRightAlignedText(item.amountAfterVAT, 11),
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            width: 1,
            text: getTabs(8) + getRightAlignedText(item.pricePerCanAfterVAT, 7),
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(width: 3)
        ]);
      }

      // The rest empty lines of table
      bytes += generator.emptyLines(
        MAX_BILLING_PRODUCT_LIST_ROW - currentListItem,
      );

      // Spacing for the next row
      bytes += generator.emptyLines(1);
      bytes += cSmallLineSpace.codeUnits;

      bytes += generator.row([
        PosColumn(width: 7),
        PosColumn(
          width: 1,
          text: getTabs(6) + getRightAlignedText(data.netSalesAfterVAT, 11),
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(width: 4)
      ]);

      bytes += generator.emptyLines(1);

      bytes += generator.row([
        PosColumn(
          width: 7,
          textEncoded:
              await getThaiEncoded(getTabs(1) + data.totalMoneyByLetters),
        ),
        PosColumn(
          width: 1,
          text: getTabs(6) + getRightAlignedText(data.netSalesBeforeVAT, 11),
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(width: 4)
      ]);

      bytes += generator.emptyLines(1);

      bytes += generator.row([
        PosColumn(width: 6),
        PosColumn(
          width: 1,
          text: getTabs(6) + data.percentVAT,
        ),
        PosColumn(
          width: 1,
          text: getTabs(6) + getRightAlignedText(data.amountVAT, 11),
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(width: 4)
      ]);

      bytes += generator.emptyLines(1);

      bytes += generator.row([
        PosColumn(width: 6),
        PosColumn(
          width: 1,
          text: getTabs(6) + data.percentSpecialDiscount,
        ),
        PosColumn(
          width: 1,
          text:
              getTabs(6) + getRightAlignedText(data.amountSpecialDiscount, 11),
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(width: 4)
      ]);

      bytes += generator.emptyLines(2);

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

  static void _printDdcBill(
    DdcBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 1000,
      isSmallFont: true,
    );

    bytes += generator.emptyLines(1);

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
    bytes += generator.text(
        'CASH SALES   - Running Number FORM-USAGE FROM.................. TO .................. TOTAL...... BILL(S)');
    bytes += generator.text(
        '             - Running Number FORM-CANCELATION NO.................................... TOTAL...... BILL(S)');
    bytes += generator.text(
        'CREDIT SALES - Running Number FORM-USAGE FROM.................. TO .................. TOTAL...... BILL(S)');
    bytes += generator.text(
        '             - Running Number FORM-CANCELATION NO.................................... TOTAL...... BILL(S)');
    bytes += generator.text(
        'NOTE: THE RUNNING NUMBER FROM IS AT THE RIGHT BOTTOM OF INVOICE');

    bytes += generator.hr(len: 120);

    bytes += generator.text(
        'Collection Sheet.............A' + getTabs(2) + 'Text.............A');
    bytes += generator.text(
        'Sample text.............text.............text.............A Text.............text   Sample text.............bath');
    bytes += generator.text(
        'Sample text.............text.............text.............A Text.............text');
    bytes +=
        generator.text('Sample text.............Sample text.............bath');
    bytes += generator.text(
        'Sample text.............Sample text.............bath Sample text.............bath Sample text.............');

    bytes += generator.hr(len: 120);

    bytes += generator.text('Total balance  ${data.totalBalance}  bath');
    bytes += generator.text('Total cash balance  ${data.totalCashBalance}  bath' +
        getTabs(2) +
        'Cash payment........................................................bath');
    bytes += generator.text('Total credit balance  ${data.creditBalance}  bath' +
        getTabs(2) +
        'Credit card payment slip amount........  Leaves value...............bath');
    bytes += generator.text(
        'Pay by............................  Get paid by............................');

    bytes += generator.hr(len: 120);

    _printEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printDssrBill(
    DssrBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 1000,
      isSmallFont: true,
    );

    bytes += generator.emptyLines(1);

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

    // 1st table
    for (final stock in data.stockList) {
      Uint8List encThai = await CharsetConverter.encode(
        'TIS-620',
        stock.name,
      );

      bytes += generator.row([
        PosColumn(width: 1, text: stock.id),
        PosColumn(width: 2, textEncoded: encThai),
        PosColumn(
          width: 9,
          text: getTabs(5) +
              ' ' +
              getRightAlignedText(stock.wh, 6) +
              getRightAlignedText(stock.perPack, 5) +
              getRightAlignedText(stock.openBal, 6) +
              getRightAlignedText(stock.sale, 6) +
              getRightAlignedText(stock.goodsReturn, 8) +
              getRightAlignedText(stock.transfIn, 7) +
              getRightAlignedText(stock.transfOut, 7) +
              getRightAlignedText(stock.focX, 5) +
              getRightAlignedText(stock.focY, 5) +
              getRightAlignedText(stock.closeBal, 6) +
              getRightAlignedText(stock.onhand, 6),
        ),
      ]);
    }

    bytes += generator.hr(len: 120, ch: '=');

    bytes += generator.text('NO OF PRODUCT : ${data.total} LIST');

    bytes += generator.hr(len: 120, ch: '=');

    _printEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printCclrBill(
    CclrBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 1000,
      isSmallFont: true,
    );

    bytes += generator.emptyLines(1);

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

    for (final callingItem in data.callingList) {
      bytes += generator.row([
        PosColumn(width: 1, text: callingItem.date),
        PosColumn(width: 1, text: getTabs(1) + callingItem.custCode),
        PosColumn(
          width: 4,
          textEncoded: await getThaiEncoded(getTabs(1) + callingItem.custName),
        ),
        PosColumn(
          width: 2,
          textEncoded: await getThaiEncoded(getTabs(1) + callingItem.reason),
        ),
        PosColumn(
          width: 2,
          textEncoded:
              await getThaiEncoded(getTabs(2) + callingItem.typeOfShop),
        ),
        PosColumn(width: 2, text: getTabs(3) + ' ' + callingItem.time),
      ]);
    }

    bytes += generator.hr(len: 120, ch: '=');

    bytes += generator.text('Total ${data.total}');

    bytes += generator.hr(len: 120, ch: '=');

    bytes += generator.text('Grand Total ${data.grandTotal}');

    _printEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printBtrBill(
    BtrBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 1000,
      isSmallFont: true,
    );

    bytes += generator.emptyLines(1);

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
        text: getTabs(20) + 'BILL TRANSACTION REPORT',
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
      PosColumn(width: 1, text: ' ' + 'EFF. DATE'),
      PosColumn(width: 1, text: getTabs(1) + ' ' + 'CRT. DATE'),
      PosColumn(width: 1, text: getTabs(2) + ' ' + 'CUST. NAME'),
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
      PosColumn(width: 1, text: ' ' + 'NAME'),
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

    for (final transaction in data.transactionList) {
      bytes += generator.row([
        PosColumn(width: 1, text: transaction.firstRowData.noProduct),
        PosColumn(width: 1, text: ' ' + transaction.firstRowData.effectiveDate),
        PosColumn(
            width: 1,
            text: getTabs(1) + ' ' + transaction.firstRowData.createdDate),
        PosColumn(
          width: 1,
          textEncoded: await getThaiEncoded(
              getTabs(2) + ' ' + transaction.firstRowData.customerName),
        ),
        PosColumn(width: 1),
        PosColumn(
            width: 1,
            text: getTabs(5) +
                getRightAlignedText(transaction.firstRowData.price, 8)),
        PosColumn(
            width: 1,
            text: getTabs(5) +
                getRightAlignedText(transaction.firstRowData.discount, 8)),
        PosColumn(
            width: 1,
            text: getTabs(5) +
                getRightAlignedText(
                    transaction.firstRowData.deliveryOrderFee, 8)),
        PosColumn(
            width: 1,
            text: getTabs(4) +
                ' ' +
                getRightAlignedText(transaction.firstRowData.tax, 7)),
        PosColumn(
            width: 1,
            text: getTabs(4) +
                getRightAlignedText(transaction.firstRowData.total, 8)),
        PosColumn(
            width: 2,
            text: getTabs(3) +
                ' ' +
                getRightAlignedText(transaction.firstRowData.sts, 8)),
      ]);

      for (final tableItem in transaction.tableData) {
        bytes += generator.row([
          PosColumn(width: 1, text: tableItem.product),
          PosColumn(
            width: 1,
            textEncoded: await getThaiEncoded(' ' + tableItem.name),
          ),
          PosColumn(width: 1),
          PosColumn(width: 1),
          PosColumn(
              width: 1,
              text: getTabs(3) +
                  getRightAlignedText(tableItem.pack, 5) +
                  getTabs(1) +
                  getRightAlignedText(tableItem.order, 5)),
          PosColumn(
              width: 1,
              text: getTabs(5) + getRightAlignedText(tableItem.foc, 8)),
          PosColumn(
              width: 1,
              text:
                  getTabs(5) + getRightAlignedText(tableItem.pricePerUnit, 8)),
          PosColumn(
              width: 1,
              text: getTabs(5) + getRightAlignedText(tableItem.price, 8)),
          PosColumn(
              width: 1,
              text: getTabs(4) +
                  ' ' +
                  getRightAlignedText(tableItem.percentDiscount, 7)),
          PosColumn(
              width: 1,
              text: getTabs(4) + getRightAlignedText(tableItem.discount, 8)),
          PosColumn(
              width: 2,
              text: getTabs(3) + ' ' + getRightAlignedText(tableItem.total, 8)),
        ]);
      }

      bytes += generator.hr(len: 120);
    }

    bytes += generator.row([
      PosColumn(width: 1, text: 'TOTAL ==>'),
      PosColumn(width: 4),
      PosColumn(
          width: 1,
          text: getTabs(5) + getRightAlignedText(data.totalRow.price, 8)),
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

    _printEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printBtlBill(
    BtlBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 1000,
      isSmallFont: true,
    );

    bytes += generator.emptyLines(1);

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
        text: getTabs(23) + 'No. ${data.reportNo}',
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

    for (final transferData in data.transferList) {
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
            text:
                getTabs(3) + ' ' + getRightAlignedText(transferData.status, 8)),
        PosColumn(width: 1),
      ]);
    }

    bytes += generator.hr(len: 120);

    bytes += generator.row([
      PosColumn(width: 1, text: 'Total ${data.totalRecord} Record(s)'),
      PosColumn(width: 8, text: ''),
      PosColumn(
          width: 1,
          text: getTabs(5) + ' ' + getRightAlignedText(data.totalAmount, 10)),
      PosColumn(width: 2, text: ''),
    ]);

    bytes += generator.hr(len: 120);

    _printEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printOsrBill(
    OsrBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 1000,
      isSmallFont: true,
    );

    bytes += generator.emptyLines(1);

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
      PosColumn(width: 1, text: getTabs(10) + getRightAlignedText('PRICE', 10)),
      PosColumn(
          width: 1, text: getTabs(9) + ' ' + getRightAlignedText('QTY', 6)),
      PosColumn(width: 1, text: getTabs(7) + getRightAlignedText('FOC', 6)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('D/I', 10)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('TAX', 10)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('AMOUNT', 10)),
      PosColumn(width: 1, text: getTabs(5) + getRightAlignedText('LITE', 5)),
      PosColumn(width: 1),
    ]);

    bytes += generator.hr(len: 120);

    for (final orderData in data.orderList) {
      bytes += generator.row([
        PosColumn(width: 1, text: orderData.partNo),
        PosColumn(
          width: 1,
          textEncoded: await getThaiEncoded(orderData.description),
        ),
        PosColumn(
          width: 1,
          textEncoded: await getThaiEncoded(getTabs(12) + ' ' + orderData.unit),
        ),
        PosColumn(
            width: 1,
            text: getTabs(10) + getRightAlignedText(orderData.perPack, 8)),
        PosColumn(
            width: 1,
            text: getTabs(10) + getRightAlignedText(orderData.price, 10)),
        PosColumn(
            width: 1,
            text:
                getTabs(9) + ' ' + getRightAlignedText(orderData.quantity, 6)),
        PosColumn(
            width: 1, text: getTabs(7) + getRightAlignedText(orderData.foc, 6)),
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
    bytes += generator.emptyLines(1);
    bytes += generator.text('Order');

    _printEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printCsrBill(
    CsrBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter default
    final profile = await CapabilityProfile.load(name: 'default');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(
      PosFontType.fontA,
      maxCharsPerLine: 1000,
      isSmallFont: true,
    );

    bytes += generator.emptyLines(1);

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
    }

    bytes += generator.hr(len: 120);

    bytes += generator.text("Total: ${data.totalRecord} Record(s)");

    _printEscPos(bytes, generator, bluetoothPrinter);
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
