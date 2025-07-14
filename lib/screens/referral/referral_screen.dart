import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/referral/referral_controller.dart';
import 'package:pos/models/referral/referral_model.dart';

class ReferralScreen extends StatefulWidget {
  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ReferralController _referralController = Get.put(ReferralController());

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Referral',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Header section with search and add button
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
                    // TODO: Navigate to add referral screen
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
                  // Table header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                            child: Text('Kode QR',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14))),
                        Container(width: 30),
                      ],
                    ),
                  ),

                  // Table rows with Obx for reactive updates
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

                      return ListView.builder(
                        itemCount: filteredReferrals.length,
                        itemBuilder: (context, index) {
                          final referral = filteredReferrals[index];
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey[200]!, width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    referral.customerName,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    referral.customerEmail,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    referral.customerPhone,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    referral.code,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[700]),
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
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  child: PopupMenuButton(
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.grey[600], size: 20),
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
                                        _showEditReferralDialog(referral);
                                      } else if (value == 'delete') {
                                        _showDeleteConfirmation(referral);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                  ? Image.network(
                      referral.qrCodeImage,
                      fit: BoxFit.cover,
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
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Referral'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Customer'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'No. Telepon'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: 'Kode Referral'),
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
              Navigator.pop(context);
              _referralController.createReferral(
                storeId: 'store_id_placeholder', // Replace with actual store ID
                customerId:
                    'customer_id_placeholder', // Replace with actual customer ID
                customerName: nameController.text,
                customerPhone: phoneController.text,
                customerEmail: emailController.text,
                code: codeController.text,
              );
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditReferralDialog(ReferralModel referral) {
    final nameController = TextEditingController(text: referral.customerName);
    final phoneController = TextEditingController(text: referral.customerPhone);
    final emailController = TextEditingController(text: referral.customerEmail);
    final codeController = TextEditingController(text: referral.code);

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
                decoration: InputDecoration(labelText: 'Nama Customer'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'No. Telepon'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: 'Kode Referral'),
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
              Navigator.pop(context);
              _referralController.updateReferral(
                referral.id,
                customerName: nameController.text,
                customerPhone: phoneController.text,
                customerEmail: emailController.text,
                code: codeController.text,
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
