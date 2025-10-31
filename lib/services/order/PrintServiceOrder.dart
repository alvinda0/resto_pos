// services/print_service.dart - UPDATED for Multi-Printer
import 'dart:convert';
import 'package:shao_kao/models/order/new_order_model.dart';
import 'package:shao_kao/screens/printer/BluetoothPrinterManager.dart';

class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  final BluetoothPrinterManager _printerManager = BluetoothPrinterManager();

  // UPDATED: Check if ANY printer is connected
  bool get isConnected => _printerManager.connectedCount > 0;

  // UPDATED: Check printer connection for multi-printer
  Future<bool> checkPrinterConnection() async {
    try {
      bool connected = _printerManager.connectedCount > 0;
      print(
          'PrintService: Connected printers: ${_printerManager.connectedCount}');

      if (connected) {
        print(
            'PrintService: ${_printerManager.connectedCount} printer(s) ready');
        return true;
      }

      // Try to reconnect if no printers connected but has saved printers
      if (!connected && _printerManager.hasSavedPrinters()) {
        print('PrintService: Attempting to reconnect saved printers...');
        await _printerManager.initialize(); // Will auto-reconnect
        await Future.delayed(Duration(seconds: 2)); // Wait for reconnection
        bool reconnected = _printerManager.connectedCount > 0;
        print('PrintService: Reconnection result: $reconnected');
        return reconnected;
      }

      return false;
    } catch (e) {
      print('PrintService: Error checking connection: $e');
      return false;
    }
  }

  // UPDATED: Print receipt to all connected printers with role-specific content
  Future<bool> printOrderReceipt(Order order) async {
    try {
      bool connectionOk = await checkPrinterConnection();

      if (!connectionOk) {
        print('PrintService: No printer connected or reconnection failed');
        return false;
      }

      print('PrintService: Starting receipt print for order ${order.id}');

      // Prepare order data for role-specific printing
      Map<String, dynamic> orderData = {
        'displayId': order.id.substring(0, 8).toUpperCase(),
        'date': _formatDateTime(order.createdAt),
        'customerName': order.customerName ?? 'N/A',
        'customerPhone': order.customerPhone ?? '',
        'tableNumber': (order.tableNumber ?? 0).toString(),
        'status': 'Order Receipt',
        'dishStatus': 'N/A',
        'notes': order.notes,
        'formattedTotal': 'Rp${_formatPrice((order.totalAmount ?? 0.0).round())}',
        'items': (order.items ?? []).map((item) => {
          'productName': item.productName ?? 'Unknown Item',
          'quantity': item.quantity ?? 1,
          'unitPrice': item.unitPrice ?? 0.0,
          'note': item.note,
        }).toList(),
      };

      // Print ONLY to admin printer for customer receipt
      Map<String, bool> results = {};
      
      print('PrintService: ===== DEBUGGING PRINT CALL =====');
      print('PrintService: About to call printToRoleWithContent for ADMIN ONLY');
      print('PrintService: Connected printers: ${_printerManager.connectedCount}');
      print('PrintService: Available printer roles: ${_printerManager.printers.keys.toList()}');
      
      bool adminSuccess = await _printerManager.printToRoleWithContent('admin', orderData);
      results['admin'] = adminSuccess;
      
      print('PrintService: Admin printer result: $adminSuccess');
      print('PrintService: ===== END DEBUGGING PRINT CALL =====');

      // Check admin printer result
      bool success = results['admin'] ?? false;

      if (success) {
        print('PrintService: Customer receipt printed to admin printer successfully');
      } else {
        print('PrintService: Failed to print customer receipt to admin printer');
      }

      return success;
    } catch (e) {
      print('PrintService: Error printing order receipt: $e');
      return false;
    }
  }

  // Existing _buildReceiptData stays the same
  List<int> _buildReceiptData(Order order) {
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
      orderInfo += "Order ID: ${order.id.substring(0, 8).toUpperCase()}\n";
      orderInfo += "Tanggal: ${_formatDateTime(order.createdAt)}\n";
      orderInfo += "Customer: ${order.customerName ?? 'N/A'}\n";

      if (order.customerPhone?.isNotEmpty == true) {
        orderInfo += "No. HP: ${order.customerPhone}\n";
      }

      orderInfo += "No. Meja: ${order.tableNumber ?? 0}\n";
      orderInfo += "--------------------------------\n";
      commands.addAll(utf8.encode(orderInfo));

      if (order.items != null && order.items.isNotEmpty) {
        for (var item in order.items) {
          String itemLine = "";
          itemLine += "${item.productName ?? 'Unknown Item'}\n";
          itemLine +=
              "  ${item.quantity ?? 1} x ${_formatPrice((item.unitPrice ?? 0.0).round())} = ${_formatPrice((item.totalPrice ?? 0.0).round())}\n";

          if (item.note?.isNotEmpty == true) {
            itemLine += "  Note: ${item.note}\n";
          }

          commands.addAll(utf8.encode(itemLine));
        }
      }

      commands.addAll(utf8.encode("--------------------------------\n"));

      String totals = "";
      totals +=
          "Subtotal: Rp${_formatPrice((order.baseAmount ?? 0.0).round())}\n";

      if ((order.discountAmount ?? 0.0) > 0) {
        totals +=
            "Diskon: -Rp${_formatPrice((order.discountAmount ?? 0.0).round())}\n";
      }

      totals +=
          "Pajak (${(order.taxRate ?? 0.0).round()}%): Rp${_formatPrice((order.taxAmount ?? 0.0).round())}\n";
      totals += "--------------------------------\n";
      commands.addAll(utf8.encode(totals));

      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll([0x1D, 0x21, 0x11]); // Double size
      String total =
          "TOTAL: Rp${_formatPrice((order.totalAmount ?? 0.0).round())}\n";
      commands.addAll(utf8.encode(total));

      commands.addAll([0x1D, 0x21, 0x00]); // Normal size
      commands.addAll([0x1B, 0x61, 0x00]); // Left align

      if (order.paymentMethods?.isNotEmpty == true) {
        String paymentInfo = "--------------------------------\n";
        paymentInfo +=
            "Metode Bayar: ${order.paymentMethods!.first.method ?? 'N/A'}\n";
        paymentInfo +=
            "Status: ${order.paymentMethods!.first.status ?? 'N/A'}\n";
        commands.addAll(utf8.encode(paymentInfo));
      }

      if (order.notes?.isNotEmpty == true) {
        commands.addAll(utf8.encode("--------------------------------\n"));
        commands.addAll(utf8.encode("Catatan: ${order.notes}\n"));
      }

      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll(utf8.encode("--------------------------------\n"));
      commands.addAll(utf8.encode("Terima Kasih!\n"));
      commands.addAll(utf8.encode("Selamat Menikmati\n"));
      commands.addAll(utf8.encode("--------------------------------\n"));

      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]); // Cut
    } catch (e) {
      print('PrintService: Error building receipt data: $e');
      commands.clear();
      commands.addAll([0x1B, 0x40]);
      commands.addAll(utf8.encode("Print Error\n"));
      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]);
    }

    return commands;
  }

  // UPDATED: Print test receipt to all printers
  Future<bool> printTestReceipt() async {
    try {
      bool connectionOk = await checkPrinterConnection();

      if (!connectionOk) {
        print('PrintService: No printer connected for test print');
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

      print('PrintService: Test receipt data size: ${commands.length} bytes');

      // Print test receipt ONLY to admin printer
      print('PrintService: Printing test receipt to admin printer only');
      bool adminSuccess = await _printerManager.printToRole('admin', commands);
      
      print('PrintService: Admin test print result: $adminSuccess');

      if (adminSuccess) {
        print('PrintService: Test receipt printed to admin printer successfully');
      } else {
        print('PrintService: Failed to print test receipt to admin printer');
      }

      bool success = adminSuccess;

      return success;
    } catch (e) {
      print('PrintService: Error printing test receipt: $e');
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

  // UPDATED: Force reconnect all saved printers
  Future<bool> forceReconnect() async {
    try {
      print('PrintService: Force reconnecting all printers...');
      await _printerManager.initialize();
      await Future.delayed(Duration(seconds: 2));
      bool success = _printerManager.connectedCount > 0;
      print(
          'PrintService: Force reconnect result: $success (${_printerManager.connectedCount} connected)');
      return success;
    } catch (e) {
      print('PrintService: Force reconnect error: $e');
      return false;
    }
  }

  // OPTIONAL: Print to specific printer role
  Future<bool> printToSpecificPrinter(Order order, String role) async {
    try {
      if (!_printerManager.isRoleConnected(role)) {
        print('PrintService: Printer role $role not connected');
        return false;
      }

      List<int> receiptData = _buildReceiptData(order);
      bool success = await _printerManager.printToRole(role, receiptData);

      print('PrintService: Print to $role result: $success');
      return success;
    } catch (e) {
      print('PrintService: Error printing to $role: $e');
      return false;
    }
  }

  String _formatPrice(int price) {
    try {
      return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    } catch (e) {
      print('Error formatting price: $e');
      return price.toString();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    try {
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      print('Error formatting datetime: $e');
      return dateTime.toString();
    }
  }
}
