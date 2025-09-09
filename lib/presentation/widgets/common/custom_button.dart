import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool outlined;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.icon,
    this.outlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppColors.primary;
    final buttonTextColor = textColor ?? 
        (outlined ? buttonColor : AppColors.surface);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppDimensions.buttonHeight.h,
      child: outlined 
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: buttonColor),
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? 
                    BorderRadius.circular(AppDimensions.borderRadius.r),
              ),
            ),
            child: _buildButtonContent(buttonTextColor),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              elevation: AppDimensions.elevationStandard,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? 
                    BorderRadius.circular(AppDimensions.borderRadius.r),
              ),
            ),
            child: _buildButtonContent(buttonTextColor),
          ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          color: textColor,
          strokeWidth: 2,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: AppDimensions.fontBody.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: AppDimensions.fontBody.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}