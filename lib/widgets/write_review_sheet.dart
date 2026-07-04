import 'package:buysawa/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:buysawa/core/utils/responsive.dart';
import 'package:buysawa/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:buysawa/providers/auth_provider.dart';

class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({super.key});

  static Future<ProductReview?> show(BuildContext context) {
    return showModalBottomSheet<ProductReview>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WriteReviewSheet(),
    );
  }

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();

  void _submit() {
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a comment before submitting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final userName = auth.user?.fullName ?? 'Guest User';
    final userAvatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=00A9A5&color=fff';

    final newReview = ProductReview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      rating: _rating.toDouble(),
      date: DateTime.now(),
      comment: _commentCtrl.text.trim(),
    );

    Navigator.pop(context, newReview);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: R.pad(context, 24),
        right: R.pad(context, 24),
        top: R.pad(context, 24),
        bottom: R.pad(context, 24) + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(R.r(context, 24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: R.sp(context, 18),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: R.pad(context, 24)),
          Text(
            'How would you rate this product?',
            style: TextStyle(
              fontSize: R.sp(context, 14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: R.pad(context, 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index){
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.pad(context, 6)),
                  child: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF5A623),
                    size: R.icon(context, 36),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: R.pad(context, 24)),
          Text(
            'Share your experience',
            style: TextStyle(
              fontSize: R.sp(context, 14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: R.pad(context, 12)),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What did you like or dislike?',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.r(context, 12)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.r(context, 12)),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: R.pad(context, 24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: R.pad(context, 16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(context, 16)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Submit Review',
                style: TextStyle(
                  fontSize: R.sp(context, 14),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
