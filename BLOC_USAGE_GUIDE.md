# Panduan Penggunaan BLoC di Aplikasi Shao Kao

## Daftar BLoC yang Tersedia

### 1. AuthBloc
**Lokasi**: `lib/bloc/auth/`

**Cara Menggunakan**:
```dart
// Login
context.read<AuthBloc>().add(AuthLoginRequested(
  email: 'user@example.com',
  password: 'password123',
));

// Logout
context.read<AuthBloc>().add(const AuthLogoutRequested());

// Check status
context.read<AuthBloc>().add(const AuthStatusChecked());

// Listen to state
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      // Navigate to dashboard
    } else if (state is AuthError) {
      // Show error
    }
  },
  child: YourWidget(),
)
```

---

### 2. CategoryBloc
**Lokasi**: `lib/bloc/category/`

**Cara Menggunakan**:
```dart
// Load categories
context.read<CategoryBloc>().add(const CategoryLoadRequested());

// Create category
context.read<CategoryBloc>().add(CategoryCreateRequested(
  name: 'Makanan',
  isActive: true,
  position: 1,
));

// Update category
context.read<CategoryBloc>().add(CategoryUpdateRequested(
  id: 'category_id',
  name: 'Makanan Baru',
  isActive: true,
));

// Delete category
context.read<CategoryBloc>().add(CategoryDeleteRequested('category_id'));

// Search
context.read<CategoryBloc>().add(CategorySearchChanged('search query'));

// Pagination
context.read<CategoryBloc>().add(CategoryPageChanged(2));

// Build UI
BlocBuilder<CategoryBloc, CategoryState>(
  builder: (context, state) {
    if (state is CategoryLoading) {
      return CircularProgressIndicator();
    }
    if (state is CategoryLoaded) {
      return ListView.builder(
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return ListTile(title: Text(category.name));
        },
      );
    }
    return SizedBox();
  },
)
```

---

### 3. ProductBloc
**Lokasi**: `lib/bloc/product/`

**Cara Menggunakan**:
```dart
// Load products
context.read<ProductBloc>().add(const ProductLoadRequested());

// Create product with image
context.read<ProductBloc>().add(ProductCreateRequested(
  name: 'Nasi Goreng',
  description: 'Nasi goreng spesial',
  basePrice: 25000,
  categoryId: 'category_id',
  isAvailable: true,
  position: 1,
  imageFile: imageFile, // File?
));

// Update product
context.read<ProductBloc>().add(ProductUpdateRequested(
  id: 'product_id',
  name: 'Nasi Goreng Special',
  description: 'Updated description',
  basePrice: 30000,
  categoryId: 'category_id',
  isAvailable: true,
  position: 1,
));

// Delete product
context.read<ProductBloc>().add(ProductDeleteRequested('product_id'));

// Search
context.read<ProductBloc>().add(ProductSearchChanged('nasi'));

// Filter by category
context.read<ProductBloc>().add(ProductCategoryFilterChanged('category_id'));

// Clear filters
context.read<ProductBloc>().add(const ProductFiltersCleared());

// Load categories for dropdown
context.read<ProductBloc>().add(const ProductCategoriesLoadRequested());

// Listen to operations
BlocListener<ProductBloc, ProductState>(
  listener: (context, state) {
    if (state is ProductOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

---

### 4. DashboardBloc
**Lokasi**: `lib/bloc/dashboard/`

**Cara Menggunakan**:
```dart
// Load statistics
context.read<DashboardBloc>().add(const DashboardStatisticsLoadRequested());

// Refresh
context.read<DashboardBloc>().add(const DashboardRefreshRequested());

// Retry on error
context.read<DashboardBloc>().add(const DashboardRetryRequested());

