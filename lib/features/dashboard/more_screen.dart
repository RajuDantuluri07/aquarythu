import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../auth/auth_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('More', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(
                    auth.user?.email ?? 'User',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile Section
                  _buildMenuCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'View and edit your profile',
                    color: AppColors.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile page coming soon...')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Farms Section
                  _buildMenuCard(
                    context,
                    icon: Icons.agriculture,
                    title: 'Farms',
                    subtitle: 'Manage your farms',
                    color: AppColors.success,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Farms page coming soon...')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Pricing Plan Section
                  _buildMenuCard(
                    context,
                    icon: Icons.monetization_on,
                    title: 'Pricing Plans',
                    subtitle: 'View our pricing and features',
                    color: AppColors.warning,
                    onTap: () => _showPricingDialog(context),
                  ),
                  const SizedBox(height: 12),

                  // Privacy Policy
                  _buildMenuCard(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Our commitment to your privacy',
                    color: AppColors.info,
                    onTap: () => _showPrivacyPolicyDialog(context),
                  ),
                  const SizedBox(height: 12),

                  // Terms & Conditions
                  _buildMenuCard(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Terms of service and conditions',
                    color: AppColors.gray600,
                    onTap: () => _showTermsDialog(context),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await context.read<AuthNotifier>().signOut();
                                  if (context.mounted) Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AquaRythu v1.0.0',
                    style: TextStyle(color: AppColors.gray600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  void _showPricingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pricing Plans'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FREE PLAN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('✓ Unlimited feed logging'),
              const Text('✓ Unlimited ponds'),
              const Text('✓ Blind feeding auto schedule'),
              const Text('✓ Tray logging (per tray mandatory)'),
              const Text('✓ Water test logging'),
              const SizedBox(height: 16),
              const Text(
                'PRO PLAN (₹499/month)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text('✓ All Free Plan features'),
              const Text('✓ Feed increase/decrease suggestions'),
              const Text('✓ Overfeeding alerts'),
              const Text('✓ Feed discipline score'),
              const Text('✓ FCR calculation'),
              const Text('✓ Appetite trend graph'),
              const Text('✓ Water-based feeding intelligence'),
              const Text('✓ Reports and analytics'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AquaRythu Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'We respect your privacy and are committed to protecting your personal data. '
                'We collect information necessary to provide feed management and water quality insights. '
                'Your data is encrypted and stored securely on Supabase servers. '
                'We will never sell your data to third parties.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              const Text(
                '• Data is encrypted in transit and at rest\n'
                '• Only you can access your farm data\n'
                '• You can request data deletion anytime\n'
                '• We comply with all data protection regulations',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AquaRythu Terms & Conditions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Service Description\n'
                'AquaRythu provides feed management and water quality insights for shrimp farming.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              const Text(
                '2. User Responsibilities\n'
                'You are responsible for maintaining the confidentiality of your account credentials.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              const Text(
                '3. Disclaimer\n'
                'AquaRythu does not guarantee profits or specific outcomes. '
                'The app provides insights to help with decision-making.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              const Text(
                '4. Limitation of Liability\n'
                'AquaRythu is provided "as is". We are not liable for any damages resulting from app usage.',
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
