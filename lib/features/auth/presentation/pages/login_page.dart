import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/snackbar_helper.dart'; // Senjata andalan kita
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;

    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();

    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  void _handleLoginResult(bool ok, AuthProvider auth) {
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      SnackBarHelper.showError(
        auth.errorMessage ?? 'Login failed. Please try again.',
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ), // Kotak tajam
        title: Text(
          'Reset Password',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF1A1A1A)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: ctrl.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  SnackBarHelper.showSuccess(
                    'Password reset link sent to your email.',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  SnackBarHelper.showError('Failed to send reset email.');
                }
              }
            },
            child: Text(
              'Send',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Authenticating...',
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Judul Mewah
                  Text(
                    'WELCOME BACK',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: const Color(0xFFC6A87C), // Emas
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign In to Your\nExclusive Account',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Input Email Elegan
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.lato(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: GoogleFonts.lato(color: Colors.grey.shade600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email is required';
                      if (!EmailValidator.validate(v!))
                        return 'Invalid email format';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Input Password Elegan
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    style: GoogleFonts.lato(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.lato(color: Colors.grey.shade600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1A1A1A)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade400,
                        ),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Lupa Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.lato(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Sign In Solid Black
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _loginEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'SIGN IN',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider Elegan
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Button (menggunakan widget bawaanmu, pastikan warnanya cocok jika perlu)
                  SizedBox(
                    width: double.infinity,
                    child: GoogleSignInButton(
                      onPressed: _loginGoogle,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Link Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to our boutique? ',
                        style: GoogleFonts.lato(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.register,
                        ),
                        child: Text(
                          'CREATE ACCOUNT',
                          style: GoogleFonts.lato(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
