import 'package:equatable/equatable.dart';
import 'package:shao_kao/models/product/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final String searchQuery;
  final String categoryFilter;

  const ProductLoaded({
    required this.products,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.searchQuery,
    required this.categoryFilter,
  });

  @override
  List<Object?> get props => [
        products,
        currentPage,
        itemsPerPage,
        totalItems,
        totalPages,
        searchQuery,
        categoryFilter,
      ];

  ProductLoaded copyWith({
    List<Product>? products,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    int? totalPages,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

class ProductOperationLoading extends ProductState {
  final String operation; // 'create', 'update', 'delete'

  const ProductOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  final String operation;

  const ProductOperationSuccess({
    required this.message,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, operation];
}

class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductCategoriesLoaded extends ProductState {
  final List<ProductCategory> categories;

  const ProductCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
