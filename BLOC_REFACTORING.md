# BLoC State Management Refactoring

Aplikasi ini telah direfactor dari GetX ke BLoC (Business Logic Component) untuk state management yang lebih terstruktur dan testable.

## Struktur BLoC

### 1. Auth BLoC
- **Location**: `lib/bloc/auth/`
- **Files**:
  - `auth_event.dart` - Events untuk authentication
  - `auth_state.dart` - States untuk authentication
  - `auth_bloc.dart` - Business logic untuk authentication

**Events**:
- `AuthLoginRequested` - Request login dengan email dan password
- `AuthLogoutRequested` - Request logout
- `AuthStatusChecked` - Cek status authentication
- `AuthUserDataRefreshed` - Refresh user data
- `AuthForceLogout` - Force logout (untuk token expired)
- `AuthPasswordVisibilityToggled` - Toggle visibility password

**States**:
- `AuthInitial` - State awal
- `AuthLoading` - State loading
- `AuthAuthenticated` - State authenticated dengan user data
- `AuthUnauthenticated` - State unauthenticated
- `AuthError` - State error dengan pesan error
- `AuthPasswordVisibilityChanged` - State perubahan visibility password

### 2. Category BLoC
- **Location**: `lib/bloc/category/`
- **Files**:
  - `category_event.dart` - Events untuk category management
  - `category_state.dart` - States untuk category management
  - `category_bloc.dart` - Business logic untuk category management

**Events**:
- `CategoryLoadRequested` - Load categories dengan pagination dan filter
- `CategoryCreateRequested` - Create category baru
- `CategoryUpdateRequested` - Update category existing
- `CategoryDeleteRequested` - Delete category
- `CategoryPageChanged` - Ganti halaman pagination
- `CategoryPageSizeChanged` - Ganti ukuran halaman
- `CategorySearchChanged` - Search categories
- `CategoryStatusFilterChanged` - Filter berdasarkan status
- `CategorySearchCleared` - Clear search
- `CategoryRefreshRequested` - Refresh data
- `CategoryFormActiveToggled` - Toggle active status di form
- `CategoryFormPreparedForCreate` - Prepare form untuk create
- `CategoryFormPreparedForEdit` - Prepare form untuk edit

**States**:
- `CategoryInitial` - State awal
- `CategoryLoading` - State loading
- `CategoryLoaded` - State loaded dengan data categories dan pagination info
- `CategoryOperationLoading` - State loading untuk operasi CRUD
- `CategoryOperationSuccess` - State success untuk operasi CRUD
- `CategoryError` - State error
- `CategoryFormState` - State untuk form management

### 3. Splash BLoC
- **Location**: `lib/bloc/splash/`
- **Files**:
  - `splash_event.dart` - Events untuk splash screen
  - `splash_state.dart` - States untuk splash screen
  - `splash_bloc.dart` - Business logic untuk splash screen

## BLoC Providers Setup

**File**: `lib/bloc/bloc_providers.dart`

Menggunakan `MultiBlocProvider` untuk menyediakan semua BLoCs ke widget tree:

```dart
BlocProviders(
  child: GetMaterialApp(...),
)
```

## Cara Penggunaan

### 1. Menggunakan BLoC di Widget

```dart
// Mengirim event
context.read<AuthBloc>().add(AuthLoginRequested(
  email: email,
  password: password,
));

// Mendengarkan state changes
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      // Navigate to dashboard
    } else if (state is AuthError) {
      // Show error message
    }
  },
  child: YourWidget(),
)

// Membangun UI berdasarkan state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    return YourWidget();
  },
)

// Kombinasi listener dan builder
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // Handle side effects
  },
  builder: (context, state) {
    // Build UI
  },
)
```

### 2. Contoh Implementasi

**Login Screen** (`lib/screens/auth/login_screen.dart`):
- Menggunakan `BlocListener` untuk navigation dan snackbar
- Menggunakan `BlocBuilder` untuk loading state pada button

**Category List Widget** (`lib/widgets/category/category_list_widget.dart`):
- Contoh lengkap CRUD operations dengan BLoC
- Pagination, search, dan filter
- Form management dengan BLoC

## Migrasi dari GetX

