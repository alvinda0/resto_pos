import 'package:flutter/material.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Map<String, dynamic>> cartItems = [];
  double total = 0;

  final List<Map<String, dynamic>> products = [
    {'name': 'Nasi Goreng', 'price': 15000},
    {'name': 'Mie Ayam', 'price': 12000},
    {'name': 'Es Teh', 'price': 5000},
    {'name': 'Ayam Bakar', 'price': 20000},
    {'name': 'Soto Ayam', 'price': 13000},
  ];

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      bool found = false;
      for (var item in cartItems) {
        if (item['name'] == product['name']) {
          item['quantity']++;
          found = true;
          break;
        }
      }
      if (!found) {
        cartItems.add({
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
        });
      }
      calculateTotal();
    });
  }

  void removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
      calculateTotal();
    });
  }

  void calculateTotal() {
    total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
  }

  void processPayment() {
    if (cartItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran Berhasil'),
        content: Text('Total: Rp ${total.toStringAsFixed(0)}'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                cartItems.clear();
                total = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjualan'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          // Products List
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Daftar Produk',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        child: InkWell(
                          onTap: () => addToCart(product),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.fastfood, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  product['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${product['price']}',
                                  style: TextStyle(
                                    color: Colors.deepPurple.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Cart
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Keranjang',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return ListTile(
                          title: Text(item['name']),
                          subtitle:
                              Text('Rp ${item['price']} x ${item['quantity']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeFromCart(index),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total: Rp ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Bayar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
