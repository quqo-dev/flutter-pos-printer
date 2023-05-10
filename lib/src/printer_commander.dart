import 'dart:io';

import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/enums.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/generator.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_column.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

enum BillType { Dksh }

class PrinterCommander {
  static final printerManager = PrinterManager.instance;

  static void printBill({
    required BillType billType,
    required dynamic data,
    required BluetoothPrinter bluetoothPrinter,
  }) {
    switch (billType) {
      case BillType.Dksh:
        _printDkshBill(data, bluetoothPrinter);
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
