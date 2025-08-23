// services/receipt_printer_service.dart - IMPROVED VERSION with chunking support
import 'dart:convert';
import 'package:pos/models/order/order_model.dart';
import 'package:pos/screens/printer/BluetoothPrinterManager.dart';

class ReceiptPrinterService {
  static final ReceiptPrinterService _instance =
      ReceiptPrinterService._internal();
  factory ReceiptPrinterService() => _instance;
  ReceiptPrinterService._internal();

  final BluetoothPrinterManager _printerManager = BluetoothPrinterManager();

  // Add getter for connection status
  bool get isConnected => _printerManager.isConnected;

  // Add method to check printer status
  Future<bool> checkPrinterConnection() async {
    try {
      bool connected = _printerManager.isConnected;
      print('ReceiptPrinterService: Printer connection status: $connected');

      if (connected && _printerManager.selectedDevice != null) {
        print(
            'ReceiptPrinterService: Connected to ${_printerManager.selectedDevice!.platformName}');
        return true;
      }

      // Try to reconnect if not connected but has saved printer
      if (!connected && _printerManager.hasSavedPrinter()) {
        print('ReceiptPrinterService: Attempting to reconnect...');
        bool reconnected = await _printerManager.reconnect();
        print('ReceiptPrinterService: Reconnection result: $reconnected');
        return reconnected;
      }

      return false;
    } catch (e) {
      print('ReceiptPrinterService: Error checking connection: $e');
      return false;
    }
  }

  // Print receipt after successful order - IMPROVED VERSION with chunking
  Future<bool> printReceipt(OrderModel order) async {
    try {
      // Enhanced connection check with retry
      bool connectionOk = await checkPrinterConnection();

      if (!connectionOk) {
        print(
            'ReceiptPrinterService: Printer not connected or reconnection failed');
        return false;
      }

      print(
          'ReceiptPrinterService: Starting receipt print for order ${order.id}');

      // Build receipt data with better structure
      List<int> receiptData = _buildReceiptData(order);

      print(
          'ReceiptPrinterService: Receipt data built - ${receiptData.length} bytes');
      print(
          'ReceiptPrinterService: Printer max chunk size: ${_printerManager.maxChunkSize}');

      // Print with chunked method and retry logic
      bool success = false;
      int retryCount = 0;
      const maxRetries = 3;

      while (!success && retryCount < maxRetries) {
        try {
          print(
              'ReceiptPrinterService: Print attempt ${retryCount + 1}/$maxRetries');

          // Check connection before each attempt
          if (!_printerManager.isConnected) {
            print(
                'ReceiptPrinterService: Connection lost, attempting to reconnect...');
            bool reconnected = await _printerManager.reconnect();
            if (!reconnected) {
              print(
                  'ReceiptPrinterService: Reconnection failed on attempt ${retryCount + 1}');
              retryCount++;
              continue;
            }
          }

          success = await _printerManager.printData(receiptData);

          if (success) {
            print(
                'ReceiptPrinterService: Receipt printed successfully on attempt ${retryCount + 1}');
            break;
          } else {
            print(
                'ReceiptPrinterService: Print failed on attempt ${retryCount + 1}');
            retryCount++;

            // Wait before retry
            if (retryCount < maxRetries) {
              await Future.delayed(Duration(milliseconds: 1000));
            }
          }
        } catch (e) {
          print(
              'ReceiptPrinterService: Print error on attempt ${retryCount + 1}: $e');
          retryCount++;

          // Wait before retry
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(milliseconds: 1000));
          }
        }
      }

      if (success) {
        print('ReceiptPrinterService: Receipt printed successfully');
      } else {
        print(
            'ReceiptPrinterService: Failed to print receipt after $maxRetries attempts');
      }

