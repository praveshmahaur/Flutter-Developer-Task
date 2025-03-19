import 'dart:async';
import 'package:flutter/material.dart';
import 'package:splash_animation/widgets/custom_button.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoAnimationController;
  late final AnimationController _backgroundColorController;
  late final AnimationController _contentAnimationController;
  late final AnimationController _textAnimationController;

  late final Animation<double> _logoPositionYAnimation;
  late final Animation<double> _logoPositionXAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoOpacityAnimation;
  late final Animation<double> _sweepAnimation;

  late final Animation<double> _contentOpacityAnimation;
  late final Animation<double> _contentPositionAnimation;
  late final Animation<double> _textOpacityAnimation;

  
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
    
    _logoAnimationController.forward();
    _backgroundColorController.forward();
    
    _logoAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showContent = true);
        _contentAnimationController.forward();
        _textAnimationController.forward();
        _startAutoPageSwitchTimer();
      }
    });
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _backgroundColorController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _logoPositionYAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.6)
            .chain(CurveTween(curve: Curves.easeOutBack)),
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
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
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
    
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _backgroundColorController.dispose();
    _contentAnimationController.dispose();
    _textAnimationController.dispose();
    _imagePageController.dispose();
    _pageAutoSwitchTimer?.cancel();
    super.dispose();
  }
  
  void _startAutoPageSwitchTimer() {
    _pageAutoSwitchTimer?.cancel();
    _pageAutoSwitchTimer = Timer.periodic(
      const Duration(seconds: _autoSwitchIntervalSeconds), 
      (_) => _animateToNextPage()
    );
  }
  
  void _animateToNextPage() {
    final int nextPage = _currentPage < _numPages - 1 ? _currentPage + 1 : 0;
    _isNavigatingForward = true;
    _textAnimationController.reset();
    _imagePageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _textAnimationController.forward();
  }
  
  void _onPageChanged(int page) {
    if (page != _currentPage) {
      _isNavigatingForward = (page > _currentPage) || 
                            (_currentPage == _numPages - 1 && page == 0);
      
      setState(() => _currentPage = page);
      _textAnimationController.reset();
      _textAnimationController.forward();
    }
    _startAutoPageSwitchTimer(); 
  }

  List<Widget> _buildPageIndicator() => List.generate(
    _numPages,
    (i) => _indicator(i == _currentPage)
  );

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
  
  Widget _buildOnboardingText(String title) => AnimatedBuilder(
    animation: _textAnimationController,
    builder: (context, _) {
      double offset = _isNavigatingForward 
          ? (1.0 - _textOpacityAnimation.value) * 50
          : -(1.0 - _textOpacityAnimation.value) * 50;
      
      return Transform.translate(
        offset: Offset(0, offset),
        child: Opacity(
          opacity: _textOpacityAnimation.value,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoAnimationController, 
        _backgroundColorController,
        _contentAnimationController
      ]),
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: SweepingColorPainter(
                    startColor: const Color.fromARGB(255, 184, 196, 205),
                    endColor: Colors.white,
                    animationValue: _sweepAnimation.value,
                  ),
                ),
              ),
              
              Positioned(
                left: size.width * _logoPositionXAnimation.value - (45 * _logoScaleAnimation.value),
                top: size.height * _logoPositionYAnimation.value - (80 * _logoScaleAnimation.value),
                child: Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Image.asset('assets/logo/NextDeals.png', height: 160, width: 190)
                  ),
                ),
              ),
              
              if (_showContent)
                Positioned.fill(
                  top: size.height * 0.12,
                  child: Transform.translate(
                    offset: Offset(0, _contentPositionAnimation.value),
                    child: Opacity(
                      opacity: _contentOpacityAnimation.value,
                      child: Column(
                        children: [
                          Container(
                            height: 82,
                            alignment: Alignment.topLeft,
                            child: _buildOnboardingText(_titles[_currentPage]),
                          ),
                          const SizedBox(height: 5),
                          Expanded(
                            child: PageView.builder(
                              physics: const ClampingScrollPhysics(),
                              controller: _imagePageController,
                              itemCount: _numPages,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (_, index) => _buildOnboardingImage(_imagePaths[index]),
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _buildPageIndicator()
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: CustomButton(text: 'Get Started', onPressed: (){})
                              ),
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
  final Color startColor;
  final Color endColor;
  final double animationValue;

  const SweepingColorPainter({
    required this.startColor,
    required this.endColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = endColor,
    );

    if (animationValue < 1.0) {
      double visiblePortion = 1.0 - animationValue;
      
      double startX = size.width * (1.0 + visiblePortion);
      double startY = size.height * (1.0 + visiblePortion);
      double endX = size.width * (-visiblePortion);
      double endY = size.height * (-visiblePortion);
      
      final path = Path()
        ..moveTo(startX, endY)
        ..lineTo(startX, startY)
        ..lineTo(endX, startY)
        ..lineTo(endX, endY)
        ..close();
      
      canvas.drawPath(path, Paint()..color = startColor);
    }
  }

  @override
  bool shouldRepaint(SweepingColorPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.startColor != startColor ||
      oldDelegate.endColor != endColor;
}




