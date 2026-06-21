import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'tv_display_screen.dart';

class TvDisplayAuthGate extends StatefulWidget {
  const TvDisplayAuthGate({super.key});

  @override
  State<TvDisplayAuthGate> createState() => _TvDisplayAuthGateState();
}

class _TvDisplayAuthGateState extends State<TvDisplayAuthGate> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late FirebaseAuth _firebaseAuth;
  late FirebaseFirestore _firestore;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isInit = false;
  String? _errorMessage;
  String? _orgId;

  @override
  void initState() {
    super.initState();
    _initTvApp();
  }

  Future<void> _initTvApp() async {
    // Safely find or create the isolated 'TV_DISPLAY' Firebase app.
    // Using Firebase.apps.any() is more reliable than try/catch because
    // Firebase.app('name') may throw a platform-specific uncaught error.
    final alreadyExists = Firebase.apps.any((app) => app.name == 'TV_DISPLAY');
    final FirebaseApp tvApp = alreadyExists
        ? Firebase.app('TV_DISPLAY')
        : await Firebase.initializeApp(
            name: 'TV_DISPLAY',
            options: Firebase.app().options,
          );

    _firebaseAuth = FirebaseAuth.instanceFor(app: tvApp);
    _firestore = FirebaseFirestore.instanceFor(app: tvApp);

    await _checkExistingSession();
    if (mounted) {
      setState(() {
        _isInit = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _resolveAdminUser(user);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential.user != null) {
        await _resolveAdminUser(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No admin account found with this email';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'Invalid email or password';
          break;
        case 'invalid-email':
          msg = 'Invalid email address';
          break;
        case 'user-disabled':
          msg = 'This account has been disabled';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Try again later';
          break;
        default:
          msg = e.message ?? 'Login failed';
      }
      if (!mounted) return;
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveAdminUser(User user) async {
    try {
      final doc =
          await _firestore.collection('admin_users').doc(user.uid).get();

      if (!mounted) return;

      if (!doc.exists) {
        setState(() {
          _errorMessage =
              'Access denied. This account is not registered as an admin.';
          _isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      final role = data['role'] as String?;
      final allowedRoles = ['admin', 'superAdmin', 'manager'];

      if (role == null || !allowedRoles.contains(role)) {
        setState(() {
          _errorMessage =
              'Access denied. TV Display requires an admin, manager, or super admin role.';
          _isLoading = false;
        });
        return;
      }

      final orgId = data['organizationId'] as String?;
      if (orgId == null || orgId.isEmpty) {
        setState(() {
          _errorMessage =
              'No organization linked to this admin account. Contact support.';
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _orgId = orgId;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Failed to verify admin: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _firebaseAuth.signOut();
    setState(() {
      _orgId = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return _buildLoadingScreen('Initializing...');
    if (_orgId != null) {
      return TvDisplayScreen(
        organizationId: _orgId!,
      );
    }
    return _buildLoginUI();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
      prefixIcon: Icon(icon, color: const Color(0xFF6A5CFF)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF6A5CFF), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
  }

  Widget _buildLoginUI() {
    const pageBackground = Color(0xFF09071A);

    return Scaffold(
      backgroundColor: pageBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    pageBackground,
                    const Color(0xFF100E1D),
                    const Color(0xFF19142A),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6A5CFF).withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            right: -70,
            bottom: -110,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6A5CFF).withValues(alpha: 0.18),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 40,
                          offset: const Offset(0, 24),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A5CFF), Color(0xFF6A5CFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.tv_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'TV Display Access',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admin sign in required to start the venue display.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.62),
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  label: 'Email address',
                                  icon: Icons.alternate_email_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white.withValues(
                                        alpha: 0.62,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _handleLogin(),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6A5CFF),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFF6A5CFF,
                                    ).withValues(alpha: 0.45),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? LoadingAnimationWidget.fourRotatingDots(
                                          color: Colors.white,
                                          size: 28,
                                        )
                                      : const Text(
                                          'Sign in to TV Display',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A1820),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withValues(alpha: 0.04),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_moon_outlined,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Restricted to venue admins and managers.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.62),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 12),
                        // TextButton(
                        //   onPressed: _orgId != null ? _signOut : null,
                        //   style: TextButton.styleFrom(
                        //     foregroundColor: Colors.white.withValues(
                        //       alpha: 0.5,
                        //     ),
                        //   ),
                        //   child: const Text('Sign out'),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFF09071A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.fourRotatingDots(
              color: const Color(0xFF6A5CFF),
              size: 48,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
