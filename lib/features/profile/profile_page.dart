import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Soft cream background color from the reference
    const Color backgroundColor = Color(0xFFFDF6E9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Profile Avatar Placeholder
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                'Jane Doe',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Email and Edit Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'janedoe04@gmail.com',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.black87,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Menu Items
              Divider(color: Colors.grey.shade300, height: 1, thickness: 0.5),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                showTrailing: true,
                onTap: () {
                  // TODO: Implement Change Password logic
                },
              ),
              Divider(color: Colors.grey.shade300, height: 1, thickness: 0.5),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Log out',
                showTrailing: false,
                onTap: () {
                  // TODO: Implement Log out logic
                },
              ),
              Divider(color: Colors.grey.shade300, height: 1, thickness: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable widget for the menu items
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool showTrailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.black.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (showTrailing)
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black87,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}