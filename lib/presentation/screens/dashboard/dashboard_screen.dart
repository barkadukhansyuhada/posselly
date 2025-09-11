import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../injection_container.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../auth/login_screen.dart';
import '../invoice/invoice_list_screen.dart';
import '../templates/template_list_screen.dart';
import '../products/product_list_screen.dart';
import '../keyboard/keyboard_view.dart';
import '../shipping/shipping_calculator_screen.dart';
import 'stats_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({Key? key}) : super(key: key);

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const InvoiceListScreen(),
    const TemplateListScreen(),
    const ProductListScreen(),
    const KeyboardView(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.surface,
          elevation: 8,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Invoice',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.text_snippet_outlined),
              activeIcon: Icon(Icons.text_snippet),
              label: 'Template',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Produk',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_outlined),
              activeIcon: Icon(Icons.keyboard),
              label: 'Keyboard',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const LoadingWidget();
        }

        if (state is AuthAuthenticated) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(state.user.businessName ?? 'Toko'),
                  SizedBox(height: 24.h),
                  const StatsWidget(),
                  SizedBox(height: 24.h),
                  const BannerAdWidget(),
                  SizedBox(height: 24.h),
                  _buildQuickActions(context),
                  SizedBox(height: 24.h),
                  _buildRecentActivity(),
                ],
              ),
            ),
          );
        }

        return const Center(
          child: Text('Error loading dashboard'),
        );
      },
    );
  }

  Widget _buildHeader(String businessName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang,',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              businessName,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text('Profil'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Pengaturan'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Keluar'),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final quickActions = [
      {
        'icon': Icons.add_circle,
        'title': 'Buat Invoice',
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InvoiceListScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.calculate,
        'title': 'Hitung Ongkir',
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ShippingCalculatorScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.keyboard,
        'title': 'Buka Keyboard',
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const KeyboardView(),
            ),
          );
        },
      },
      {
        'icon': Icons.add_business,
        'title': 'Tambah Produk',
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProductListScreen(),
            ),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppDimensions.gridCrossAxisCount,
            crossAxisSpacing: AppDimensions.gridCrossAxisSpacing.w,
            mainAxisSpacing: AppDimensions.gridMainAxisSpacing.h,
            childAspectRatio: AppDimensions.gridChildAspectRatio,
          ),
          itemCount: quickActions.length,
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return _buildActionCard(
              icon: action['icon'] as IconData,
              title: action['title'] as String,
              onTap: action['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.w,
              color: AppColors.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Terbaru',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48.w,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Belum ada aktivitas',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Mulai buat invoice atau template pertama Anda',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
