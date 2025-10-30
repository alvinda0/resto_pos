# 🚀 BLoC Quick Reference Guide

Panduan cepat untuk menggunakan BLoC di aplikasi Shao Kao POS.

---

## 📦 Available BLoCs

| BLoC | Status | Auto-Refresh | Service |
|------|--------|--------------|---------|
| AuthBloc | ✅ Ready | - | AuthService |
| CategoryBloc | ✅ Ready | - | CategoryService |
| ProductBloc | ✅ Ready | - | ProductService |
| DashboardBloc | ✅ Ready | - | StatisticsService |
| OrderBloc | ✅ Ready | ✅ 1s | OrderService |
| PaymentBloc | ✅ Ready | - | - |
| KitchenBloc | ⚠️ Skeleton | ✅ 3s | - |
| TableBloc | ⚠️ Skeleton | - | - |
| UserBloc | ⚠️ Skeleton | - | - |
| SplashBloc | ✅ Ready | - | AuthService |

---

## 🎯 Common Patterns

### Load Data
```dart
context.read<ProductBloc>().add(const ProductLoadRequested());
```

### Create
```dart
context.read<ProductBloc>().add(ProductCreateRequested(
  name: 'Product Name',
  // ... other fields
));
```

### Update
```dart
context.read<ProductBloc>().add(ProductUpdateRequested(
  id: 'product_id',
  name: 'New Name',
  // ... other fields
));
```

### Delete
```dart
context.read<ProductBloc>().add(ProductDeleteRequested('product_id'));
```

### Search
```dart
context.read<ProductBloc>().add(ProductSearchChanged('query'));
```

### Pagination
```dart
context.read<ProductBloc>().add(ProductPageChanged(2));
```

### Refresh
```dart
context.read<ProductBloc>().add(const ProductRefreshRequested());
```

---

## 🎨 UI Patterns

### BlocBuilder (UI Only)
```dart
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state is ProductLoading) return CircularProgressIndicator();
    if (state is ProductLoaded) return ProductList(state.products);
    if (state is ProductError) return ErrorWidget(state.message);
    return SizedBox();
  },
)
```

### BlocListener (Side Effects Only)
```dart
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

### BlocConsumer (Both)
```dart
BlocConsumer<ProductBloc, ProductState>(
  listener: (context, state) {
    // Handle side effects
  },
  builder: (context, state) {
    // Build UI
  },
)
```

---

## 📋 BLoC Cheat Sheet

### AuthBloc
```dart
// Login
context.read<AuthBloc>().add(AuthLoginRequested(
  email: 'user@example.com',
  password: 'password',
));

// Logout
context.read<AuthBloc>().add(const AuthLogoutRequested());

// Check status
context.read<AuthBloc>().add(const AuthStatusChecked());
```

### CategoryBloc
```dart
// Load
context.read<CategoryBloc>().add(const CategoryLoadRequested());

// Create
context.read<CategoryBloc>().add(CategoryCreateRequested(
  name: 'Category Name',
  isActive: true,
));

// Search
context.read<CategoryBloc>().add(CategorySearchChanged('query'));
```

### ProductBloc
```dart
// Load
context.read<ProductBloc>().add(const ProductLoadRequested());

// Create with image
context.read<ProductBloc>().add(ProductCreateRequested(
  name: 'Product Name',
  description: 'Description',
  basePrice: 25000,
  categoryId: 'cat_id',
  isAvailable: true,
  position: 1,
  imageFile: imageFile,
));

// Filter by category
context.read<ProductBloc>().add(
  ProductCategoryFilterChanged('category_id'),
);
```

### DashboardBloc
```dart
// Load statistics
context.read<DashboardBloc>().add(
  const DashboardStatisticsLoadRequested(),
);

// Refresh
context.read<DashboardBloc>().add(
  const DashboardRefreshRequested(),
);
```

### OrderBloc
```dart
// Load
context.read<OrderBloc>().add(const OrderLoadRequested());

// Search
context.read<OrderBloc>().add(OrderSearchChanged('customer'));

// Filter by status
context.read<OrderBloc>().add(OrderStatusFilterChanged('PAID'));

// Toggle auto-refresh
context.read<OrderBloc>().add(const OrderAutoRefreshToggled());
```

### PaymentBloc
```dart
// Generate QRIS
context.read<PaymentBloc>().add(PaymentQRISGenerateRequested(
  orderId: 'order_id',
  amount: 50000,
));

