import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;


  static const Color _primaryOrange = Color(0xFFE8A020);
  static const Color _bgColor = Color(0xFFFDF6E3);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGrey = Color(0xFF9E9E9E);
  static const Color _borderColor = Color(0xFFE0E0E0);


  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),


                  // ── Logo & App Name ──────────────────────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: _primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Berseri',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 40),


                  // ── Headline ─────────────────────────────────────────────
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Know Your Skin ',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        TextSpan(
                          text: 'Better',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 8),


                  Text(
                    'Discover what your skin truly needs.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _textGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),


                  const SizedBox(height: 36),


                  // ── Email Field ──────────────────────────────────────────
                  Text(
                    'Email address',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),


                  const SizedBox(height: 20),


                  // ── Username Field ───────────────────────────────────────
                  Text(
                    'Username',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _usernameController,
                    hint: 'johndoe123',
                  ),


                  const SizedBox(height: 20),


                  // ── Password Field ───────────────────────────────────────
                  Text(
                    'Password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _passwordController,
                    hint: 'min. 8 characters with number',
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),


                  const SizedBox(height: 20),


                  // ── Confirm Password Field ───────────────────────────────
                  Text(
                    'Confirm password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hint: 're-enter your password',
                    obscure: _obscureConfirmPassword,
                    onToggle: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),


                  const SizedBox(height: 28),


                  // ── Create Account Button ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: buat registernya
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Create account >',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),


                  const Spacer(),


                  // ── Login link ───────────────────────────────────────────
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _textGrey,
                              ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.go('/auth/login'),
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _primaryOrange,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _primaryOrange,
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }


  // ── Helpers ───────────────────────────────────────────────────────────────


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFFBDBDBD),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8A020), width: 1.5),
        ),
      ),
    );
  }


  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFFBDBDBD),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFFBDBDBD),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8A020), width: 1.5),
        ),
      ),
    );
  }
}