### Yang Sudah Direfactor:
1. ✅ Auth Controller → Auth BLoC (LENGKAP)
2. ✅ Category Controller → Category BLoC (LENGKAP)
3. ✅ Splash Controller → Splash BLoC (LENGKAP)
4. ✅ Product Controller → Product BLoC (LENGKAP)
5. ✅ Dashboard Controller → Dashboard BLoC (LENGKAP)
6. ✅ Order Controller → Order BLoC (LENGKAP dengan auto-refresh)
7. ✅ User Controller → User BLoC (skeleton - perlu service implementation)
8. ✅ Kitchen Controller → Kitchen BLoC (skeleton dengan auto-refresh)
9. ✅ Payment Controller → Payment BLoC (LENGKAP dengan QRIS support)
10. ✅ Table/QR Code Controller → Table BLoC (skeleton)
11. ✅ Login Screen menggunakan BLoC
12. ✅ Splash Screen menggunakan BLoC
13. ✅ Category List Widget menggunakan BLoC (CRUD lengkap)
14. ✅ BLoC Providers setup dengan MultiBlocProvider

### BLoC yang Sudah Dibuat dan Siap Digunakan:
- **AuthBloc**: Login, logout, status check, password visibility
- **CategoryBloc**: CRUD, pagination, search, filter
- **ProductBloc**: CRUD, pagination, search, category filter, image upload
- **DashboardBloc**: Statistics, charts, refresh
- **OrderBloc**: List, pagination, search, filter, auto-refresh
- **UserBloc**: CRUD skeleton (perlu service implementation)
- **KitchenBloc**: Order management, status update, auto-refresh
- **PaymentBloc**: Multiple methods, QRIS generation, status check
- **TableBloc**: CRUD, QR code generation
- **SplashBloc**: Authentication check, navigation

### Yang Perlu Direfactor (Prioritas Rendah):
- [ ] Transaction Controller → Transaction BLoC
- [ ] New Order Controller → New Order BLoC

### Controller Lainnya (Prioritas Rendah):
- [ ] Account Controller
- [ ] API Key Controller
- [ ] Assets Controller
- [ ] Customer Controller
- [ ] Debt Controller
- [ ] Employee Controller
- [ ] Inventory Controller
- [ ] Payroll Controller
- [ ] Points Controller
- [ ] Profit Controller
- [ ] Promotion Controller
- [ ] Recipe Controller
- [ ] Redemption Controller
- [ ] Referral Controller
- [ ] Return Controller
- [ ] Rewards Controller
- [ ] Role Controller
- [ ] Tax Controller
- [ ] Theme Controller
- [ ] Withdraw Controller

## Keuntungan BLoC vs GetX

### BLoC:
- ✅ Lebih terstruktur dengan separation of concerns
- ✅ Immutable states untuk predictability
- ✅ Mudah untuk testing
- ✅ Built-in debugging dengan BlocObserver
- ✅ Stream-based untuk reactive programming
- ✅ Tidak terikat dengan Flutter (bisa digunakan di Dart apps)

### GetX:
- ✅ Lebih simple dan cepat untuk development
- ✅ Built-in dependency injection
- ✅ Routing management
- ❌ Mutable states bisa menyebabkan bugs
- ❌ Tightly coupled dengan Flutter
- ❌ Sulit untuk testing complex scenarios

## Best Practices

1. **Event Naming**: Gunakan past tense untuk events (e.g., `LoginRequested`, `DataLoaded`)
2. **State Naming**: Gunakan present tense untuk states (e.g., `Loading`, `Loaded`, `Error`)
3. **Immutable States**: Selalu gunakan immutable states dengan Equatable
4. **Single Responsibility**: Satu BLoC untuk satu feature/domain
5. **Error Handling**: Selalu handle error states dengan proper error messages
6. **Loading States**: Berikan feedback visual untuk loading states
7. **Form Management**: Gunakan separate events untuk form operations

## Testing

BLoC memudahkan testing karena:
- Pure functions untuk business logic
- Predictable state transitions
- Easy mocking dengan streams
- Isolated testing per BLoC

Contoh test structure:
```
test/
  bloc/
    auth/
      auth_bloc_test.dart
    category/
      category_bloc_test.dart
```

## Debugging

Gunakan `BlocObserver` untuk debugging:

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(BlocBase bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}
```

## Langkah Selanjutnya

1. Refactor controller lainnya ke BLoC pattern
2. Implement proper error handling di semua BLoCs
3. Add comprehensive testing
4. Implement BlocObserver untuk debugging
5. Consider using Hydrated BLoC untuk state persistence
6. Optimize dengan BlocSelector untuk specific state listening


## Template untuk Membuat BLoC Baru

### 1. Struktur Folder
```
lib/bloc/
  feature_name/
    feature_event.dart
    feature_state.dart
    feature_bloc.dart
```

### 2. Template Event (feature_event.dart)
```dart
import 'package:equatable/equatable.dart';

abstract class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

// Load/Fetch events
class FeatureLoadRequested extends FeatureEvent {
  final bool showLoading;
  
  const FeatureLoadRequested({this.showLoading = true});
  
