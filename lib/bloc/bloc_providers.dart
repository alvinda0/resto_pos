import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shao_kao/bloc/auth/auth_bloc.dart';
import 'package:shao_kao/bloc/auth/auth_event.dart';
import 'package:shao_kao/bloc/category/category_bloc.dart';
import 'package:shao_kao/bloc/dashboard/dashboard_bloc.dart';
import 'package:shao_kao/bloc/order/order_bloc.dart';
import 'package:shao_kao/bloc/product/product_bloc.dart';
import 'package:shao_kao/bloc/splash/splash_bloc.dart';
import 'package:shao_kao/services/auth_service.dart';
import 'package:shao_kao/services/category/category_service.dart';
import 'package:shao_kao/services/dashboard/dashboard_service.dart';
import 'package:shao_kao/services/order/order_service.dart';
import 'package:shao_kao/services/product/product_service.dart';
import 'package:shao_kao/bloc/user/user_bloc.dart';
import 'package:shao_kao/bloc/kitchen/kitchen_bloc.dart';
import 'package:shao_kao/bloc/payment/payment_bloc.dart';
import 'package:shao_kao/bloc/table/table_bloc.dart';

class BlocProviders extends StatelessWidget {
  final Widget child;

  const BlocProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: AuthService.instance,
          )..add(const AuthStatusChecked()),
        ),
        
        // Splash BLoC
        BlocProvider<SplashBloc>(
          create: (context) => SplashBloc(
            authService: AuthService.instance,
          ),
        ),
        
        // Dashboard BLoC
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(
            statisticsService: StatisticsService.instance,
          ),
        ),
        
        // Category BLoC
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            categoryService: CategoryService(),
          ),
        ),
        
        // Product BLoC
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(
            productService: ProductService.instance,
          ),
        ),
        
        // Order BLoC
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(
            orderService: OrderService(),
          ),
        ),
        
        // User BLoC
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        
        // Kitchen BLoC
        BlocProvider<KitchenBloc>(
          create: (context) => KitchenBloc(),
        ),
        
        // Payment BLoC
        BlocProvider<PaymentBloc>(
          create: (context) => PaymentBloc(),
        ),
        
        // Table BLoC
        BlocProvider<TableBloc>(
          create: (context) => TableBloc(),
        ),
        
        // Add more BLoCs here as you create them
      ],
      child: child,
    );
  }
}