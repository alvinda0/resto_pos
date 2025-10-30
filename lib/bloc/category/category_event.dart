import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryLoadRequested extends CategoryEvent {
  final bool showLoading;
  final int? page;
  final int? limit;
  final String? search;
  final String? status;

  const CategoryLoadRequested({
    this.showLoading = true,
    this.page,
    this.limit,
    this.search,
    this.status,
  });

  @override
  List<Object?> get props => [showLoading, page, limit, search, status];
}

class CategoryCreateRequested extends CategoryEvent {
  final String name;
  final bool isActive;
  final int? position;
  final String? storeId;

  const CategoryCreateRequested({
    required this.name,
    this.isActive = true,
    this.position,
    this.storeId,
  });

  @override
  List<Object?> get props => [name, isActive, position, storeId];
}

class CategoryUpdateRequested extends CategoryEvent {
  final String id;
  final String? name;
  final bool? isActive;
  final int? position;
  final String? storeId;

  const CategoryUpdateRequested({
    required this.id,
    this.name,
    this.isActive,
    this.position,
    this.storeId,
  });

  @override
  List<Object?> get props => [id, name, isActive, position, storeId];
}

class CategoryDeleteRequested extends CategoryEvent {
  final String id;
  final String? storeId;

  const CategoryDeleteRequested({
    required this.id,
    this.storeId,
  });

  @override
  List<Object?> get props => [id, storeId];
}

class CategoryPageChanged extends CategoryEvent {
  final int page;

  const CategoryPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class CategoryPageSizeChanged extends CategoryEvent {
  final int size;

  const CategoryPageSizeChanged(this.size);

  @override
  List<Object?> get props => [size];
}

class CategorySearchChanged extends CategoryEvent {
  final String query;

  const CategorySearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class CategoryStatusFilterChanged extends CategoryEvent {
  final String status;

  const CategoryStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class CategorySearchCleared extends CategoryEvent {
  const CategorySearchCleared();
}

class CategoryRefreshRequested extends CategoryEvent {
  const CategoryRefreshRequested();
}

class CategoryFormActiveToggled extends CategoryEvent {
  const CategoryFormActiveToggled();
}

class CategoryFormPreparedForCreate extends CategoryEvent {
  const CategoryFormPreparedForCreate();
}

class CategoryFormPreparedForEdit extends CategoryEvent {
  final String id;
  final String name;
  final bool isActive;
  final int? position;

  const CategoryFormPreparedForEdit({
    required this.id,
    required this.name,
    required this.isActive,
    this.position,
  });

  @override
  List<Object?> get props => [id, name, isActive, position];
}