// Build UI
BlocBuilder<DashboardBloc, DashboardState>(
  builder: (context, state) {
    if (state is DashboardLoading) {
      return CircularProgressIndicator();
    }
    if (state is DashboardLoaded) {
      return Column(
        children: [
          Text('Today Earnings: ${state.statistics.data.dailyStats.totalEarnings}'),
          Text('Today Orders: ${state.statistics.data.dailyStats.totalOrders}'),
          // Chart
          ChartWidget(data: state.chartData),
        ],
      );
    }
    return SizedBox();
  },
)
```

---

### 5. OrderBloc
**Lokasi**: `lib/bloc/order/`

**Fitur**: Auto-refresh setiap 1 detik

**Cara Menggunakan**:
```dart
// Load orders
context.read<OrderBloc>().add(const OrderLoadRequested());

// Search
context.read<OrderBloc>().add(OrderSearchChanged('customer name'));

// Filter by status
context.read<OrderBloc>().add(OrderStatusFilterChanged('PAID'));

// Filter by method
context.read<OrderBloc>().add(OrderMethodFilterChanged('Tunai'));

// Toggle auto-refresh
context.read<OrderBloc>().add(const OrderAutoRefreshToggled());

// Pagination
context.read<OrderBloc>().add(OrderPageChanged(2));
context.read<OrderBloc>().add(OrderPageSizeChanged(20));

// Clear filters
context.read<OrderBloc>().add(const OrderFiltersCleared());

// Build UI
BlocBuilder<OrderBloc, OrderState>(
  builder: (context, state) {
    if (state is OrderLoaded) {
      return Column(
        children: [
          // Auto-refresh indicator
          if (state.isAutoRefreshEnabled)
            Text('Auto-refresh: ON'),
          // Orders list
          ListView.builder(
            itemCount: state.filteredOrders.length,
            itemBuilder: (context, index) {
              final order = state.filteredOrders[index];
              return OrderCard(order: order);
            },
          ),
        ],
      );
    }
    return SizedBox();
  },
)
```

---

### 6. PaymentBloc
**Lokasi**: `lib/bloc/payment/`

**Cara Menggunakan**:
```dart
// Load payment methods
context.read<PaymentBloc>().add(const PaymentMethodsLoadRequested());

// Process payment
context.read<PaymentBloc>().add(PaymentProcessRequested(
  orderId: 'order_id',
  paymentMethods: [
    {'method': 'Tunai', 'amount': 50000},
  ],
  totalAmount: 50000,
));

// Generate QRIS
context.read<PaymentBloc>().add(PaymentQRISGenerateRequested(
  orderId: 'order_id',
  amount: 50000,
));

// Check QRIS status
context.read<PaymentBloc>().add(PaymentQRISStatusCheckRequested('transaction_id'));

// Select payment method
context.read<PaymentBloc>().add(PaymentMethodSelected('Tunai'));

// Reset payment form
context.read<PaymentBloc>().add(const PaymentReset());

// Listen to payment status
BlocListener<PaymentBloc, PaymentState>(
  listener: (context, state) {
    if (state is PaymentSuccess) {
      // Navigate to success page
    } else if (state is PaymentQRISGenerated) {
      // Show QR code
    } else if (state is PaymentQRISPaid) {
      // Payment confirmed
    }
  },
  child: YourWidget(),
)
```

---

### 7. KitchenBloc
**Lokasi**: `lib/bloc/kitchen/`

**Fitur**: Auto-refresh setiap 3 detik

**Cara Menggunakan**:
```dart
// Load kitchen orders
context.read<KitchenBloc>().add(const KitchenOrdersLoadRequested());

// Update order status
context.read<KitchenBloc>().add(KitchenOrderStatusUpdateRequested(
  orderId: 'order_id',
  newStatus: 'COOKING',
));

// Complete order item
context.read<KitchenBloc>().add(KitchenOrderItemCompleteRequested(
  orderId: 'order_id',
  itemId: 'item_id',
));

// Filter by status
context.read<KitchenBloc>().add(KitchenStatusFilterChanged('PENDING'));

// Toggle auto-refresh
context.read<KitchenBloc>().add(const KitchenAutoRefreshToggled());

