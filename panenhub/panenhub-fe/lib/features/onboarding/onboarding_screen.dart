import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const OnboardingScreen({super.key, required this.onLogin, required this.onRegister});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  final _slides = const [
    _OnboardingSlide(
      icon: Icons.calendar_today_outlined,
      title: 'Pesan Sebelum Panen',
      description: 'Pre-order komoditas segar langsung dari petani sebelum masa panen tiba.',
    ),
    _OnboardingSlide(
      icon: Icons.local_shipping_outlined,
      title: 'Pantau Rantai Pasok',
      description: 'Pantau proses panen, sortir, dan pengiriman secara transparan.',
    ),
    _OnboardingSlide(
      icon: Icons.shield_outlined,
      title: 'Pembayaran Aman',
      description: 'Dana ditahan aman melalui escrow sampai barang diterima sesuai.',
    ),
    _OnboardingSlide(
      icon: Icons.verified_outlined,
      title: 'Kualitas Terjaga',
      description: 'Quality control dan mekanisme sengketa untuk melindungi transaksi Anda.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onLogin,
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Icon(slide.icon, size: 56, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Text(slide.title, style: AppTextStyles.headlineLarge, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(slide.description, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                      ],
                    );
                  },
                ),
              ),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'Masuk',
                onPressed: widget.onLogin,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Daftar Sekarang',
                isOutlined: true,
                onPressed: widget.onRegister,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingSlide({required this.icon, required this.title, required this.description});
}
