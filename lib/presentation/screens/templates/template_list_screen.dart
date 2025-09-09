import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.templates),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add template screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildCategoryFilter(),
              SizedBox(height: 16.h),
              Expanded(
                child: _buildTemplateList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Semua', 'Salam', 'Promosi', 'Konfirmasi', 'Pengiriman'];
    
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == 0;
          
          return Container(
            margin: EdgeInsets.only(right: 12.w),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                // Handle category selection
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateList() {
    return ListView.builder(
      itemCount: 5, // Placeholder count
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.text_snippet,
                color: AppColors.primary,
              ),
            ),
            title: Text('Template ${index + 1}'),
            subtitle: const Text('Selamat datang di toko kami...'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Text('Salin'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus'),
                ),
              ],
            ),
            onTap: () {
              // Use template
            },
          ),
        );
      },
    );
  }
}