  @override
  List<Object?> get props => [showLoading];
}

// CRUD events
class FeatureCreateRequested extends FeatureEvent {
  final String name;
  // Add other required fields
  
  const FeatureCreateRequested({required this.name});
  
  @override
  List<Object?> get props => [name];
}

class FeatureUpdateRequested extends FeatureEvent {
  final String id;
  final String? name;
  
  const FeatureUpdateRequested({required this.id, this.name});
  
  @override
  List<Object?> get props => [id, name];
}

class FeatureDeleteRequested extends FeatureEvent {
  final String id;
  
  const FeatureDeleteRequested(this.id);
  
  @override
  List<Object?> get props => [id];
}

// Pagination events
class FeaturePageChanged extends FeatureEvent {
  final int page;
  
  const FeaturePageChanged(this.page);
  
  @override
  List<Object?> get props => [page];
}

// Search/Filter events
class FeatureSearchChanged extends FeatureEvent {
  final String query;
  
  const FeatureSearchChanged(this.query);
  
  @override
  List<Object?> get props => [query];
}

class FeatureRefreshRequested extends FeatureEvent {
  const FeatureRefreshRequested();
}
```

### 3. Template State (feature_state.dart)
```dart
import 'package:equatable/equatable.dart';
import 'package:shao_kao/models/feature/feature_model.dart';

abstract class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

class FeatureInitial extends FeatureState {
  const FeatureInitial();
}

class FeatureLoading extends FeatureState {
  const FeatureLoading();
}

class FeatureLoaded extends FeatureState {
  final List<Feature> items;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final String searchQuery;

