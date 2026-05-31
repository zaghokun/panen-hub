import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/network/services/auth_service.dart';
import '../../core/network/api_exceptions.dart';
import '../../providers/app_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSuccess;

  const RegisterScreen({super.key, required this.onLogin, required this.onSuccess});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'customer';
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Customer fields
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  String _businessType = 'Restoran';
  // Farmer fields
  final _farmNameController = TextEditingController();
  final _farmAddressController = TextEditingController();
  final _landAreaController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _farmNameController.dispose();
    _farmAddressController.dispose();
    _landAreaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      if (_selectedRole == 'customer') {
        await authService.registerCustomer(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          businessName: _businessNameController.text.trim(),
          businessType: _businessType,
          businessAddress: _businessAddressController.text.trim(),
        );
      } else {
        await authService.registerFarmer(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          farmName: _farmNameController.text.trim(),
          landArea: double.tryParse(_landAreaController.text) ?? 0,
          address: _farmAddressController.text.trim(),
        );
      }

      if (mounted) {
        // Refresh auth state with the new user
        await ref.read(authProvider.notifier).checkSession();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedRole == 'farmer'
                  ? 'Pendaftaran berhasil! Akun Anda menunggu verifikasi admin.'
                  : 'Pendaftaran berhasil!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSuccess();
      }
    } on DioException catch (e) {
      if (mounted) {
        final apiError = e.error;
        final message = apiError is ApiException ? apiError.message : 'Tidak dapat terhubung ke server.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat terhubung ke server.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // Role selection
                Text('Daftar Sebagai', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.storefront_outlined,
                        label: 'Pelanggan B2B',
                        subtitle: 'Restoran, Katering, Hotel',
                        isSelected: _selectedRole == 'customer',
                        onTap: () => setState(() => _selectedRole = 'customer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.agriculture_outlined,
                        label: 'Petani Mitra',
                        subtitle: 'Pemasok komoditas',
                        isSelected: _selectedRole == 'farmer',
                        onTap: () => setState(() => _selectedRole = 'farmer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Common fields
                AppTextField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  controller: _nameController,
                  validator: (v) => Validators.required(v, 'Nama'),
                  prefixIcon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'Masukkan email',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nomor Telepon',
                  hint: '08xxxxxxxxxx',
                  controller: _phoneController,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: 'Minimal 6 karakter',
                  controller: _passwordController,
                  validator: Validators.password,
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password',
                  controller: _confirmPasswordController,
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                ),
                const SizedBox(height: 24),

                // Role specific fields
                if (_selectedRole == 'customer') ...[
                  Text('Informasi Bisnis', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Nama Bisnis',
                    hint: 'Restoran Segar Jaya',
                    controller: _businessNameController,
                    validator: (v) => Validators.required(v, 'Nama bisnis'),
                    prefixIcon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jenis Bisnis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _businessType,
                        items: ['Restoran', 'Katering', 'Hotel', 'Lainnya']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _businessType = v!),
                        decoration: const InputDecoration(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Alamat Bisnis',
                    hint: 'Alamat lengkap bisnis',
                    controller: _businessAddressController,
                    validator: (v) => Validators.required(v, 'Alamat bisnis'),
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ] else ...[
                  Text('Informasi Lahan', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Nama Lahan',
                    hint: 'Kebun Subur Makmur',
                    controller: _farmNameController,
                    validator: (v) => Validators.required(v, 'Nama lahan'),
                    prefixIcon: Icons.grass_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Alamat Lahan',
                    hint: 'Alamat lengkap lahan',
                    controller: _farmAddressController,
                    validator: (v) => Validators.required(v, 'Alamat lahan'),
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Luas Lahan (Hektar)',
                    hint: '2.5',
                    controller: _landAreaController,
                    validator: (v) => Validators.positiveNumber(v, 'Luas lahan'),
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.straighten_outlined,
                  ),
                ],
                const SizedBox(height: 32),

                AppButton(
                  label: 'Daftar',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ', style: AppTextStyles.bodyMedium),
                      GestureDetector(
                        onTap: widget.onLogin,
                        child: Text('Masuk', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.labelLarge.copyWith(color: isSelected ? AppColors.primary : AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
