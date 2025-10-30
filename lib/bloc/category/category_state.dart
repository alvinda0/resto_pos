import 'package:equatable/equatable.dart';
import 'package:shao_kao/models/category/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final String searchQuery;
  final String statusFilter;

  const CategoryLoaded({
    required this.categories,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.searchQuery,
    required this.statusFilter,
  });

  @override
  List<Object?> get props => [
        categories,
        currentPage,
        itemsPerPage,
        totalItems,
        totalPages,
        searchQuery,
        statusFilter,
      ];

  CategoryLoaded copyWith({
    List<Category>? categories,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    int? totalPages,
    String? searchQuery,
    String? statusFilter,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class CategoryOperationLoading extends CategoryState {
  final String operation; // 'create', 'update', 'delete'

  const CategoryOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  final String operation;

  const CategoryOperationSuccess({
    required this.message,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, operation];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryFormState extends CategoryState {
  final String nameValue;
  final String positionValue;
  final bool isActiveValue;
  final bool isEditMode;
  final String? editingId;

  const CategoryFormState({
    required this.nameValue,
    required this.positionValue,
    required this.isActiveValue,
    required this.isEditMode,
    this.editingId,
  });

  @override
  List<Object?> get props => [
        nameValue,
        positionValue,
        isActiveValue,
        isEditMode,
        editingId,
      ];

  CategoryFormState copyWith({
    String? nameValue,
    String? positionValue,
    bool? isActiveValue,
    bool? isEditMode,
    String? editingId,
  }) {
    return CategoryFormState(
      nameValue: nameValue ?? this.nameValue,
      positionValue: positionValue ?? this.positionValue,
      isActiveValue: isActiveValue ?? this.isActiveValue,
      isEditMode: isEditMode ?? this.isEditMode,
      editingId: editingId ?? this.editingId,
    );
  }
}