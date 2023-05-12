import 'dart:io';

import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/commands.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/enums.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/generator.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_column.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

import 'models/ddc_bill.dart';

enum BillType { Dksh, Ddc }

class PrinterCommander {
  static final printerManager = PrinterManager.instance;

  static void printBill({
    required BillType billType,
    required dynamic data,
    required BluetoothPrinter bluetoothPrinter,
  }) {
    switch (billType) {
      case BillType.Dksh:
        if (!(data is DkshBillModel)) {
          throw FormatException('Error. Type is invalid');
        }
        _printDkshBill(data, bluetoothPrinter);
        break;
      case BillType.Ddc:
        if (!(data is DdcBillModel)) {
          throw FormatException('Error. Type is invalid');
        }
        _printDdcBill(data, bluetoothPrinter);
        break;
      default:
        throw UnimplementedError();
    }
  }

  static void _printDkshBill(
    DkshBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'XP-N160I');

    final generator = Generator(PaperSize.mmCustom, profile);
    generator.setGlobalFont(PosFontType.fontA, maxCharsPerLine: 1000);

    bytes += generator.emptyLines(1);

    bytes += generator.row([
      PosColumn(width: 3),
      PosColumn(
        width: 9,
        text: getTabs(1) +
            data.issuedBranch +
            getTabs(4) +
            'Page ${data.page}  Time ${data.time}',
      ),
    ]);

    bytes += generator.text(getTabs(6) + data.contactInfo);

    bytes += generator.emptyLines(1);

    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 5,
        text: data.storeName,
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
        text: data.address,
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
    bytes += generator.row([
      PosColumn(width: 1),
      PosColumn(
        width: 11,
        text: 'A sample text',
      ),
    ]);

    bytes += generator.row([
      PosColumn(width: 2),
      PosColumn(
        width: 4,
        text: data.taxPayerIdNumber,
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

    for (final item in data.productList) {
      bytes += generator.row([
        PosColumn(
          width: 3,
          text: ' ${item.productCode} ${item.productList}',
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
          text:
              getTabs(2) + ' ' + getRightAlignedText(item.amountBeforeVAT, 11),
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          width: 1,
          text:
              getTabs(4) + ' ' + getRightAlignedText(item.discountBeforeVAT, 9),
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
      MAX_DKSH_ROW - data.productList.length,
    );

    // Spacing for the next row
    bytes += generator.emptyLines(1);

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
      PosColumn(width: 1),
      PosColumn(
        width: 6,
        text: data.totalMoneyByLetters,
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
        text: getTabs(6) + getRightAlignedText(data.amountSpecialDiscount, 11),
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(width: 4)
    ]);

    bytes += generator.emptyLines(2);

    bytes += generator.text(getTabs(4) + data.deliveryAt);
    bytes += generator.text(getTabs(4) + data.deliveryAddress);

    _printBluetoothEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printDdcBill(
    DdcBillModel data,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    List<int> bytes = [];

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'XP-N160I');

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
            width: 1, text: getTabs(2) + ' ' + customerPrice.customerName),
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
        PosColumn(width: 1, text: ' ' + getRightAlignedText(bill.quantity, 3)),
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

    _printBluetoothEscPos(bytes, generator, bluetoothPrinter);
  }

  static void _printBluetoothEscPos(
    List<int> bytes,
    Generator generator,
    BluetoothPrinter bluetoothPrinter,
  ) async {
    bytes += generator.cut();

    await printerManager.connect(
      type: PrinterType.bluetooth,
      model: BluetoothPrinterInput(
        name: bluetoothPrinter.deviceName,
        address: bluetoothPrinter.address!,
        isBle: bluetoothPrinter.isBle ?? false,
        autoConnect: true,
      ),
    );

    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    } else {
      throw UnsupportedError("Only available on Android device");
    }
  }
}
