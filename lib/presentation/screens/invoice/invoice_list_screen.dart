import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.invoices),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search invoices
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter invoices
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStats(),
            Expanded(
              child: _buildInvoiceList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create invoice screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.surface),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: 'Total Invoice',
              value: '24',
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.divider,
          ),
          Expanded(
            child: _buildStatItem(
              title: 'Total Nilai',
              value: CurrencyFormatter.formatRupiah(2500000),
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 15, // Placeholder count
      itemBuilder: (context, index) {
        return _buildInvoiceCard(
          invoiceNumber: 'INV${DateTime.now().millisecondsSinceEpoch}$index',
          customerName: 'Customer ${index + 1}',
          total: 150000 + (index * 50000),
          date: DateTime.now().subtract(Duration(days: index)),
          status: index % 3 == 0 ? 'Lunas' : index % 3 == 1 ? 'Pending' : 'Draft',
        );
      },
    );
  }

  Widget _buildInvoiceCard({
    required String invoiceNumber,
    required String customerName,
    required double total,
    required DateTime date,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case 'Lunas':
        statusColor = AppColors.success;
        break;
      case 'Pending':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          // Navigate to invoice detail
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoiceNumber,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    DateFormatter.formatDisplay(date),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.formatRupiah(total),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {
                          // Share invoice
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20.w,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: const Icon(Icons.print_outlined),
                        onPressed: () {
                          // Print invoice
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20.w,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
