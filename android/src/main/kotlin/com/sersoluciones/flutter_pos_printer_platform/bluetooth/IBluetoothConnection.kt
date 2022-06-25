package com.sersoluciones.flutter_pos_printer_platform.bluetooth
import io.flutter.plugin.common.MethodChannel.Result

interface IBluetoothConnection {
    fun connect(address: String, result: Result)
    fun stop()
    fun write(out: ByteArray?)
    var state: Int
}