  const FeatureLoaded({
    required this.items,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [
        items,
        currentPage,
        itemsPerPage,
        totalItems,
        totalPages,
        searchQuery,
      ];

  FeatureLoaded copyWith({
    List<Feature>? items,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    int? totalPages,
    String? searchQuery,
  }) {
    return FeatureLoaded(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FeatureOperationLoading extends FeatureState {
  final String operation; // 'create', 'update', 'delete'

  const FeatureOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class FeatureOperationSuccess extends FeatureState {
  final String message;
  final String operation;

  const FeatureOperationSuccess({
    required this.message,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, operation];
}

class FeatureError extends FeatureState {
  final String message;

  const FeatureError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 4. Template BLoC (feature_bloc.dart)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/services/feature/feature_service.dart';
import 'feature_event.dart';
import 'feature_state.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final FeatureService _featureService;

  // State variables
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalItems = 0;
  int _totalPages = 0;
  String _searchQuery = '';

  FeatureBloc({required FeatureService featureService})
      : _featureService = featureService,
        super(const FeatureInitial()) {
    on<FeatureLoadRequested>(_onLoadRequested);
    on<FeatureCreateRequested>(_onCreateRequested);
    on<FeatureUpdateRequested>(_onUpdateRequested);
    on<FeatureDeleteRequested>(_onDeleteRequested);
    on<FeaturePageChanged>(_onPageChanged);
    on<FeatureSearchChanged>(_onSearchChanged);
    on<FeatureRefreshRequested>(_onRefreshRequested);
  }

  // Getters
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;

  Future<void> _onLoadRequested(
    FeatureLoadRequested event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      if (event.showLoading) {
        emit(const FeatureLoading());
      }

      final response = await _featureService.getItems(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      _totalItems = response.metadata.total;
      _totalPages = response.metadata.totalPages;
      _currentPage = response.metadata.page;
      _itemsPerPage = response.metadata.limit;

      emit(FeatureLoaded(
        items: response.data,
        currentPage: _currentPage,
        itemsPerPage: _itemsPerPage,
        totalItems: _totalItems,
        totalPages: _totalPages,
        searchQuery: _searchQuery,
      ));
    } catch (e) {
      emit(FeatureError('Gagal memuat data: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    FeatureCreateRequested event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      emit(const FeatureOperationLoading('create'));

      await _featureService.create(name: event.name);

      emit(FeatureOperationSuccess(
        message: 'Data berhasil dibuat',
        operation: 'create',
      ));

      add(const FeatureLoadRequested(showLoading: false));
    } catch (e) {
      emit(FeatureError('Gagal membuat data: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRequested(
    FeatureUpdateRequested event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      emit(const FeatureOperationLoading('update'));

      await _featureService.update(event.id, name: event.name);

      emit(const FeatureOperationSuccess(
        message: 'Data berhasil diperbarui',
        operation: 'update',
      ));

      add(const FeatureLoadRequested(showLoading: false));
    } catch (e) {
      emit(FeatureError('Gagal memperbarui data: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRequested(
    FeatureDeleteRequested event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      emit(const FeatureOperationLoading('delete'));

      await _featureService.delete(event.id);

      emit(const FeatureOperationSuccess(
        message: 'Data berhasil dihapus',
        operation: 'delete',
      ));

      add(const FeatureLoadRequested(showLoading: false));
    } catch (e) {
      emit(FeatureError('Gagal menghapus data: ${e.toString()}'));
    }
  }

  void _onPageChanged(
    FeaturePageChanged event,
    Emitter<FeatureState> emit,
  ) {
    _currentPage = event.page;
    add(const FeatureLoadRequested());
  }

  void _onSearchChanged(
    FeatureSearchChanged event,
    Emitter<FeatureState> emit,
  ) {
    _searchQuery = event.query;
    _currentPage = 1;
    add(const FeatureLoadRequested());
  }

  void _onRefreshRequested(
    FeatureRefreshRequested event,
    Emitter<FeatureState> emit,
  ) {
    add(const FeatureLoadRequested(showLoading: false));
  }
}
```

### 5. Menambahkan BLoC ke BlocProviders
```dart
// lib/bloc/bloc_providers.dart
BlocProvider<FeatureBloc>(
  create: (context) => FeatureBloc(
    featureService: FeatureService(),
  ),
),
```

### 6. Menggunakan BLoC di Widget
```dart
// Load data
context.read<FeatureBloc>().add(const FeatureLoadRequested());

// Listen to state changes
BlocListener<FeatureBloc, FeatureState>(
  listener: (context, state) {
    if (state is FeatureOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is FeatureError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: YourWidget(),
)

// Build UI based on state
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    if (state is FeatureLoading) {
      return const CircularProgressIndicator();
    }
    
    if (state is FeatureLoaded) {
      return ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return ListTile(
            title: Text(item.name),
          );
        },
      );
    }
    
    if (state is FeatureError) {
      return Text('Error: ${state.message}');
    }
    
    return const SizedBox();
  },
)
```

## Tips Migrasi dari GetX ke BLoC

### 1. Mapping GetX ke BLoC

| GetX | BLoC |
|------|------|
| `controller.method()` | `context.read<Bloc>().add(Event())` |
| `Obx(() => widget)` | `BlocBuilder<Bloc, State>()` |
| `controller.variable.value` | `state.variable` |
| `Get.snackbar()` | `BlocListener` + `ScaffoldMessenger` |
| `Get.to()` | `Navigator.push()` atau `Get.to()` (masih bisa digunakan) |

### 2. Langkah-langkah Migrasi

1. **Identifikasi Controller**: Pilih controller yang akan direfactor
2. **Buat Event**: Definisikan semua actions sebagai events
3. **Buat State**: Definisikan semua possible states
4. **Buat BLoC**: Implement business logic di event handlers
5. **Update Widget**: Ganti Obx/GetBuilder dengan BlocBuilder/BlocListener
6. **Test**: Pastikan semua functionality masih berjalan
7. **Cleanup**: Hapus controller GetX yang sudah tidak digunakan

### 3. Contoh Migrasi Konkret

**Before (GetX):**
```dart
class ProductController extends GetxController {
  final products = <Product>[].obs;
  final isLoading = false.obs;
  
  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      products.value = await productService.getProducts();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

// Widget
Obx(() => controller.isLoading.value 
  ? CircularProgressIndicator()
  : ListView(children: controller.products.map(...))
)
```

**After (BLoC):**
```dart
// Events
class ProductLoadRequested extends ProductEvent {}

// States
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded(this.products);
}
class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await productService.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

// Widget
BlocConsumer<ProductBloc, ProductState>(
  listener: (context, state) {
    if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is ProductLoading) {
      return const CircularProgressIndicator();
    }
    if (state is ProductLoaded) {
      return ListView(
        children: state.products.map(...).toList(),
      );
    }
    return const SizedBox();
  },
)
```

## Checklist Sebelum Migrasi

- [ ] Pastikan `flutter_bloc` dan `equatable` sudah ada di pubspec.yaml
- [ ] Buat struktur folder `lib/bloc/feature_name/`
- [ ] Identifikasi semua actions di controller
- [ ] Identifikasi semua states yang mungkin
- [ ] Buat service layer jika belum ada
- [ ] Test setiap BLoC setelah dibuat
- [ ] Update dokumentasi

## Resources

- [BLoC Official Documentation](https://bloclibrary.dev/)
- [Flutter BLoC Package](https://pub.dev/packages/flutter_bloc)
- [Equatable Package](https://pub.dev/packages/equatable)
- [BLoC Architecture](https://bloclibrary.dev/#/architecture)
