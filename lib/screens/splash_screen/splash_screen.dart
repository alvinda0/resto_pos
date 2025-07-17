import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/splash/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;

  // Initialize the controller
  final SplashController splashController = Get.put(SplashController());

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationAndCheckAuth();
  }

  /// Initialize animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.elasticOut),
    );
  }

  /// Start animation and check authentication
  void _startAnimationAndCheckAuth() {
    _animationController!.forward();

    // Check authentication status after animation completes
    splashController.checkAuthenticationStatus();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFFC084FC)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController!,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation!,
                child: ScaleTransition(
                  scale: _scaleAnimation!,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      SizedBox(height: 30),

                      // App Name
                      Text(
                        'SiResto',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),

                      SizedBox(height: 10),

                      // Tagline
                      Text(
                        'Sistem Informasi Restaurant',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                        ),
                      ),

                      SizedBox(height: 80),

                      // Loading Indicator
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
