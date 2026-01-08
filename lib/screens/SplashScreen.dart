import 'package:flutter/material.dart';
import 'package:counter_app/screens/CategorySelectionScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _controller;
  late Future<void> _loadingFuture;

  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _loadingFuture = _loadAppData();
  }

  Future<void> _loadAppData() async {
    // ضع تحميلك الحقيقي هنا
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategorySelectionScreen(),
                ),
              );
            });
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [Colors.black, Colors.grey.shade900]
                    : [
                        theme.primaryColor,
                        theme.primaryColorDark,
                      ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: FadeTransition(
                        opacity: _fade,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            size: 90,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SlideTransition(
                      position: _slide,
                      child: FadeTransition(
                        opacity: _fade,
                        child: Text(
                          'مسابقة الذكاء',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        'اختبر معلوماتك وتحدى أصدقاءك',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    if (snapshot.connectionState != ConnectionState.done)
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