      return success;
    } catch (e) {
      print('ReceiptPrinterService: Error printing receipt: $e');
      return false;
    }
  }

  // NEW: Separate method to build receipt data
  List<int> _buildReceiptData(OrderModel order) {
    List<int> commands = [];

    try {
      // Initialize printer with error recovery
      commands.addAll([0x1B, 0x40]); // ESC @ - Initialize printer
      commands.addAll([0x1B, 0x61, 0x01]); // Center align

      // Store header
      commands.addAll([0x1D, 0x21, 0x11]); // Double size
      String header = "Shao Kao\n";
      commands.addAll(utf8.encode(header));

      commands.addAll([0x1D, 0x21, 0x00]); // Normal size
      commands.addAll(utf8.encode("Jl. Contoh No. 123\n"));
      commands.addAll(utf8.encode("Telp: 021-1234567\n"));
      commands.addAll(utf8.encode("================================\n"));
      commands.addAll([0x1B, 0x61, 0x00]); // Left align

      // Order info with null safety
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

      // Items with null safety - build in smaller sections
      if (order.items.isNotEmpty) {
        for (var item in order.items) {
          // Build each item separately to keep chunks smaller
          List<int> itemCommands = [];
          String itemLine = "";
          itemLine += "${item.productName}\n";
          itemLine +=
              "  ${item.quantity} x ${_formatPrice(item.unitPrice.round())} = ${_formatPrice(item.totalPrice.round())}\n";

          if (item.note?.isNotEmpty == true) {
            itemLine += "  Note: ${item.note}\n";
          }

          itemCommands.addAll(utf8.encode(itemLine));
          commands.addAll(itemCommands);
        }
      }

      commands.addAll(utf8.encode("--------------------------------\n"));

      // Totals with null safety
      String totals = "";
      totals += "Subtotal: Rp${_formatPrice(order.baseAmount.round())}\n";

      totals +=
          "Pajak (${order.taxRate.round()}%): Rp${_formatPrice(order.taxAmount.round())}\n";
      totals += "--------------------------------\n";
      commands.addAll(utf8.encode(totals));

      // Total amount
      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll([0x1D, 0x21, 0x11]); // Double size
      String total = "TOTAL: Rp${_formatPrice(order.totalAmount.round())}\n";
      commands.addAll(utf8.encode(total));

      commands.addAll([0x1D, 0x21, 0x00]); // Normal size
      commands.addAll([0x1B, 0x61, 0x00]); // Left align

      // Payment method with null safety
      if (order.paymentMethods.isNotEmpty) {
        String paymentInfo = "--------------------------------\n";
        paymentInfo += "Metode Bayar: ${order.paymentMethods.first.method}\n";
        paymentInfo += "Status: ${order.paymentMethods.first.status}\n";
        commands.addAll(utf8.encode(paymentInfo));
      }

      // Notes with null safety
      if (order.notes?.isNotEmpty == true) {
        commands.addAll(utf8.encode("--------------------------------\n"));
        commands.addAll(utf8.encode("Catatan: ${order.notes}\n"));
      }

      // Footer
      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll(utf8.encode("--------------------------------\n"));
      commands.addAll(utf8.encode("Terima kasih atas kunjungan Anda\n"));
      commands.addAll(utf8.encode("Selamat menikmati!\n"));
      commands.addAll(utf8.encode("--------------------------------\n"));

      // Cut paper
      commands.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
      commands.addAll([0x1D, 0x56, 0x00]); // Cut
    } catch (e) {
      print('ReceiptPrinterService: Error building receipt data: $e');
      // Return minimal receipt on error
      commands.clear();
      commands.addAll([0x1B, 0x40]); // Initialize
      commands.addAll(utf8.encode("Print Error\n"));
      commands.addAll([0x0A, 0x0A, 0x0A]);
      commands.addAll([0x1D, 0x56, 0x00]); // Cut
    }

    return commands;
  }

  // Method to print simple test receipt
  Future<bool> testPrintReceipt() async {
    try {
      bool connectionOk = await checkPrinterConnection();

      if (!connectionOk) {
        print('ReceiptPrinterService: Printer not connected for test print');
        return false;
      }

      List<int> commands = [];

      // Initialize printer
      commands.addAll([0x1B, 0x40]); // ESC @
      commands.addAll([0x1B, 0x61, 0x01]); // Center align
      commands.addAll([0x1D, 0x21, 0x11]); // Double size

      String testText = "=== TES KONEKSI ===\n\n";
      commands.addAll(utf8.encode(testText));

      commands.addAll([0x1D, 0x21, 0x00]); // Normal size
      commands.addAll([0x1B, 0x61, 0x00]); // Left align

      String detailText = "";
      detailText += "Status: Koneksi Berhasil\n";
      detailText += "Waktu: ${_formatDateTime(DateTime.now())}\n";
      detailText += "MTU: ${_printerManager.maxChunkSize}\n";
      detailText += "Printer siap digunakan\n\n";

      commands.addAll(utf8.encode(detailText));
      commands.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
      commands.addAll([0x1D, 0x56, 0x00]); // Cut

      print(
          'ReceiptPrinterService: Test receipt data size: ${commands.length} bytes');

      bool success = await _printerManager.printData(commands);

      if (success) {
        print('ReceiptPrinterService: Test receipt printed successfully');
      } else {
        print('ReceiptPrinterService: Failed to print test receipt');
      }

      return success;
    } catch (e) {
      print('ReceiptPrinterService: Error printing test receipt: $e');
      return false;
    }
  }

  // NEW: Print receipt in smaller sections to avoid large data chunks
  Future<bool> printReceiptSectioned(OrderModel order) async {
    try {
      bool connectionOk = await checkPrinterConnection();

      if (!connectionOk) {
        print('ReceiptPrinterService: Printer not connected');
        return false;
      }

      print(
          'ReceiptPrinterService: Starting sectioned receipt print for order ${order.id}');

      // Print header section
      if (!await _printSection(_buildHeaderSection(order))) {
        return false;
      }

      // Wait between sections
      await Future.delayed(Duration(milliseconds: 100));

      // Print items section
      if (order.items.isNotEmpty) {
        for (var item in order.items) {
          if (!await _printSection(_buildItemSection(item))) {
            return false;
          }
          await Future.delayed(Duration(milliseconds: 50));
        }
      }

      // Wait between sections
      await Future.delayed(Duration(milliseconds: 100));

      // Print totals section
      if (!await _printSection(_buildTotalsSection(order))) {
        return false;
      }

      // Wait between sections
      await Future.delayed(Duration(milliseconds: 100));

      // Print footer section
      if (!await _printSection(_buildFooterSection(order))) {
        return false;
      }

      print('ReceiptPrinterService: Sectioned receipt printed successfully');
      return true;
    } catch (e) {
      print('ReceiptPrinterService: Error printing sectioned receipt: $e');
      return false;
    }
  }

  // NEW: Helper method to print individual sections
  Future<bool> _printSection(List<int> sectionData) async {
    try {
      print(
          'ReceiptPrinterService: Printing section (${sectionData.length} bytes)');
      return await _printerManager.printData(sectionData);
    } catch (e) {
      print('ReceiptPrinterService: Error printing section: $e');
      return false;
    }
  }

  // NEW: Build header section
  List<int> _buildHeaderSection(OrderModel order) {
    List<int> commands = [];

    // Initialize printer
    commands.addAll([0x1B, 0x40]); // ESC @
    commands.addAll([0x1B, 0x61, 0x01]); // Center align
    commands.addAll([0x1D, 0x21, 0x11]); // Double size

    String header = "RESTO KITA\n";
    commands.addAll(utf8.encode(header));

    commands.addAll([0x1D, 0x21, 0x00]); // Normal size
    commands.addAll(utf8.encode("Jl. Contoh No. 123\n"));
    commands.addAll(utf8.encode("Telp: 021-1234567\n"));
    commands.addAll(utf8.encode("================================\n"));
    commands.addAll([0x1B, 0x61, 0x00]); // Left align

    // Order info
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

    return commands;
  }

  // NEW: Build item section
  List<int> _buildItemSection(OrderItem item) {
    List<int> commands = [];

    String itemLine = "";
    itemLine += "${item.productName}\n";
    itemLine +=
        "  ${item.quantity} x ${_formatPrice(item.unitPrice.round())} = ${_formatPrice(item.totalPrice.round())}\n";

    if (item.note?.isNotEmpty == true) {
      itemLine += "  Note: ${item.note}\n";
    }

    commands.addAll(utf8.encode(itemLine));
    return commands;
  }

  // NEW: Build totals section
  List<int> _buildTotalsSection(OrderModel order) {
    List<int> commands = [];

    commands.addAll(utf8.encode("--------------------------------\n"));

    String totals = "";
    totals += "Subtotal: Rp${_formatPrice(order.baseAmount.round())}\n";

    totals +=
        "Pajak (${order.taxRate.round()}%): Rp${_formatPrice(order.taxAmount.round())}\n";
    totals += "--------------------------------\n";
    commands.addAll(utf8.encode(totals));

    // Total amount
    commands.addAll([0x1B, 0x61, 0x01]); // Center align
    commands.addAll([0x1D, 0x21, 0x11]); // Double size
    String total = "TOTAL: Rp${_formatPrice(order.totalAmount.round())}\n";
    commands.addAll(utf8.encode(total));

    commands.addAll([0x1D, 0x21, 0x00]); // Normal size
    commands.addAll([0x1B, 0x61, 0x00]); // Left align

    return commands;
  }

  // NEW: Build footer section
  List<int> _buildFooterSection(OrderModel order) {
    List<int> commands = [];

    // Payment method
    if (order.paymentMethods.isNotEmpty) {
      String paymentInfo = "--------------------------------\n";
      paymentInfo += "Metode Bayar: ${order.paymentMethods.first.method}\n";
      paymentInfo += "Status: ${order.paymentMethods.first.status}\n";
      commands.addAll(utf8.encode(paymentInfo));
    }

    // Notes
    if (order.notes?.isNotEmpty == true) {
      commands.addAll(utf8.encode("--------------------------------\n"));
      commands.addAll(utf8.encode("Catatan: ${order.notes}\n"));
    }

    // Footer
    commands.addAll([0x1B, 0x61, 0x01]); // Center align
    commands.addAll(utf8.encode("--------------------------------\n"));
    commands.addAll(utf8.encode("Terima kasih atas kunjungan Anda\n"));
    commands.addAll(utf8.encode("Selamat menikmati!\n"));
    commands.addAll(utf8.encode("--------------------------------\n"));

    // Cut paper
    commands.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
    commands.addAll([0x1D, 0x56, 0x00]); // Cut

    return commands;
  }

  // Get printer status info
  Map<String, dynamic> getPrinterStatus() {
    return {
      'isConnected': _printerManager.isConnected,
      'isReconnecting': _printerManager.isReconnecting,
      'selectedDevice': _printerManager.selectedDevice?.platformName,
      'deviceId': _printerManager.selectedDevice?.remoteId.toString(),
      'hasSavedPrinter': _printerManager.hasSavedPrinter(),
      'savedPrinterInfo': _printerManager.getSavedPrinterInfo(),
      'maxChunkSize': _printerManager.maxChunkSize,
    };
  }

  // Force reconnect method
  Future<bool> forceReconnect() async {
    try {
      print('ReceiptPrinterService: Force reconnecting...');
      bool success = await _printerManager.reconnect();
      print('ReceiptPrinterService: Force reconnect result: $success');
      return success;
    } catch (e) {
      print('ReceiptPrinterService: Force reconnect error: $e');
      return false;
    }
  }

  // NEW: Smart print method that chooses best approach based on data size
  Future<bool> printReceiptSmart(OrderModel order) async {
    try {
      // Build receipt data first to check size
      List<int> receiptData = _buildReceiptData(order);

      print(
          'ReceiptPrinterService: Receipt data size: ${receiptData.length} bytes');
      print(
          'ReceiptPrinterService: Printer chunk size: ${_printerManager.maxChunkSize} bytes');

      // If data is significantly larger than chunk size, use sectioned approach
      if (receiptData.length > _printerManager.maxChunkSize * 2) {
        print('ReceiptPrinterService: Using sectioned printing approach');
        return await printReceiptSectioned(order);
      } else {
        print('ReceiptPrinterService: Using chunked printing approach');
        return await printReceipt(order);
      }
    } catch (e) {
      print('ReceiptPrinterService: Error in smart print: $e');
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