// Build UI
BlocBuilder<KitchenBloc, KitchenState>(
  builder: (context, state) {
    if (state is KitchenLoaded) {
      return Column(
        children: [
          // Status filter
          DropdownButton<String>(
            value: state.selectedStatus,
            items: ['ALL', 'PENDING', 'COOKING', 'READY']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {
              context.read<KitchenBloc>().add(
                    KitchenStatusFilterChanged(value!),
                  );
            },
          ),
          // Orders
          ListView.builder(
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              return KitchenOrderCard(order: state.orders[index]);
            },
          ),
        ],
      );
    }
    return SizedBox();
  },
)
```

---

### 8. TableBloc
**Lokasi**: `lib/bloc/table/`

**Cara Menggunakan**:
```dart
// Load tables
context.read<TableBloc>().add(const TableLoadRequested());

// Create table
context.read<TableBloc>().add(TableCreateRequested(
  tableNumber: 1,
  capacity: 4,
  location: 'Indoor',
));

// Update table
context.read<TableBloc>().add(TableUpdateRequested(
  id: 'table_id',
  tableNumber: 1,
  capacity: 6,
  isActive: true,
));

// Delete table
context.read<TableBloc>().add(TableDeleteRequested('table_id'));

// Generate QR code
context.read<TableBloc>().add(TableQRCodeGenerateRequested('table_id'));

// Search
context.read<TableBloc>().add(TableSearchChanged('1'));

// Listen to QR code generation
BlocListener<TableBloc, TableState>(
  listener: (context, state) {
    if (state is TableQRCodeGenerated) {
      // Show QR code dialog
      showDialog(
        context: context,
        builder: (context) => QRCodeDialog(qrCode: state.qrCode),
      );
    }
  },
  child: YourWidget(),
)
```

---

### 9. UserBloc
**Lokasi**: `lib/bloc/user/`

**Status**: Skeleton (perlu service implementation)

**Cara Menggunakan**:
```dart
// Load users
context.read<UserBloc>().add(const UserLoadRequested());

// Create user
context.read<UserBloc>().add(UserCreateRequested(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
  roleId: 'role_id',
  phone: '08123456789',
));

// Update user
context.read<UserBloc>().add(UserUpdateRequested(
  id: 'user_id',
  name: 'John Doe Updated',
  email: 'john.new@example.com',
));

// Delete user
context.read<UserBloc>().add(UserDeleteRequested('user_id'));

// Search
context.read<UserBloc>().add(UserSearchChanged('john'));

