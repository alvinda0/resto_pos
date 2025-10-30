import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final List<dynamic> users;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final String searchQuery;
  final String roleFilter;

  const UserLoaded({
    required this.users,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.searchQuery,
    required this.roleFilter,
  });

  @override
  List<Object?> get props => [
        users,
        currentPage,
        itemsPerPage,
        totalItems,
        totalPages,
        searchQuery,
        roleFilter,
      ];
}

class UserOperationLoading extends UserState {
  final String operation;

  const UserOperationLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class UserOperationSuccess extends UserState {
  final String message;
  final String operation;

  const UserOperationSuccess({
    required this.message,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, operation];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
