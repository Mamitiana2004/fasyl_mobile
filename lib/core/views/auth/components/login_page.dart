import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/services/abonnement_service.dart';
import 'package:fasyl/core/services/auth_service.dart';
import 'package:fasyl/core/views/abonnement/abonnement_screen.dart';
import 'package:fasyl/core/views/auth/forgot_screen.dart';
import 'package:fasyl/core/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final AbonnementService _abonnementService = AbonnementService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _shakeController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _shakeAnimation;

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Animation principale
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Animation du bouton
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Animation de tremblement pour les erreurs
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _animationController.forward();
  }

  Future<void> _redirectUserBasedOnSubscription() async {
    bool hasAbonnement = await _abonnementService.have_abonnement();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              hasAbonnement ? const HomeScreen() : const AbonnementScreen(),
        ),
      );
    }
  }

  Future<void> _checkAuthStatus() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final user = await storage.read(key: 'user');

    if (token != null && user != null && mounted) {
      await _redirectUserBasedOnSubscription();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    _buttonAnimationController.forward();

    try {
      final response = await _auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response != null) {
        HapticFeedback.lightImpact();
        await _redirectUserBasedOnSubscription();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      HapticFeedback.heavyImpact();
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _buttonAnimationController.reverse();
      }
    }
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.secondary.withOpacity(0.1),
            Colors.transparent,
            AppColor.primary.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildGradientBackground(),
        AnimatedBuilder(
          animation: Listenable.merge([_animationController, _shakeController]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _shakeAnimation.value *
                    10 *
                    ((_shakeController.value * 4).floor() % 2 == 0 ? 1 : -1),
                _slideAnimation.value,
              ),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field avec animation délayée
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (0 * 100)),
                          curve: Curves.easeOutBack,
                          child: _EnhancedAuthTextField(
                            controller: _emailController,
                            label: "Email",
                            hintText: "entrez@votre.email",
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un email';
                              }
                              if (!value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Password Field avec animation délayée
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (1 * 100)),
                          curve: Curves.easeOutBack,
                          child: _EnhancedAuthTextField(
                            controller: _passwordController,
                            label: "Mot de passe",
                            hintText: "••••••••",
                            icon: Icons.lock_rounded,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value.length < 6) {
                                return '6 caractères minimum';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password avec effet hover
                        Align(
                          alignment: Alignment.centerRight,
                          child: _HoverTextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotScreen(),
                                ),
                              );
                            },
                            text: "Mot de passe oublié ?",
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Enhanced Login Button
                        AnimatedBuilder(
                          animation: _buttonAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonScaleAnimation.value,
                              child: _EnhancedLoginButton(
                                isLoading: _isLoading,
                                onPressed: _login,
                              ),
                            );
                          },
                        ),

                        // Enhanced Error Message
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.5),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: _errorMessage.isNotEmpty
                              ? _EnhancedErrorMessage(message: _errorMessage)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EnhancedAuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _EnhancedAuthTextField({
    required this.controller,
    required this.label,
    this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<_EnhancedAuthTextField> createState() => _EnhancedAuthTextFieldState();
}

class _EnhancedAuthTextFieldState extends State<_EnhancedAuthTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isFocused
                  ? AppColor.primary
                  : Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: AppColor.primary,
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 16,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      widget.icon,
                      color: _isFocused
                          ? AppColor.primary
                          : Colors.white.withOpacity(0.6),
                      size: 22,
                    ),
                  ),
                  suffixIcon: widget.suffixIcon,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 50,
                    minHeight: 50,
                  ),
                  filled: true,
                  fillColor: AppColor.secondaryLight.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColor.primary.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  errorStyle: TextStyle(
                    color: AppColor.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                validator: widget.validator,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EnhancedLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _EnhancedLoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.black,
                ),
              )
            : const Text(
                "Se connecter",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

class _HoverTextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const _HoverTextButton({required this.onPressed, required this.text});

  @override
  State<_HoverTextButton> createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<_HoverTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: _isHovered
                  ? AppColor.primary
                  : AppColor.primary.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: _isHovered
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _EnhancedErrorMessage extends StatelessWidget {
  final String message;

  const _EnhancedErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.error.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColor.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColor.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
