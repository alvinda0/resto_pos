import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/blocs/auth/auth_bloc.dart';
import 'package:pos/blocs/auth/auth_state.dart';
import 'package:pos/blocs/tables/tables_bloc.dart';
import 'package:pos/blocs/tables/tables_event.dart';
import 'package:pos/blocs/tables/tables_state.dart';
import 'package:pos/models/tables/model_tables.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
// Tambahkan import untuk download QR
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final TextEditingController _tableNumberController = TextEditingController();
  // GlobalKey untuk capture QR code widget
  final GlobalKey _qrGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    super.dispose();
  }

  void _loadTables() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TableBloc>().add(TableLoadRequested(token: authState.token));
    }
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Meja Baru'),
          content: TextField(
            controller: _tableNumberController,
            decoration: const InputDecoration(
              labelText: 'Nomor Meja',
              hintText: 'Masukkan nomor meja',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _tableNumberController.clear();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_tableNumberController.text.isNotEmpty) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<TableBloc>().add(
                          TableCreateRequested(
                            token: authState.token,
                            tableNumber: _tableNumberController.text,
                          ),
                        );
                  }
                  Navigator.of(context).pop();
                  _tableNumberController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(QrCodeModel table) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Meja'),
          content: Text(
              'Apakah Anda yakin ingin menghapus Meja ${table.tableNumber}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<TableBloc>().add(
                        TableDeleteRequested(
                          token: authState.token,
                          tableId: table.id,
                        ),
                      );
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showTableOptions(QrCodeModel table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width, // Force full width
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width:
              MediaQuery.of(context).size.width, // Gunakan ukuran layar penuh
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
          ),
          padding: const EdgeInsets.fromLTRB(
              20, 20, 20, 40), // Tambah bottom padding untuk safe area
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Meja ${table.tableNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showQrCode(table);
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Lihat QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(table);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus Meja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showQrCode(QrCodeModel table) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'QR Code - Meja ${table.tableNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      iconSize: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // QR Code Display dengan GlobalKey untuk capture
                RepaintBoundary(
                  key: _qrGlobalKey,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: table.menuUrl,
                      version: QrVersions.auto,
                      size: 248,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      errorStateBuilder: (cxt, err) {
                        return Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Error generating QR",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons - Ganti Share dengan Download
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _downloadQrCode(table);
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk download QR Code sebagai image
  Future<void> _downloadQrCode(QrCodeModel table) async {
    try {
      // Minta permission untuk storage
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnackBar(
              'Izin penyimpanan diperlukan untuk download', Colors.red);
          return;
        }
      }

      // Capture QR code widget sebagai image
      RenderRepaintBoundary boundary = _qrGlobalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Simpan ke galeri
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          name:
              "QR_Meja_${table.tableNumber}_${DateTime.now().millisecondsSinceEpoch}",
          quality: 100,
        );

        if (result['isSuccess'] == true) {
          _showSnackBar('QR Code berhasil disimpan ke galeri', Colors.green);
        } else {
          _showSnackBar('Gagal menyimpan QR Code', Colors.red);
        }
      }
    } catch (e) {
      print('Error downloading QR code: $e');
      _showSnackBar('Terjadi kesalahan saat download QR Code', Colors.red);
    }
  }

  // Helper method untuk menampilkan snackbar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _copyQrUrlToClipboard(String menuUrl) {
    Clipboard.setData(ClipboardData(text: menuUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu URL disalin ke clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

// Helper method for QR info rows
  Widget _buildQrInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

// Helper method to copy QR code to clipboard
  void _copyQrCodeToClipboard(String qrCode) {
    Clipboard.setData(ClipboardData(text: qrCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code disalin ke clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

// Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getLoadingText(String actionType) {
    switch (actionType) {
      case 'create':
        return 'Menambah meja...';
      case 'delete':
        return 'Menghapus meja...';
      case 'update':
        return 'Memperbarui meja...';
      default:
        return 'Memproses...';
    }
  }

  int _getOccupiedTablesCount(List<QrCodeModel> tables) {
    return tables.where((table) {
      final tableNum = int.tryParse(table.tableNumber) ?? 1;
      return _getTableStatus(tableNum) == TableStatus.occupied;
    }).length;
  }

  int _getReservedTablesCount(List<QrCodeModel> tables) {
    return tables.where((table) {
      final tableNum = int.tryParse(table.tableNumber) ?? 1;
      return _getTableStatus(tableNum) == TableStatus.reserved;
    }).length;
  }

  TableStatus _getTableStatus(int tableNumber) {
    // Simulate different statuses based on table number for demo purposes
    if (tableNumber % 3 == 0) {
      return TableStatus.occupied;
    } else if (tableNumber % 5 == 0) {
      return TableStatus.reserved;
    }
    return TableStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<TableBloc, TableState>(
        listener: (context, state) {
          if (state is TableError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TableActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manajemen Meja',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola meja restoran Anda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _loadTables,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh',
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: state is TableActionLoading
                              ? null
                              : _showAddTableDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Meja'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Stats Cards
                _buildStatsCards(state),
                const SizedBox(height: 32),

                // Tables Grid
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Layout Meja',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              if (state is TableActionLoading)
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getLoadingText(state.actionType),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _buildTablesGrid(state),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(TableState state) {
    List<QrCodeModel> tables = [];

    if (state is TableLoaded) {
      tables = state.tables;
    } else if (state is TableActionLoading) {
      tables = state.tables;
    } else if (state is TableActionSuccess) {
      tables = state.tables;
    }

    final totalTables = tables.length;
    final occupiedTables = _getOccupiedTablesCount(tables);
    final availableTables = totalTables - occupiedTables;
    final reservedTables = _getReservedTablesCount(tables);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Meja',
            totalTables.toString(),
            Icons.table_restaurant,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Meja Terisi',
            occupiedTables.toString(),
            Icons.event_seat,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Meja Kosong',
            availableTables.toString(),
            Icons.event_available,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Reservasi',
            reservedTables.toString(),
            Icons.book_online,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildTablesGrid(TableState state) {
    if (state is TableLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is TableError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data meja',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTables,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    List<QrCodeModel> tables = [];

    if (state is TableLoaded) {
      tables = state.tables;
    } else if (state is TableActionLoading) {
      tables = state.tables;
    } else if (state is TableActionSuccess) {
      tables = state.tables;
    }

    if (tables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada meja',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan meja pertama Anda',
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return _buildTableCard(tables[index]);
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(QrCodeModel table) {
    // Simulate different table statuses based on table number
    final tableNum = int.tryParse(table.tableNumber) ?? 1;
    final status = _getTableStatus(tableNum);

    Color backgroundColor;
    Color borderColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case TableStatus.occupied:
        backgroundColor = Colors.red[50]!;
        borderColor = Colors.red;
        statusText = status.displayName;
        statusIcon = Icons.event_seat;
        break;
      case TableStatus.reserved:
        backgroundColor = Colors.orange[50]!;
        borderColor = Colors.orange;
        statusText = status.displayName;
        statusIcon = Icons.book_online;
        break;
      default:
        backgroundColor = Colors.green[50]!;
        borderColor = Colors.green;
        statusText = status.displayName;
        statusIcon = Icons.event_available;
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showTableOptions(table);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                statusIcon,
                size: 32,
                color: borderColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Meja ${table.tableNumber}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: borderColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
