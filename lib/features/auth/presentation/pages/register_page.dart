import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Sembunyikan keyboard

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      SnackBarHelper.showError(
        auth.errorMessage ?? 'Registration failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Creating account...',
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
                  // Judul Mewah
                  Text(
                    'JOIN THE CLUB',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: const Color(0xFFC6A87C), // Emas
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create Your\nExclusive Account',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Input Nama
                  TextFormField(
                    controller: _nameCtrl,
                    style: GoogleFonts.lato(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.lato(color: Colors.grey.shade600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 24),

                  // Input Email
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

                  // Input Password
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
                    validator: (v) => (v?.length ?? 0) < 8
                        ? 'Minimum 8 characters required'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Input Confirm Password
                  TextFormField(
                    controller: _pass2Ctrl,
                    obscureText: !_showPass,
                    style: GoogleFonts.lato(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: GoogleFonts.lato(color: Colors.grey.shade600),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    validator: (v) =>
                        v != _passCtrl.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 48),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'CREATE ACCOUNT',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Link Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member? ',
                        style: GoogleFonts.lato(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.login,
                        ),
                        child: Text(
                          'SIGN IN',
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
