// services/receipt_printer_service.dart - UPDATED for Multi-Printer
import 'dart:convert';
import 'package:shao_kao/models/order/order_model.dart';
import 'package:shao_kao/screens/printer/BluetoothPrinterManager.dart';

class ReceiptPrinterService {
  static final ReceiptPrinterService _instance =
      ReceiptPrinterService._internal();
  factory ReceiptPrinterService() => _instance;
  ReceiptPrinterService._internal();

  final BluetoothPrinterManager _printerManager = BluetoothPrinterManager();

  // UPDATED: Check if ANY printer is connected
  bool get isConnected => _printerManager.connectedCount > 0;

  // UPDATED: Check printer connection for multi-printer
  Future<bool> checkPrinterConnection() async {
    try {
      bool connected = _printerManager.connectedCount > 0;
      print(
          'ReceiptPrinterService: Connected printers: ${_printerManager.connectedCount}');

      if (connected) {
        print(
            'ReceiptPrinterService: ${_printerManager.connectedCount} printer(s) ready');
        return true;
      }

      // Try to reconnect if no printers connected but has saved printers
      if (!connected && _printerManager.hasSavedPrinters()) {
        print(
            'ReceiptPrinterService: Attempting to reconnect saved printers...');
        await _printerManager.initialize();
        await Future.delayed(Duration(seconds: 2));
        bool reconnected = _printerManager.connectedCount > 0;
        print('ReceiptPrinterService: Reconnection result: $reconnected');
        return reconnected;
      }

      return false;
    } catch (e) {
      print('ReceiptPrinterService: Error checking connection: $e');
      return false;
    }
  }

  // UPDATED: Print receipt to all connected printers
  Future<bool> printReceipt(OrderModel order) async {
    try {
      bool connectionOk = await checkPrinterConnection();

      if (!connectionOk) {
        print(
            'ReceiptPrinterService: No printer connected or reconnection failed');
        return false;
      }

      print(
          'ReceiptPrinterService: Starting receipt print for order ${order.id}');

      // Build receipt data
      List<int> receiptData = _buildReceiptData(order);
      print(
          'ReceiptPrinterService: Receipt data built - ${receiptData.length} bytes');

      // Print to ALL connected printers
      Map<String, bool> results = await _printerManager.printToAll(receiptData);

      // Check results
      int successCount = results.values.where((v) => v).length;
      int totalPrinters = results.length;

      print(
          'ReceiptPrinterService: Print result: $successCount/$totalPrinters printers succeeded');

      bool success = successCount > 0;

      if (success) {
        print(
            'ReceiptPrinterService: Receipt printed to $successCount printer(s)');
      } else {
        print('ReceiptPrinterService: Failed to print to any printer');
      }

      return success;
    } catch (e) {
      print('ReceiptPrinterService: Error printing receipt: $e');
      return false;
    }
  }

