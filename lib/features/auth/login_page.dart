import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;


  static const Color _primaryOrange = Color(0xFFE8A020);
  static const Color _bgColor = Color(0xFFFDF6E3);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGrey = Color(0xFF9E9E9E);
  static const Color _borderColor = Color(0xFFE0E0E0);


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                          decoration: BoxDecoration(
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


                  // ── Email / Username Field ───────────────────────────────
                  Text(
                    'Username or email address',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'username or name@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),


                  const SizedBox(height: 20),


                  // ── Password Field label row ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: ngisi lupa password
                        },
                        child: Text(
                          'Forgot?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(),


                  const SizedBox(height: 28),


                  // ── Login Button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Front-end only: navigate to home if both fields are filled.
                        final username = _emailController.text.trim();
                        final password = _passwordController.text;
                        if (username.isNotEmpty && password.isNotEmpty) {
                          context.go('/');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in username and password.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
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
                        'Login >',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 24),


                  // ── Or continue with ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: _borderColor, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _textGrey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: _borderColor, thickness: 1),
                      ),
                    ],
                  ),


                  const SizedBox(height: 16),


                  // ── Google & Apple Buttons ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Google',
                          onTap: () {
                            // TODO: Google sign-in
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          label: 'Apple',
                          onTap: () {
                            // TODO: Apple sign-in
                          },
                        ),
                      ),
                    ],
                  ),


                  const Spacer(),


                  // ── Sign up link ─────────────────────────────────────────
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'New to Berseri? ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _textGrey,
                              ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.go('/auth/register'),
                                child: Text(
                                  'Create an account',
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


  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: 'min. 8 characters with number',
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
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFFBDBDBD),
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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


  Widget _buildSocialButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}
