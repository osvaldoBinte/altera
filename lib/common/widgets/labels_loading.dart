import 'package:altera/common/theme/Theme_colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class LabelsLoading extends StatefulWidget {
  const LabelsLoading({Key? key}) : super(key: key);
  
  @override
  State<LabelsLoading> createState() => _LabelsLoadingState();
}

class _LabelsLoadingState extends State<LabelsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: false);
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AdminColors.backgroundGradient,
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return _buildLabelsSkeleton(context);
          },
        ),
      ),
    );
  }
  
  Widget _buildShimmerBox({required Widget child}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AdminColors.loaddingwithOpacity1,
                AdminColors.loaddingwithOpacity3,
                AdminColors.loaddingwithOpacity1
              ],
              stops: [
                _shimmerAnimation.value - 1,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 1,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  Widget _buildLabelsSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AdminColors.paddingMedium),
      child: Column(
        children: [
        
          Expanded(
            child: _buildLabelsListSkeleton(),
          ),
        ],
      ),
    );
  }



  Widget _buildLabelsListSkeleton() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildLabelCardSkeleton();
      },
    );
  }

  Widget _buildLabelCardSkeleton() {
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AdminColors.paddingMedium),
      decoration: BoxDecoration(
        color: AdminColors.loaddingwithOpacity1,
        borderRadius: AdminColors.mediumBorderRadius,
        border: Border.all(color: AdminColors.loaddingwithOpacity3),
        boxShadow: [AdminColors.lightShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminColors.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: AdminColors.smallBorderRadius,
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: _buildShimmerBox(
                    child: Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AdminColors.loadding,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                _buildShimmerBox(
                  child: Container(
                    height: 12,
                    width: 30,
                    decoration: BoxDecoration(
                      color: AdminColors.loadding,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AdminColors.paddingSmall),
            
            _buildShimmerBox(
              child: Container(
                height: 18,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AdminColors.loadding,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            _buildShimmerBox(
              child: Container(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: AdminColors.loadding,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            const SizedBox(height: AdminColors.paddingSmall),
            
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AdminColors.textSecondaryColor.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                _buildShimmerBox(
                  child: Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AdminColors.loadding,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: AdminColors.paddingMedium),
                Icon(
                  Icons.access_time,
                  color: AdminColors.textSecondaryColor.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildShimmerBox(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AdminColors.loadding,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}