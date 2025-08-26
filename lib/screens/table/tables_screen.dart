// lib/screens/qr_code_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos/controller/tables/tables_qr_code_controller.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this package
import 'package:pos/models/tables/model_tables.dart';

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QRCodeController controller = Get.put(QRCodeController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: controller.searchQRCodes,
              decoration: InputDecoration(
                hintText: 'Cari Meja',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // QR Code Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.qrCodes.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Download QR Code functionality
              Future<void> _downloadQRCode(
                  BuildContext context, QRCode qrCode, String url) async {
                try {
                  // For web/desktop - copy URL to clipboard and show QR in new dialog
                  await Clipboard.setData(ClipboardData(text: url));

                  Get.snackbar(
                    'Success',
                    'QR Code URL copied to clipboard!\nYou can take a screenshot to save the QR code.',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 4),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to copy URL: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                }
              }

              // Show fullscreen QR for screenshot
              void _showFullscreenQR(
                  BuildContext context, QRCode qrCode, String url) {
                showDialog(
                  context: context,
                  barrierColor: Colors.black87,
                  builder: (context) => Dialog.fullscreen(
                    backgroundColor: Colors.white,
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text('QR Code - Meja ${qrCode.tableNumber}'),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Large QR Code for screenshot
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'MEJA ${qrCode.tableNumber}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  QrImageView(
                                    data: url,
                                    version: QrVersions.auto,
                                    size: 400.0,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Scan untuk melihat menu',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Tip: Ambil screenshot untuk menyimpan QR Code ini\nURL sudah di-copy ke clipboard',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (controller.qrCodes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada QR Code',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + untuk menambah QR Code baru',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: controller.qrCodes.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == controller.qrCodes.length) {
                    // Add button
                    return _buildAddButton(context, controller);
                  }

                  final qrCode = controller.qrCodes[index];
                  return _buildTableItem(context, qrCode, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTableItem(
      BuildContext context, QRCode qrCode, QRCodeController controller) {
    final isExpired = controller.isExpired(qrCode);
    final completeUrl = '${qrCode.menuUrl}&table_number=${qrCode.tableNumber}';

    return GestureDetector(
      onTap: () => _showQRCodeDialog(context, qrCode, controller),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpired ? Colors.red[300]! : Colors.pink[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content - perfectly centered
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 12), // Account for delete button space
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Table Number
                    Text(
                      qrCode.tableNumber,
                      style: TextStyle(
                        fontSize: isExpired ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.red[600] : Colors.pink[600],
                      ),
                    ),

                    if (isExpired) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Expired',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Delete icon positioned at top-right
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () =>
                    _showDeleteConfirmation(context, qrCode, controller),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, QRCodeController controller) {
    return GestureDetector(
      onTap: () => _showCreateQRDialog(context, controller),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.pink[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          size: 32,
          color: Colors.pink[400],
        ),
      ),
    );
  }

  void _showQRCodeDialog(
      BuildContext context, QRCode qrCode, QRCodeController controller) {
    // Build the complete URL with table_number parameter
    final completeUrl = '${qrCode.menuUrl}&table_number=${qrCode.tableNumber}';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            // Add this line
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MEJA ${qrCode.tableNumber}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // QR Code Image
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: QrImageView(
                    data: completeUrl,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    errorStateBuilder: (cxt, err) {
                      return Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 50,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Error generating QR",
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // QR Code Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Type:', qrCode.type.toUpperCase()),
                      const SizedBox(height: 8),
                      _buildDetailRow('URL:', completeUrl),
                      const SizedBox(height: 8),
                      _buildDetailRow('Expires:',
                          controller.formatExpiryDate(qrCode.expiresAt)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Download Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => (),
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text(
                      'Download QR',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, QRCode qrCode, QRCodeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus QR Code'),
        content: Text(
            'Apakah Anda yakin ingin menghapus QR Code untuk Meja ${qrCode.tableNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteQRCode(qrCode.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showCreateQRDialog(BuildContext context, QRCodeController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat QR Code Bulk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Bulk QR Form
              _buildBulkQRForm(controller),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isCreatingQR.value
                            ? null
                            : () {
                                // Validasi tanggal sebelum membuat QR Code
                                if (controller.selectedExpiryDate.value ==
                                    null) {
                                  Get.snackbar(
                                    'Error',
                                    'Tanggal kadaluarsa wajib dipilih',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  return;
                                }
                                controller.createBulkQRCodes();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[500],
                          foregroundColor: Colors.white,
                        ),
                        child: controller.isCreatingQR.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Buat QR Code'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulkQRForm(QRCodeController controller) {
    return Column(
      children: [
        TextField(
          controller: controller.bulkStartNumberController,
          decoration: InputDecoration(
            labelText: 'Nomor Mulai',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.bulkTableCountController,
          decoration: InputDecoration(
            labelText: 'Jumlah Meja',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.menuUrlController,
          decoration: InputDecoration(
            labelText: 'Menu URL',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Expiry Date Picker (wajib - tanpa toggle)
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: controller.selectedExpiryDate.value ??
                  DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (date != null) {
              controller.setExpiryDate(date);
            }
          },
          child: Obx(() => InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal Kadaluarsa *',
                  labelStyle: TextStyle(
                    color: controller.selectedExpiryDate.value == null
                        ? Colors.red
                        : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: controller.selectedExpiryDate.value == null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: controller.selectedExpiryDate.value == null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: controller.selectedExpiryDate.value == null
                        ? Colors.red
                        : null,
                  ),
                ),
                child: Text(
                  controller.selectedExpiryDate.value != null
                      ? controller
                          .formatExpiryDate(controller.selectedExpiryDate.value)
                      : 'Pilih tanggal kadaluarsa',
                  style: TextStyle(
                    color: controller.selectedExpiryDate.value == null
                        ? Colors.red[400]
                        : Colors.black,
                  ),
                ),
              )),
        ),
        // Keterangan wajib
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '* Tanggal kadaluarsa wajib dipilih',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
