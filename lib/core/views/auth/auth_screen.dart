import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/views/auth/components/signup_page.dart';
import 'package:fasyl/core/views/auth/components/login_page.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final int selectedIndex;

  const AuthScreen({super.key, required this.selectedIndex});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;

    // Configuration des animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuad,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTabChange(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo/Titre
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Text(
                      "FASYL",
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 7,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Bienvenue",
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Créez un compte ou connectez-vous avec un compte existant",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Tab Selector
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColor.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AuthTabButton(
                          text: 'Connexion',
                          isActive: _selectedIndex == 1,
                          onTap: () => _handleTabChange(1),
                        ),
                      ),
                      Expanded(
                        child: _AuthTabButton(
                          text: 'Inscription',
                          isActive: _selectedIndex == 2,
                          onTap: () => _handleTabChange(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Animated Content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _selectedIndex == 1 ? LoginPage() : SignUpPage(),
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

// Widget personnalisé pour les boutons d'onglet
class _AuthTabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _AuthTabButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive
                ? AppColor.textOnPrimary
                : Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