// Process payment
context.read<PaymentBloc>().add(PaymentProcessRequested(
  orderId: 'order_id',
  paymentMethods: [...],
  totalAmount: 50000,
));
```

### KitchenBloc
```dart
// Load orders
context.read<KitchenBloc>().add(
  const KitchenOrdersLoadRequested(),
);

// Update status
context.read<KitchenBloc>().add(KitchenOrderStatusUpdateRequested(
  orderId: 'order_id',
  newStatus: 'COOKING',
));

// Toggle auto-refresh
context.read<KitchenBloc>().add(const KitchenAutoRefreshToggled());
```

### TableBloc
```dart
// Load tables
context.read<TableBloc>().add(const TableLoadRequested());

// Generate QR
context.read<TableBloc>().add(
  TableQRCodeGenerateRequested('table_id'),
);
```

---

## 🔍 State Checking

### Check Loading
```dart
if (state is ProductLoading) {
  return CircularProgressIndicator();
}
```

### Check Loaded
```dart
if (state is ProductLoaded) {
  return ProductList(products: state.products);
}
```

### Check Error
```dart
if (state is ProductError) {
  return ErrorWidget(message: state.message);
}
```

### Check Operation Success
```dart
if (state is ProductOperationSuccess) {
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
```

---

## 🎯 Common Use Cases

### 1. Load Data on Init
```dart
@override
void initState() {
  super.initState();
  context.read<ProductBloc>().add(const ProductLoadRequested());
}
```

### 2. Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<ProductBloc>().add(const ProductRefreshRequested());
    await context.read<ProductBloc>().stream.firstWhere(
      (state) => state is! ProductLoading,
    );
  },
  child: ProductList(),
)
```

### 3. Search with TextField
```dart
TextField(
  onChanged: (value) {
    context.read<ProductBloc>().add(ProductSearchChanged(value));
  },
  decoration: InputDecoration(
    hintText: 'Search...',
    prefixIcon: Icon(Icons.search),
  ),
)
```

### 4. Pagination Buttons
```dart
Row(
  children: [
    ElevatedButton(
      onPressed: () {
        final bloc = context.read<ProductBloc>();
        if (bloc.hasPreviousPage) {
          bloc.add(ProductPageChanged(bloc.currentPage - 1));
        }
      },
      child: Text('Previous'),
    ),
    Text('Page ${bloc.currentPage}'),
    ElevatedButton(
      onPressed: () {
        final bloc = context.read<ProductBloc>();
        if (bloc.hasNextPage) {
          bloc.add(ProductPageChanged(bloc.currentPage + 1));
        }
      },
      child: Text('Next'),
    ),
  ],
)
```

### 5. Form Submission
```dart
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

### 6. Delete with Confirmation
```dart
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(
                ProductDeleteRequested(product.id),
              );
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  },
)
```

---

## 🐛 Troubleshooting

### BLoC not found
```dart
// ❌ Wrong
ProductBloc bloc = ProductBloc();

// ✅ Correct
context.read<ProductBloc>()
```

### State not updating
```dart
// Make sure state has proper props
@override
List<Object?> get props => [products, currentPage]; // ✅
```

### Memory leak with Timer
```dart
// Always cancel timer in close()
@override
Future<void> close() {
  _timer?.cancel();
  return super.close();
}
```

### Can't add event after close
```dart
// Check if mounted before adding event
if (mounted) {
  context.read<ProductBloc>().add(event);
}
```

---

## 📚 Full Documentation

- **BLOC_USAGE_GUIDE.md** - Detailed usage guide
- **BLOC_REFACTORING.md** - Pattern & best practices
- **BLOC_MIGRATION_SUMMARY.md** - Migration overview
- **BLOC_IMPLEMENTATION_COMPLETE.md** - Implementation status

---

## 💡 Tips

1. **Always use const** for events without parameters
   ```dart
   const ProductLoadRequested() // ✅
   ProductLoadRequested()        // ❌
   ```

2. **Use BlocConsumer** when you need both listener and builder
   ```dart
   BlocConsumer<ProductBloc, ProductState>(...) // ✅
   ```

3. **Check state type** before accessing properties
   ```dart
   if (state is ProductLoaded) {
     final products = state.products; // ✅
   }
   ```

4. **Use copyWith** for partial state updates
   ```dart
   emit(state.copyWith(products: newProducts)); // ✅
   ```

5. **Handle all possible states** in builder
   ```dart
   if (state is Loading) return Loading();
   if (state is Loaded) return Content();
   if (state is Error) return Error();
   return SizedBox(); // ✅ Default case
   ```

---

**Last Updated**: 2025-01-30
**Version**: 1.0.0
