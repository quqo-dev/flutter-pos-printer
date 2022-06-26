# flutter_pos_printer_platform

A flutter plugin that prints esc commands to printers in different platforms such as android, ios, windows and different interfaces Bluetooth and BLE, TCP and USB

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```dart
import 'package:flutter_star_prnt/flutter_star_prnt.dart';

// Find printers
List<PortInfo> list = await StarPrnt.portDiscovery(StarPortType.All);

list.forEach((port) async {
/// Check status
await StarPrnt.checkStatus(portName: port.portName,emulation: 'StarGraphic',)
}

///send print commands to printer
PrintCommands commands = PrintCommands();
commands.push({
 'appendBitmapText': "Hello World"
});
commands.push({
 'appendCutPaper': "FullCutWithFeed"
});
await StarPrnt.print(portName: port.portName, emulation: 'StarGraphic',printCommands: commands)
```