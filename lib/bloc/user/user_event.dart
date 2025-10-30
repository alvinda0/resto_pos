import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoadRequested extends UserEvent {
  final bool showLoading;
  final int? page;
  final int? limit;
  final String? search;
  final String? role;

  const UserLoadRequested({
    this.showLoading = true,
    this.page,
    this.limit,
    this.search,
    this.role,
  });

  @override
  List<Object?> get props => [showLoading, page, limit, search, role];
}

class UserCreateRequested extends UserEvent {
  final String name;
  final String email;
  final String password;
  final String roleId;
  final String? phone;

  const UserCreateRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.roleId,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, roleId, phone];
}

class UserUpdateRequested extends UserEvent {
  final String id;
  final String? name;
  final String? email;
  final String? password;
  final String? roleId;
  final String? phone;

  const UserUpdateRequested({
    required this.id,
    this.name,
    this.email,
    this.password,
    this.roleId,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, password, roleId, phone];
}

class UserDeleteRequested extends UserEvent {
  final String id;

  const UserDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class UserByIdRequested extends UserEvent {
  final String id;

  const UserByIdRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class UserPageChanged extends UserEvent {
  final int page;

  const UserPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class UserSearchChanged extends UserEvent {
  final String query;

  const UserSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class UserRoleFilterChanged extends UserEvent {
  final String role;

  const UserRoleFilterChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class UserRefreshRequested extends UserEvent {
  const UserRefreshRequested();
}
