import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:splash_animation/widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _initialScreenController;
  late final AnimationController _logoAnimationController;
  late final AnimationController _backgroundColorController;
  late final AnimationController _contentAnimationController;

  late final Animation<double> _logoPositionYAnimation;
  late final Animation<double> _logoPositionXAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoOpacityAnimation;
  late final Animation<double> _sweepAnimation;

  late final Animation<double> _contentOpacityAnimation;
  late final Animation<double> _contentPositionAnimation;

  final PageController _imagePageController = PageController(initialPage: 0);

  int _currentPage = 0;
  bool _showContent = false;
  bool _isNavigatingForward = true;

  static const int _numPages = 4;
  static const int _autoSwitchIntervalSeconds = 3;

  Timer? _pageAutoSwitchTimer;

  final List<String> _imagePaths = [
    'assets/images/image1.jpeg',
    'assets/images/image2.jpeg',
    'assets/images/image3.jpeg',
    'assets/images/image4.jpeg',
  ];

  final List<String> _titles = [
    'Expert Guidance for Smart Moves!',
    'Buy, Sell & Rent - All in One Place!',
    'Verified Listings for Safe Investments!',
    'Find Your Dream Home with Ease!',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Start with initial screen for 2 seconds
    _initialScreenController.forward();

    // After 2 seconds, start logo and background animations
    Future.delayed(const Duration(seconds: 2), () {
      _logoAnimationController.forward();
      _backgroundColorController.forward();
    });

    _logoAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showContent = true);
        _contentAnimationController.forward();
        _startAutoPageSwitchTimer();
      }
    });
  }

  void _initializeAnimations() {
    _initialScreenController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _backgroundColorController = AnimationController(
      duration: const Duration(seconds: 2500),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoPositionYAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.6)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.6),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_logoAnimationController);

    _logoPositionXAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.5),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_logoAnimationController);

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(2.0),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.0, end: 0.75),
        weight: 35,
      ),
    ]).animate(_logoAnimationController);

    _logoOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 90,
      ),
    ]).animate(_logoAnimationController);

    _sweepAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeInExpo),
      ),
    );

    _contentOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_contentAnimationController);

    _contentPositionAnimation = Tween<double>(
      begin: 200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutQuad,
    ));
  }

  @override
  void dispose() {
    _initialScreenController.dispose();
    _logoAnimationController.dispose();
    _backgroundColorController.dispose();
    _contentAnimationController.dispose();
    _imagePageController.dispose();
    _pageAutoSwitchTimer?.cancel();
    super.dispose();
  }

  void _startAutoPageSwitchTimer() {
    _pageAutoSwitchTimer?.cancel();
    _pageAutoSwitchTimer = Timer.periodic(
        const Duration(seconds: _autoSwitchIntervalSeconds),
        (_) => _animateToNextPage());
  }

  void _animateToNextPage() {
    final int nextPage = _currentPage < _numPages - 1 ? _currentPage + 1 : 0;
    _isNavigatingForward = true;

    _imagePageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 100),
      curve: Curves.elasticOut,
    );
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      _isNavigatingForward =
          (page > _currentPage) || (_currentPage == _numPages - 1 && page == 0);

      setState(() => _currentPage = page);
    }
    _startAutoPageSwitchTimer();
  }

  List<Widget> _buildPageIndicator() =>
      List.generate(_numPages, (i) => _indicator(i == _currentPage));

  Widget _indicator(bool isActive) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: 8.0,
        width: isActive ? 24.0 : 8.0,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(12),
        ),
      );

  Widget _buildOnboardingImage(String imagePath) => Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      );

  // Enhanced Text Animation with Smooth Sliding
  Widget _buildOnboardingText(String title, bool isForward, String? oldTitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: SizedBox(
        height: 95, // Fixed height
        child: Stack(
          children: [
            // Old text exiting quickly
            if (oldTitle != null)
              Positioned.fill(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      oldTitle, // Previous text
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                      textAlign: TextAlign.left,
                    )
                        .animate(
                          key: ValueKey("old_$oldTitle"),
                        )
                        .slideY(
                          begin: 0,
                          end: -1.2, // Moves up quickly
                          duration:
                              const Duration(milliseconds: 1200), // Fast exit
                          curve: Curves.elasticInOut, // Smooth exit
                        )
                    // .fadeOut(duration: const Duration(milliseconds: 200)), // Quick fade
                    ),
              ),

            // New text entering with delay
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title, // New text
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  textAlign: TextAlign.left,
                )
                    .animate(
                      key: ValueKey("new_$title"),
                    )
                    .slideY(
                      begin: isForward ? 1.0 : -1.0, // Enter from bottom or top
                      end: 0,
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(
                          milliseconds: 600), // Wait for old text to go
                      curve: Curves.elasticOut, // Smooth enter
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _initialScreenController,
        _logoAnimationController,
        _backgroundColorController,
        _contentAnimationController
      ]),
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Initial blank screen with specific color
              Positioned.fill(
                child: Container(
                  color: const Color.fromARGB(255, 184, 196, 205),
                ),
              ),

              Positioned.fill(
                child: CustomPaint(
                  painter: SweepingColorPainter(
                    initialBackgroundColor:
                        const Color.fromARGB(255, 184, 196, 205),
                    transitionBackgroundColor: Colors.white,
                    circleColor: const Color.fromARGB(255, 184, 196, 205),
                    animationValue: _sweepAnimation.value,
                  ),
                ),
              ),

              Positioned(
                left: size.width * _logoPositionXAnimation.value -
                    (45 * _logoScaleAnimation.value),
                top: size.height * _logoPositionYAnimation.value -
                    (105 * _logoScaleAnimation.value),
                child: Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Image.asset('assets/logo/NextDeals.png',
                          height: 160, width: 190)),
                ),
              ),

              if (_showContent)
                Positioned.fill(
                  top: size.height * 0.10,
                  child: Transform.translate(
                    offset: Offset(0, _contentPositionAnimation.value),
                    child: Opacity(
                      opacity: _contentOpacityAnimation.value,
                      child: Column(
                        children: [
                          Container(
                            // color: Colors.amber,
                            height: 100,
                            alignment: Alignment.topLeft,
                            child: ClipRRect(
                              child: _buildOnboardingText(
                                  _titles[_currentPage],
                                  _isNavigatingForward,
                                  _currentPage > 0
                                      ? _titles[_currentPage - 1]
                                      : null),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: PageView.builder(
                              controller:
                                  _imagePageController, // Use this instead of _pageController
                              itemCount: _numPages,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (_, index) =>
                                  _buildOnboardingImage(_imagePaths[index]),
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _buildPageIndicator()),
                              const SizedBox(height: 20),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: CustomButton(
                                      text: 'Get Started', onPressed: () {})),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SweepingColorPainter extends CustomPainter {
  final Color circleColor;
  final Color initialBackgroundColor;
  final Color transitionBackgroundColor;
  final double animationValue;

  const SweepingColorPainter({
    required this.circleColor,
    required this.initialBackgroundColor,
    required this.transitionBackgroundColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background Color Interpolation
    Color backgroundColor = Color.lerp(
        initialBackgroundColor, transitionBackgroundColor, animationValue)!;

    // Background fill with animated color transition
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    if (animationValue > 0) {
      double screenWidth =
          PlatformDispatcher.instance.views.first.physicalSize.width /
              PlatformDispatcher.instance.views.first.devicePixelRatio;

      // Reveal Effect ke origin point
      Offset revealOrigin = Offset(screenWidth / 8, -45);

      // Maximum radius jo screen ko cover kare
      double maxRadius =
          sqrt(size.width * size.width + size.height * size.height);

      // Circular Reveal ke liye path
      Path revealPath = Path()
        ..addOval(Rect.fromCircle(
          center: revealOrigin,
          radius: maxRadius * (1 - animationValue), // Shrink effect
        ));

      // Sweeping Circle draw karo
      canvas.drawPath(
        revealPath,
        Paint()
          ..color = circleColor
          ..blendMode = BlendMode.srcOver,
      );
    }
  }

  @override
  bool shouldRepaint(SweepingColorPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.circleColor != circleColor ||
      oldDelegate.initialBackgroundColor != initialBackgroundColor ||
      oldDelegate.transitionBackgroundColor != transitionBackgroundColor;
}
