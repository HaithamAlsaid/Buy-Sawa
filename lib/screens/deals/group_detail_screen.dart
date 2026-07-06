import 'package:buysawa/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive.dart';
import 'group_deal_checkout_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupName;
  final List<Map<String, dynamic>> products;

  const GroupDetailScreen({
    super.key,
    required this.groupName,
    required this.products,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(R.pad(context, 8.0)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.textDark,
                size: R.icon(context, 24),
              ),
            ),
          ),
        ),
        title: Text(
          widget.groupName,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(R.pad(context, 20.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Invite Code Section ──────────────────────────
              DottedBorder(
                options: const RoundedRectDottedBorderOptions(
                  color: AppColors.primary,
                  strokeWidth: 1.5,
                  dashPattern: [4, 4],
                  radius: Radius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: R.pad(context, 16),
                    vertical: R.pad(context, 12),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(R.r(context, 20)),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).inviteCode,
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: R.sp(context, 10),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: R.pad(context, 2)),
                          Text(
                            'GB-X72A',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: R.sp(context, 18),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: 'GB-X72A'));
                          setState(() => _isCopied = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() => _isCopied = false);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: R.pad(context, 14),
                            vertical: R.pad(context, 8),
                          ),
                          decoration: BoxDecoration(
                            color: _isCopied
                                ? AppColors.success
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(R.r(context, 20)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isCopied
                                    ? Icons.check_rounded
                                    : Icons.copy_rounded,
                                color: Colors.white,
                                size: R.icon(context, 14),
                              ),
                              SizedBox(width: R.pad(context, 4)),
                              Text(
                                  _isCopied ? (AppLocalizations.of(context).locale.languageCode == 'ar' ? 'تم النسخ' : 'Copied') : AppLocalizations.of(context).copy,
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: R.sp(context, 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: R.pad(context, 32)),
  
              // ── Members Joined Section ───────────────────────
              Text(
                AppLocalizations.of(context).membersJoined,
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: R.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: R.pad(context, 16)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildAvatar(context, 'YO', const Color(0xFF00897B)),
                    SizedBox(width: R.pad(context, 8)),
                    _buildAvatar(context, 'AH', const Color(0xFFF5A623)),
                    SizedBox(width: R.pad(context, 8)),
                    _buildAvatar(context, 'LA', const Color(0xFFD81B60)),
                    SizedBox(width: R.pad(context, 8)),
                    _buildAvatar(context, 'OM', const Color(0xFF7E57C2)),
                    SizedBox(width: R.pad(context, 8)),
                    _buildAvatar(context, 'SA', const Color(0xFF43A047)),
                    SizedBox(width: R.pad(context, 8)),
                    DottedBorder(
                      options: const RoundedRectDottedBorderOptions(
                        color: AppColors.primary,
                        strokeWidth: 1.5,
                        dashPattern: [4, 4],
                        radius: Radius.circular(24),
                      ),
                      child: SizedBox(
                        width: R.pad(context, 44),
                        height: R.pad(context, 44),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: R.icon(context, 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.pad(context, 32)),
  
              // ── Products Section ─────────────────────────────
              Text(
                AppLocalizations.of(context).productsInGroup,
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: R.sp(context, 12),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: R.pad(context, 16)),
              ...widget.products.map(
                (product) => Padding(
                  padding: EdgeInsets.only(bottom: R.pad(context, 12)),
                  child: Container(
                    padding: EdgeInsets.all(R.pad(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(context, 16)),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: R.pad(context, 64),
                          height: R.pad(context, 64),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107), // Yellow placeholder
                            borderRadius: BorderRadius.circular(R.r(context, 12)),
                          ),
                          child: Icon(
                            product['icon'] as IconData? ?? Icons.image,
                            color: Colors.black87,
                            size: R.icon(context, 32),
                          ),
                        ),
                        SizedBox(width: R.pad(context, 16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] as String? ?? 'Product Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: R.sp(context, 14),
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: R.pad(context, 4)),
                              Text(
                                AppLocalizations.of(context).fullPrice,
                                style: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: R.sp(context, 11),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: R.pad(context, 8)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${product['price']} ',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w900,
                                    fontSize: R.sp(context, 16),
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).aed,
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: R.sp(context, 10),
                                  ),
                                ),
                              ],
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(R.pad(context, 20.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: R.pad(context, 56),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupDealCheckoutScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(context, 16)),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).joinPayFullPrice,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: R.sp(context, 16),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.pad(context, 12)),
              Text(
                AppLocalizations.of(context).discountRefundNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF94A3B8), // Slate 400
                  fontSize: R.sp(context, 11),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String text, Color color) {
    return Container(
      width: R.pad(context, 44),
      height: R.pad(context, 44),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: R.sp(context, 14),
          ),
        ),
      ),
    );
  }
}
