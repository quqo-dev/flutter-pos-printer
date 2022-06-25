#import <Flutter/Flutter.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ConnecterManager.h"

#define NAMESPACE @"flutter_pos_printer"

@interface FlutterPosPrinterPlugin : NSObject<FlutterPlugin, CBCentralManagerDelegate, CBPeripheralDelegate>
@property(nonatomic,copy)ConnectDeviceState state;
@end

@interface BluetoothPrintStreamHandler : NSObject<FlutterStreamHandler>
@property FlutterEventSink sink;
@end
