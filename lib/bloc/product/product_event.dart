import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {
  final bool showLoading;
  final int? page;
  final int? limit;
  final String? search;
  final String? category;

  const ProductLoadRequested({
    this.showLoading = true,
    this.page,
    this.limit,
    this.search,
    this.category,
  });

  @override
  List<Object?> get props => [showLoading, page, limit, search, category];
}

class ProductCreateRequested extends ProductEvent {
  final String name;
  final String description;
  final int basePrice;
  final String categoryId;
  final bool isAvailable;
  final int position;
  final String? recipeId;
  final File? imageFile;

  const ProductCreateRequested({
    required this.name,
    required this.description,
    required this.basePrice,
    required this.categoryId,
    required this.isAvailable,
    required this.position,
    this.recipeId,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        basePrice,
        categoryId,
        isAvailable,
        position,
        recipeId,
        imageFile,
      ];
}

class ProductUpdateRequested extends ProductEvent {
  final String id;
  final String name;
  final String description;
  final int basePrice;
  final String categoryId;
  final bool isAvailable;
  final int position;
  final String? recipeId;
  final File? imageFile;

  const ProductUpdateRequested({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.categoryId,
    required this.isAvailable,
    required this.position,
    this.recipeId,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        basePrice,
        categoryId,
        isAvailable,
        position,
        recipeId,
        imageFile,
      ];
}

class ProductDeleteRequested extends ProductEvent {
  final String id;

  const ProductDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ProductByIdRequested extends ProductEvent {
  final String id;

  const ProductByIdRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ProductPageChanged extends ProductEvent {
  final int page;

  const ProductPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class ProductPageSizeChanged extends ProductEvent {
  final int size;

  const ProductPageSizeChanged(this.size);

  @override
  List<Object?> get props => [size];
}

class ProductSearchChanged extends ProductEvent {
  final String query;

  const ProductSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductCategoryFilterChanged extends ProductEvent {
  final String category;

  const ProductCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class ProductFiltersCleared extends ProductEvent {
  const ProductFiltersCleared();
}

class ProductRefreshRequested extends ProductEvent {
  const ProductRefreshRequested();
}

class ProductCategoriesLoadRequested extends ProductEvent {
  const ProductCategoriesLoadRequested();
}
