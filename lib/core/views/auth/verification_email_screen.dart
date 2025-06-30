import 'package:fasyl/core/config/constants.dart';
import 'package:fasyl/core/services/auth_service.dart';
import 'package:fasyl/core/views/auth/new_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class VerificationEmailScreen extends StatefulWidget {
  final String email;

  const VerificationEmailScreen({super.key, required this.email});

  @override
  State<VerificationEmailScreen> createState() =>
      _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends State<VerificationEmailScreen>
    with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _codeController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  String _errorMessage = "";
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  // API endpoint
  static const String _verifyOtpUrl =
      'http://backend.groupe-syl.com/backend-preprod/api/v2/auth/users/verify-otp';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_codeController.text.length != 6) {
      setState(
        () => _errorMessage = "Veuillez entrer un code valide à 6 chiffres",
      );
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(_verifyOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': widget.email, 'otp': _codeController.text}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Vérifier si la réponse indique un succès
        if (responseData['token'] != null) {
          await _storage.write(
            key: 'auth_token',
            value: responseData['data']['token'],
          );

          // Afficher le message de succès
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Code vérifié avec succès !'),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.all(16),
              ),
            );

            await Future.delayed(Duration(milliseconds: 500));
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPasswordScreen(email: widget.email),
              ),
            );
          }
        } else {
          // Gestion des erreurs de l'API
          String errorMsg = "Code incorrect. Veuillez réessayer.";
          if (responseData['message'] != null) {
            errorMsg = responseData['message'];
          }
          setState(() => _errorMessage = errorMsg);
          _shakeController.forward().then((_) => _shakeController.reset());
        }
      } else if (response.statusCode == 400) {
        // Code invalide ou expiré
        final responseData = jsonDecode(response.body);
        String errorMsg = "Code incorrect ou expiré.";
        if (responseData['message'] != null) {
          errorMsg = responseData['message'];
        }
        setState(() => _errorMessage = errorMsg);
        _shakeController.forward().then((_) => _shakeController.reset());
      } else if (response.statusCode == 404) {
        setState(() => _errorMessage = "Email non trouvé.");
        _shakeController.forward().then((_) => _shakeController.reset());
      } else if (response.statusCode == 429) {
        setState(
          () => _errorMessage =
              "Trop de tentatives. Veuillez réessayer plus tard.",
        );
        _shakeController.forward().then((_) => _shakeController.reset());
      } else {
        setState(
          () => _errorMessage = "Erreur de connexion. Veuillez réessayer.",
        );
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    } catch (e) {
      setState(
        () => _errorMessage =
            "Erreur de connexion. Vérifiez votre connexion internet.",
      );
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    // Ici vous pouvez ajouter l'appel API pour renvoyer le code
    // Par exemple: await _auth.resendOtp(widget.email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.white),
              SizedBox(width: 12),
              Text('Nouveau code envoyé !'),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }

    _startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.secondary,
              AppColor.secondaryDark,
              const Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête personnalisé
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColor.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColor.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vérification',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Icône animée
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColor.primary.withOpacity(0.2),
                                    AppColor.primary.withOpacity(0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColor.primary.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primary.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.mark_email_read_outlined,
                                  size: 50,
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Titre et description
                          const Text(
                            'Vérification\nde l\'email',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "Nous avons envoyé un code de vérification à\n",
                                ),
                                TextSpan(
                                  text: widget.email,
                                  style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Champ PIN amélioré
                          _buildPinCodeField(),

                          const SizedBox(height: 24),

                          // Message d'erreur
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: _errorMessage.isNotEmpty ? 40 : 0,
                            child: AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    _shakeAnimation.value *
                                        (_shakeController.status ==
                                                AnimationStatus.reverse
                                            ? -1
                                            : 1),
                                    0,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColor.error.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: AppColor.error,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage,
                                            style: TextStyle(
                                              color: AppColor.error,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Bouton de vérification
                          _buildVerifyButton(),

                          const SizedBox(height: 32),

                          // Section de renvoi
                          _buildResendSection(),

                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _buildPinCodeField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: PinCodeTextField(
        controller: _codeController,
        length: 6,
        appContext: context,
        keyboardType: TextInputType.number,
        animationType: AnimationType.scale,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(12),
          fieldHeight: 60,
          fieldWidth: 45,
          activeFillColor: AppColor.primary.withOpacity(0.1),
          activeColor: AppColor.primary,
          inactiveColor: Colors.white.withOpacity(0.2),
          selectedColor: AppColor.primary,
          selectedFillColor: AppColor.primary.withOpacity(0.05),
          inactiveFillColor: AppColor.secondaryLight.withOpacity(0.5),
          borderWidth: 2,
        ),
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        onCompleted: (value) => _verifyOtp(),
        onChanged: (value) {
          setState(() => _errorMessage = "");
        },
        beforeTextPaste: (text) {
          // Permettre uniquement les chiffres
          return RegExp(r'^[0-9]+$').hasMatch(text ?? '');
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.black,
          elevation: 8,
          shadowColor: AppColor.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColor.primary.withOpacity(0.6),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Vérification...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Vérifier le code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified, size: 20),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          "Vous n'avez pas reçu le code ?",
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _canResend ? _resendCode : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: _canResend
                  ? LinearGradient(
                      colors: [
                        AppColor.primary.withOpacity(0.1),
                        AppColor.primary.withOpacity(0.05),
                      ],
                    )
                  : null,
              color: _canResend ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _canResend
                    ? AppColor.primary.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  color: _canResend
                      ? AppColor.primary
                      : Colors.white.withOpacity(0.5),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _canResend
                      ? "Renvoyer le code"
                      : "Renvoyer dans ${_resendCountdown}s",
                  style: TextStyle(
                    color: _canResend
                        ? AppColor.primary
                        : Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
