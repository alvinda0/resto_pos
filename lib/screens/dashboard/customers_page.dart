import 'package:flutter/material.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  List<Map<String, dynamic>> customers = [
    {
      'name': 'Ahmad Suryanto',
      'phone': '081234567890',
      'email': 'ahmad@email.com',
      'totalPurchases': 850000,
      'lastVisit': '2024-01-15',
    },
    {
      'name': 'Siti Nurhaliza',
      'phone': '081234567891',
      'email': 'siti@email.com',
      'totalPurchases': 1250000,
      'lastVisit': '2024-01-14',
    },
    {
      'name': 'Budi Santoso',
      'phone': '081234567892',
      'email': 'budi@email.com',
      'totalPurchases': 650000,
      'lastVisit': '2024-01-13',
    },
  ];

  final _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    filteredCustomers = customers;
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers
            .where((customer) =>
                customer['name'].toLowerCase().contains(query.toLowerCase()) ||
                customer['phone'].contains(query) ||
                customer['email'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                setState(() {
                  customers.add({
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                    'totalPurchases': 0,
                    'lastVisit': DateTime.now().toString().substring(0, 10),
                  });
                  _filterCustomers(_searchController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                customers.removeWhere((customer) =>
                    customer['name'] == filteredCustomers[index]['name']);
                _filterCustomers(_searchController.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelanggan'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showAddCustomerDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header and Search
            Row(
              children: [
                const Text(
                  'Daftar Pelanggan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari pelanggan...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterCustomers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.people,
                              size: 32, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            customers.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total Pelanggan'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.person_add,
                              size: 32, color: Colors.green),
                          const SizedBox(height: 8),
                          const Text(
                            '5',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Pelanggan Baru'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.star,
                              size: 32, color: Colors.orange),
                          const SizedBox(height: 8),
                          const Text(
                            '12',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Pelanggan VIP'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Customers List
            Expanded(
              child: Card(
                child: ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade700,
                        child: Text(
                          customer['name'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        customer['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📞 ${customer['phone']}'),
                          Text('📧 ${customer['email']}'),
                          Text(
                              '💰 Total Pembelian: Rp ${customer['totalPurchases']}'),
                          Text(
                              '📅 Kunjungan Terakhir: ${customer['lastVisit']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Implement edit functionality
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCustomer(index),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
