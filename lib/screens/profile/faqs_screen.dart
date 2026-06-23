import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'q': 'What is Buy SAWA?',
        'a': 'A social commerce app where you shop solo or pool with friends in Group Deals to unlock tiered discounts.',
      },
      {
        'q': 'How do I join a Group Deal?',
        'a': 'Browse active deals on the Deals tab, select a product, and enter the shared group code to pool with friends.',
      },
      {
        'q': 'Is my payment information secure?',
        'a': 'Yes, we use industry-standard encryption and secure payment processors to safeguard your transaction details.',
      },
      {
        'q': 'How long does delivery take?',
        'a': 'Delivery typically takes 2 to 3 business days within the UAE.',
      },
      {
        'q': 'Can I cancel my order?',
        'a': 'You can cancel your order before it gets processed for shipping directly from your order details screen.',
      },
      {
        'q': 'What are SAWA Coins?',
        'a': 'SAWA Coins are loyalty rewards you earn by participating in group buys and referrals, redeemable for discounts on future shopping.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          'FAQs',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.pad(context, 20),
            vertical: R.pad(context, 24),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R.r(context, 24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
            child: Column(
              children: List.generate(faqs.length, (index) {
                final item = faqs[index];
                return Column(
                  children: [
                    _FaqItemTile(
                      question: item['q']!,
                      answer: item['a']!,
                    ),
                    if (index < faqs.length - 1)
                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItemTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItemTile({required this.question, required this.answer});

  @override
  State<_FaqItemTile> createState() => _FaqItemTileState();
}

class _FaqItemTileState extends State<_FaqItemTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(R.r(context, 24)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: R.pad(context, 16),
              vertical: R.pad(context, 18),
            ),
            child: Row(
              children: [
                Container(
                  width: R.pad(context, 40),
                  height: R.pad(context, 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1EEFF), // Light purple
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: const Color(0xFF7C4DFF), // Purple
                      size: R.icon(context, 20),
                    ),
                  ),
                ),
                SizedBox(width: R.pad(context, 14)),
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: R.sp(context, 14),
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94A3B8),
                    size: R.icon(context, 22),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            height: _isExpanded ? null : 0,
            padding: EdgeInsets.only(
              left: R.pad(context, 70), // Aligns answer text with question text
              right: R.pad(context, 16),
              bottom: R.pad(context, 18),
            ),
            child: Text(
              widget.answer,
              style: TextStyle(
                fontSize: R.sp(context, 13),
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