  // Existing _buildReceiptData stays the same
  List<int> _buildReceiptData(OrderModel order) {
    List<int> commands = [];

    try {
      commands.addAll([0x1B, 0x40]); // Initialize
      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll([0x1D, 0x21, 0x11]); // Double size

      String header = "Shao Kao\n";
      commands.addAll(utf8.encode(header));

      commands.addAll([0x1D, 0x21, 0x00]); // Normal size
      commands.addAll(utf8.encode("Jl. Contoh No. 123\n"));
      commands.addAll(utf8.encode("Telp: 021-1234567\n"));
      commands.addAll(utf8.encode("================================\n"));
      commands.addAll([0x1B, 0x61, 0x00]); // Left align

      String orderInfo = "";
      orderInfo += "Order ID: ${order.displayId}\n";
      orderInfo += "Tanggal: ${_formatDateTime(order.createdAt)}\n";
      orderInfo += "Customer: ${order.customerName}\n";

      if (order.customerPhone.isNotEmpty) {
        orderInfo += "No. HP: ${order.customerPhone}\n";
      }

      orderInfo += "No. Meja: ${order.tableNumber}\n";
      orderInfo += "Status: ${order.status}\n";
      orderInfo += "--------------------------------\n";

      commands.addAll(utf8.encode(orderInfo));

      if (order.items.isNotEmpty) {
        for (var item in order.items) {
          String itemLine = "";
          itemLine += "${item.productName}\n";
          itemLine +=
              "  ${item.quantity} x ${_formatPrice(item.unitPrice.round())} = ${_formatPrice(item.totalPrice.round())}\n";

          if (item.note?.isNotEmpty == true) {
            itemLine += "  Note: ${item.note}\n";
          }

          commands.addAll(utf8.encode(itemLine));
        }
      }

      commands.addAll(utf8.encode("--------------------------------\n"));

      String totals = "";
      totals += "Subtotal: Rp${_formatPrice(order.baseAmount.round())}\n";
      totals +=
          "Pajak (${order.taxRate.round()}%): Rp${_formatPrice(order.taxAmount.round())}\n";
      totals += "--------------------------------\n";
      commands.addAll(utf8.encode(totals));

      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll([0x1D, 0x21, 0x11]); // Double size
      String total = "TOTAL: Rp${_formatPrice(order.totalAmount.round())}\n";
      commands.addAll(utf8.encode(total));

      commands.addAll([0x1D, 0x21, 0x00]); // Normal size
      commands.addAll([0x1B, 0x61, 0x00]); // Left align

      if (order.paymentMethods.isNotEmpty) {
        String paymentInfo = "--------------------------------\n";
        paymentInfo += "Metode Bayar: ${order.paymentMethods.first.method}\n";
        paymentInfo += "Status: ${order.paymentMethods.first.status}\n";
        commands.addAll(utf8.encode(paymentInfo));
      }

      if (order.notes?.isNotEmpty == true) {
        commands.addAll(utf8.encode("--------------------------------\n"));
        commands.addAll(utf8.encode("Catatan: ${order.notes}\n"));
      }

      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll(utf8.encode("--------------------------------\n"));
      commands.addAll(utf8.encode("Terima kasih atas kunjungan Anda\n"));
      commands.addAll(utf8.encode("Selamat menikmati!\n"));
      commands.addAll(utf8.encode("--------------------------------\n"));

      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]); // Cut
    } catch (e) {
      print('ReceiptPrinterService: Error building receipt data: $e');
      commands.clear();
      commands.addAll([0x1B, 0x40]);
      commands.addAll(utf8.encode("Print Error\n"));
      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]);
    }

    return commands;
  }

  // UPDATED: Test print to all printers
  Future<bool> testPrintReceipt() async {
    try {
      bool connectionOk = await checkPrinterConnection();

      if (!connectionOk) {
        print('ReceiptPrinterService: No printer connected for test print');
        return false;
      }

      List<int> commands = [];

      commands.addAll([0x1B, 0x40]);
      commands.addAll([0x1B, 0x61, 0x01]);
      commands.addAll([0x1D, 0x21, 0x11]);

      String testText = "=== TES KONEKSI ===\n\n";
      commands.addAll(utf8.encode(testText));

      commands.addAll([0x1D, 0x21, 0x00]);
      commands.addAll([0x1B, 0x61, 0x00]);

      String detailText = "";
      detailText += "Status: Koneksi Berhasil\n";
      detailText += "Waktu: ${_formatDateTime(DateTime.now())}\n";
      detailText += "Connected: ${_printerManager.connectedCount} printer(s)\n";
      detailText += "Printer siap digunakan\n\n";

      commands.addAll(utf8.encode(detailText));
      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]);

      print(
          'ReceiptPrinterService: Test receipt data size: ${commands.length} bytes');

      Map<String, bool> results = await _printerManager.printToAll(commands);
      int successCount = results.values.where((v) => v).length;

      bool success = successCount > 0;

      if (success) {
        print(
            'ReceiptPrinterService: Test receipt printed to $successCount printer(s)');
      } else {
        print('ReceiptPrinterService: Failed to print test receipt');
      }

      return success;
    } catch (e) {
      print('ReceiptPrinterService: Error printing test receipt: $e');
      return false;
    }
  }

  // UPDATED: Get printer status info for multi-printer
  Map<String, dynamic> getPrinterStatus() {
    Map<String, PrinterInfo> printers = _printerManager.printers;

    return {
      'connectedCount': _printerManager.connectedCount,
      'totalPrinters': printers.length,
      'printers': printers.map((role, info) => MapEntry(role, {
            'role': info.role,
            'name': info.name,
            'connected': info.isConnected,
            'deviceName': info.device?.platformName,
            'deviceId': info.id,
          })),
      'hasSavedPrinters': _printerManager.hasSavedPrinters(),
      'savedPrintersInfo': _printerManager.getSavedPrintersInfo(),
    };
  }

  // UPDATED: Force reconnect all printers
  Future<bool> forceReconnect() async {
    try {
      print('ReceiptPrinterService: Force reconnecting all printers...');
      await _printerManager.initialize();
      await Future.delayed(Duration(seconds: 2));
      bool success = _printerManager.connectedCount > 0;
      print(
          'ReceiptPrinterService: Force reconnect result: $success (${_printerManager.connectedCount} connected)');
      return success;
    } catch (e) {
      print('ReceiptPrinterService: Force reconnect error: $e');
      return false;
    }
  }

  // OPTIONAL: Print to specific printer role
  Future<bool> printToSpecificPrinter(OrderModel order, String role) async {
    try {
      if (!_printerManager.isRoleConnected(role)) {
        print('ReceiptPrinterService: Printer role $role not connected');
        return false;
      }

      List<int> receiptData = _buildReceiptData(order);
      bool success = await _printerManager.printToRole(role, receiptData);

      print('ReceiptPrinterService: Print to $role result: $success');
      return success;
    } catch (e) {
      print('ReceiptPrinterService: Error printing to $role: $e');
      return false;
    }
  }

  String _formatPrice(int price) {
    try {
      return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    } catch (e) {
      print('ReceiptPrinterService: Error formatting price: $e');
      return price.toString();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    try {
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      print('ReceiptPrinterService: Error formatting datetime: $e');
      return dateTime.toString();
    }
  }

  // Legacy helper methods for backward compatibility
  String _formatCurrency(double amount) {
    return "Rp${_formatPrice(amount.round())}";
  }

  String _padRight(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text + ' ' * (width - text.length);
  }

  String _padLeft(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return ' ' * (width - text.length) + text;
  }

  // Check printer connection status
  bool get isBluetoothSupported => _printerManager.isBluetoothSupported;

  // Get printer manager instance for setup
  BluetoothPrinterManager get printerManager => _printerManager;
}