// Filter by role
context.read<UserBloc>().add(UserRoleFilterChanged('admin'));
```

---

## Pattern Umum

### 1. BlocConsumer (Listener + Builder)
```dart
BlocConsumer<ProductBloc, ProductState>(
  listener: (context, state) {
    // Handle side effects (navigation, snackbar, dialog)
    if (state is ProductOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  builder: (context, state) {
    // Build UI based on state
    if (state is ProductLoading) {
      return CircularProgressIndicator();
    }
    if (state is ProductLoaded) {
      return ProductList(products: state.products);
    }
    return SizedBox();
  },
)
```

### 2. BlocBuilder (UI Only)
```dart
BlocBuilder<CategoryBloc, CategoryState>(
  builder: (context, state) {
    if (state is CategoryLoading) {
      return CircularProgressIndicator();
    }
    if (state is CategoryLoaded) {
      return CategoryList(categories: state.categories);
    }
    return SizedBox();
  },
)
```

### 3. BlocListener (Side Effects Only)
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (state is AuthError) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: state.message),
      );
    }
  },
  child: LoginForm(),
)
```

### 4. Multiple BLoC Listeners
```dart
MultiBlocListener(
  listeners: [
    BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle auth state
      },
    ),
    BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        // Handle product state
      },
    ),
  ],
  child: YourWidget(),
)
```

---

## Tips & Best Practices

### 1. Inisialisasi Data
```dart
@override
void initState() {
  super.initState();
  // Load data saat widget pertama kali dibuat
  context.read<ProductBloc>().add(const ProductLoadRequested());
  context.read<CategoryBloc>().add(const CategoryLoadRequested());
}
```

### 2. Refresh Data
```dart
// Pull to refresh
RefreshIndicator(
  onRefresh: () async {
    context.read<ProductBloc>().add(const ProductRefreshRequested());
    // Wait for state to change
    await context.read<ProductBloc>().stream.firstWhere(
      (state) => state is! ProductLoading,
    );
  },
  child: ProductList(),
)
```

### 3. Form dengan BLoC
```dart
// Submit form
ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      context.read<ProductBloc>().add(ProductCreateRequested(
        name: _nameController.text,
        description: _descriptionController.text,
        basePrice: int.parse(_priceController.text),
        categoryId: _selectedCategoryId,
        isAvailable: true,
        position: 1,
      ));
    }
  },
  child: Text('Submit'),
)
```

### 4. Pagination
```dart
// Next page button
ElevatedButton(
  onPressed: () {
    final bloc = context.read<ProductBloc>();
    if (bloc.hasNextPage) {
      bloc.add(ProductPageChanged(bloc.currentPage + 1));
    }
  },
  child: Text('Next'),
)

// Previous page button
ElevatedButton(
  onPressed: () {
    final bloc = context.read<ProductBloc>();
    if (bloc.hasPreviousPage) {
      bloc.add(ProductPageChanged(bloc.currentPage - 1));
    }
  },
  child: Text('Previous'),
)
```

### 5. Search dengan Debounce
```dart
TextField(
  onChanged: (value) {
    // BLoC akan handle debouncing jika diperlukan
    context.read<ProductBloc>().add(ProductSearchChanged(value));
  },
  decoration: InputDecoration(
    hintText: 'Search products...',
    prefixIcon: Icon(Icons.search),
  ),
)
```

---

## Troubleshooting

### Error: "BlocProvider not found"
**Solusi**: Pastikan widget Anda berada di dalam `BlocProviders` di `main.dart`

### Error: "Bad state: Cannot add new events after calling close"
**Solusi**: Jangan add event setelah BLoC di-dispose. Gunakan `if (mounted)` check.

### State tidak update
**Solusi**: 
1. Pastikan menggunakan `Equatable` di state
2. Pastikan `props` di state sudah benar
3. Gunakan `copyWith` untuk update state

### Memory leak dengan Timer
**Solusi**: Pastikan cancel timer di `close()` method BLoC

```dart
@override
Future<void> close() {
  _timer?.cancel();
  return super.close();
}
```

---

## Contoh Lengkap: Product Screen

```dart
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create product
            },
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(const ProductRefreshRequested());
                await context.read<ProductBloc>().stream.firstWhere(
                  (state) => state is! ProductLoading,
                );
              },
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        context.read<ProductBloc>().add(
                          ProductSearchChanged(value),
                        );
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  
                  // Products list
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(product.description),
                          trailing: Text(
                            context.read<ProductBloc>().formatCurrency(
                              product.basePrice,
                            ),
                          ),
                          onTap: () {
                            // Navigate to product detail
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Pagination
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: context.read<ProductBloc>().hasPreviousPage
                              ? () {
                                  final bloc = context.read<ProductBloc>();
                                  bloc.add(ProductPageChanged(
                                    bloc.currentPage - 1,
                                  ));
                                }
                              : null,
                          child: const Text('Previous'),
                        ),
                        Text(
                          'Page ${state.currentPage} of ${state.totalPages}',
                        ),
                        ElevatedButton(
                          onPressed: context.read<ProductBloc>().hasNextPage
                              ? () {
                                  final bloc = context.read<ProductBloc>();
                                  bloc.add(ProductPageChanged(
                                    bloc.currentPage + 1,
                                  ));
                                }
                              : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
```
