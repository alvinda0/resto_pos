import 'dart:convert'; // Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/referral/referral_controller.dart';
import 'package:pos/controller/customer/customer_controller.dart'; // Add this import
import 'package:pos/models/referral/referral_model.dart';
import 'package:pos/widgets/pagination_widget.dart';

class ReferralScreen extends StatefulWidget {
  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ReferralController _referralController = Get.put(ReferralController());
  final CustomerController _customerController =
      Get.put(CustomerController()); // Add this line

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<ReferralModel> _getFilteredReferrals() {
    if (_searchQuery.isEmpty) {
      return _referralController.referrals;
    }
    return _referralController.filterByCustomerName(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama customer...',
                        hintStyle:
                            TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[500], size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Filter button
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_alt_outlined,
                        color: Colors.grey[600], size: 20),
                    onPressed: () {
                      // TODO: Implement filter functionality
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Grid view button
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.grid_view,
                        color: Colors.grey[600], size: 20),
                    onPressed: () {
                      // TODO: Implement grid view toggle
                    },
                  ),
                ),
                SizedBox(width: 12),
                // Add referral button
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddReferralDialog();
                  },
                  icon: Icon(Icons.add, size: 16),
                  label:
                      Text('Tambah Referral', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table section
          // Ganti bagian table section dengan code ini:
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Responsive table content
                  Expanded(
                    child: Obx(() {
                      if (_referralController.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (_referralController.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                'Error loading data',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _referralController.errorMessage.value,
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final filteredReferrals = _getFilteredReferrals();

                      if (filteredReferrals.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Belum ada data referral'
                                    : 'Tidak ada hasil pencarian',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          bool isMobile = constraints.maxWidth < 768;

                          if (isMobile) {
                            // Mobile card view
                            return ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: filteredReferrals.length,
                              itemBuilder: (context, index) {
                                final referral = filteredReferrals[index];
                                final globalIndex = (_referralController
                                                .currentPage.value -
                                            1) *
                                        _referralController.itemsPerPage.value +
                                    index +
                                    1;

                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[200]!),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.05),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header row with number and menu
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#$globalIndex',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton(
                                            icon: Icon(Icons.more_vert,
                                                color: Colors.grey[600],
                                                size: 20),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 16),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        size: 16,
                                                        color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Delete',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showEditReferralDialog(
                                                    referral);
                                              } else if (value == 'delete') {
                                                _showDeleteConfirmation(
                                                    referral);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      // Customer name (main title)
                                      Text(
                                        referral.customerName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Contact info
                                      _buildInfoRow(
                                          Icons.email, referral.customerEmail),
                                      SizedBox(height: 4),
                                      _buildInfoRow(
                                          Icons.phone, referral.customerPhone),
                                      SizedBox(height: 8),
                                      // Referral code and commission
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Kode Referral',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Text(
                                                    referral.code,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Komisi',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${referral.commissionRate}${referral.commissionType == 'percentage' ? '%' : ''}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                  Text(
                                                    referral.commissionType ==
                                                            'percentage'
                                                        ? 'Persen'
                                                        : 'Fixed',
                                                    style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      // QR Code button
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            _showQRCodeDialog(referral);
                                          },
                                          icon: Icon(Icons.qr_code, size: 16),
                                          label: Text('Lihat QR Code'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.blue[600],
                                            side: BorderSide(
                                                color: Colors.blue[200]!),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            // Desktop table view (original code)
                            return Column(
                              children: [
                                // Table header
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: 30,
                                          child: Text('No.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Nama',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Email',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Phone',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Kode Referral',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14))),
                                      Expanded(
                                          flex: 1,
                                          child: Text('Komisi',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14))),
                                      Expanded(
                                          flex: 1,
                                          child: Text('QR Code',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14))),
                                      Container(width: 30),
                                    ],
                                  ),
                                ),

                                // Table rows
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: filteredReferrals.length,
                                    itemBuilder: (context, index) {
                                      final referral = filteredReferrals[index];
                                      final globalIndex = (_referralController
                                                      .currentPage.value -
                                                  1) *
                                              _referralController
                                                  .itemsPerPage.value +
                                          index +
                                          1;

                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]!,
                                                width: 1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              child: Text(
                                                '$globalIndex',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600]),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                referral.customerName,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                referral.customerEmail,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                referral.customerPhone,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                referral.code,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${referral.commissionRate}${referral.commissionType == 'percentage' ? '%' : ''}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Colors.green[700]),
                                                  ),
                                                  Text(
                                                    referral.commissionType ==
                                                            'percentage'
                                                        ? 'Persen'
                                                        : 'Fixed',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _showQRCodeDialog(referral);
                                                },
                                                child: Text(
                                                  'Lihat',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.blue[600],
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 30,
                                              child: PopupMenuButton(
                                                icon: Icon(Icons.more_vert,
                                                    color: Colors.grey[600],
                                                    size: 20),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _showEditReferralDialog(
                                                        referral);
                                                  } else if (value ==
                                                      'delete') {
                                                    _showDeleteConfirmation(
                                                        referral);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Pagination Widget
          Obx(() => PaginationWidget(
                currentPage: _referralController.currentPage.value,
                totalItems: _referralController.totalItems.value,
                itemsPerPage: _referralController.itemsPerPage.value,
                availablePageSizes: _referralController.availablePageSizes,
                startIndex: _referralController.startIndex,
                endIndex: _referralController.endIndex,
                hasPreviousPage: _referralController.hasPreviousPage,
                hasNextPage: _referralController.hasNextPage,
                pageNumbers: _referralController.pageNumbers,
                onPageSizeChanged: (newSize) =>
                    _referralController.onPageSizeChanged(newSize),
                onPreviousPage: () => _referralController.onPreviousPage(),
                onNextPage: () => _referralController.onNextPage(),
                onPageSelected: (page) =>
                    _referralController.onPageSelected(page),
              )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showQRCodeDialog(ReferralModel referral) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code - ${referral.customerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: referral.qrCodeImage.isNotEmpty
                  ? Image.memory(
                      base64Decode(referral.qrCodeImage),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.qr_code,
                              size: 100, color: Colors.grey),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.qr_code, size: 100, color: Colors.grey),
                    ),
            ),
            SizedBox(height: 16),
            Text('Kode: ${referral.code}'),
            if (referral.oneTimePassword.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('OTP: ${referral.oneTimePassword}',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ReferralModel referral) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Referral'),
        content: Text(
            'Apakah Anda yakin ingin menghapus referral ${referral.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _referralController.deleteReferral(referral.id);
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddReferralDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final commissionRateController = TextEditingController();
    String commissionType = 'percentage'; // default
    String? selectedCustomerId; // Store selected customer ID

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Tambah Referral'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer dropdown - NEW
                Obx(() => DropdownButtonFormField<String>(
                      value: selectedCustomerId,
                      decoration: InputDecoration(
                        labelText: 'Pilih Customer *',
                        border: OutlineInputBorder(),
                      ),
                      hint: Text('Pilih Customer'),
                      items: _customerController.customers.map((customer) {
                        return DropdownMenuItem<String>(
                          value: customer.id,
                          child: Text('${customer.name} '),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setDialogState(() {
                          selectedCustomerId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih customer terlebih dahulu';
                        }
                        return null;
                      },
                    )),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Referral *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'No. Telepon *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: commissionType,
                  decoration: InputDecoration(
                    labelText: 'Tipe Komisi',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'percentage', child: Text('Persentase')),
                    DropdownMenuItem(
                        value: 'fixed', child: Text('Nominal Tetap')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      commissionType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: commissionRateController,
                  decoration: InputDecoration(
                    labelText: commissionType == 'percentage'
                        ? 'Rate Komisi (%)'
                        : 'Nominal Komisi (Rp)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Validation
                if (selectedCustomerId == null || selectedCustomerId!.isEmpty) {
                  Get.snackbar('Error', 'Pilih customer terlebih dahulu');
                  return;
                }

                if (nameController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Nama referral tidak boleh kosong');
                  return;
                }

                if (phoneController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'No. telepon tidak boleh kosong');
                  return;
                }

                if (emailController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Email tidak boleh kosong');
                  return;
                }

                if (commissionRateController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Rate komisi tidak boleh kosong');
                  return;
                }

                Navigator.pop(context);
                _referralController.createReferral(
                  customerId: selectedCustomerId!,
                  referralName: nameController.text.trim(),
                  referralPhone: phoneController.text.trim(),
                  referralEmail: emailController.text.trim(),
                  commissionType: commissionType,
                  commissionRate:
                      double.tryParse(commissionRateController.text.trim()) ??
                          0.0,
                );
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReferralDialog(ReferralModel referral) {
    final nameController = TextEditingController(text: referral.customerName);
    final phoneController = TextEditingController(text: referral.customerPhone);
    final emailController = TextEditingController(text: referral.customerEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Referral'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Referral *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'No. Telepon *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              // Commission info display only (not editable in PATCH)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Komisi (tidak dapat diedit):'),
                    SizedBox(height: 8),
                    Text(
                        'Tipe: ${referral.commissionType == 'percentage' ? 'Persentase' : 'Nominal Tetap'}'),
                    Text(
                        'Rate: ${referral.commissionRate}${referral.commissionType == 'percentage' ? '%' : ''}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Validation
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Nama referral tidak boleh kosong');
                return;
              }

              if (phoneController.text.trim().isEmpty) {
                Get.snackbar('Error', 'No. telepon tidak boleh kosong');
                return;
              }

              if (emailController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Email tidak boleh kosong');
                return;
              }

              Navigator.pop(context);
              _referralController.updateReferral(
                referral.id,
                referralName: nameController.text.trim(),
                referralPhone: phoneController.text.trim(),
                referralEmail: emailController.text.trim(),
                // Note: commission_type and commission_rate are not included in PATCH
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
