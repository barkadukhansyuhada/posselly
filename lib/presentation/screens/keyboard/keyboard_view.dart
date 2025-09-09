import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class KeyboardView extends StatelessWidget {
  const KeyboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.keyboard),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open keyboard settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKeyboardStatus(),
              SizedBox(height: 24.h),
              _buildQuickTemplates(),
              SizedBox(height: 24.h),
              _buildQuickActions(),
              SizedBox(height: 24.h),
              _buildKeyboardPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardStatus() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.keyboard,
                color: AppColors.primary,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Status Keyboard',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Keyboard Selly',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Keyboard telah diaktifkan dan siap digunakan di aplikasi pesan Anda.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Template Cepat',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all templates
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 200.w,
                margin: EdgeInsets.only(right: 12.w),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Template ${index + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Expanded(
                          child: Text(
                            'Selamat datang di toko kami! Kami menyediakan berbagai produk berkualitas dengan harga terjangkau...',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () {
                            // Use template
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: Size(double.infinity, 28.h),
                          ),
                          child: Text(
                            'Gunakan',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.receipt_long, 'title': 'Buat Invoice', 'color': AppColors.primary},
      {'icon': Icons.calculate, 'title': 'Hitung Ongkir', 'color': AppColors.secondary},
      {'icon': Icons.inventory, 'title': 'Cek Stok', 'color': AppColors.info},
      {'icon': Icons.local_shipping, 'title': 'Lacak Paket', 'color': AppColors.success},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                child: InkWell(
                  onTap: () {
                    // Handle action
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 24.w,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          action['title'] as String,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKeyboardPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview Keyboard',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              // Keyboard header with templates
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.text_snippet,
                      color: AppColors.primary,
                      size: 16.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Template Selly',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: AppColors.primary,
                      size: 16.w,
                    ),
                  ],
                ),
              ),
              // Keyboard buttons preview
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 2.5,
                    children: [
                      'Salam',
                      'Promosi',
                      'Konfirmasi',
                      'Ongkir',
                      'Invoice',
                      'Stok',
                    ].map((text) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Center(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
