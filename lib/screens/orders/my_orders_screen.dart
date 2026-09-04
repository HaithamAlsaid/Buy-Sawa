import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/services/order_service.dart';
import '../../models/order_model.dart';
import '../../core/localization/app_localizations.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _orders = [];
  bool _loading = true;

  final _tabs = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _hasError = false;

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final orders = await OrderService.getOrders(perPage: 50);
      if (mounted) {
        setState(() {
          _orders = orders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  List<OrderModel> _filteredOrders(String tab) {
    if (tab == 'All') return _orders;
    return _orders
        .where((o) => o.status.toLowerCase() == tab.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context).locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(R.pad(context, 8)),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
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
          isAr ? 'طلباتي' : 'My Orders',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: R.sp(context, 18),
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: TextStyle(
            fontSize: R.sp(context, 13),
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: R.sp(context, 13),
            fontWeight: FontWeight.w500,
          ),
          tabs: _tabs.map((t) => Tab(text: _tabLabel(t, isAr))).toList(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'حدث خطأ. اسحب للتحديث.' : 'Something went wrong.',
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _loadOrders,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: AppColors.primary,
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      final list = _filteredOrders(tab);
                      if (list.isEmpty) return _buildEmpty(context, isAr);
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.pad(context, 16),
                          vertical: R.pad(context, 16),
                        ),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) =>
                            _OrderCard(order: list[i], isAr: isAr),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  String _tabLabel(String tab, bool isAr) {
    if (!isAr) return tab;
    switch (tab) {
      case 'All': return 'الكل';
      case 'Pending': return 'قيد الانتظار';
      case 'Processing': return 'جارى التجهيز';
      case 'Shipped': return 'تم الشحن';
      case 'Delivered': return 'تم التسليم';
      case 'Cancelled': return 'ملغي';
      default: return tab;
    }
  }

  Widget _buildEmpty(BuildContext context, bool isAr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: R.icon(context, 72),
            color: const Color(0xFFCBD5E1),
          ),
          SizedBox(height: R.pad(context, 16)),
          Text(
            isAr ? 'لا توجد طلبات' : 'No orders yet',
            style: TextStyle(
              fontSize: R.sp(context, 16),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: R.pad(context, 8)),
          Text(
            isAr ? 'ابدأ التسوق الآن!' : 'Start shopping now!',
            style: TextStyle(
              fontSize: R.sp(context, 13),
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isAr;

  const _OrderCard({required this.order, required this.isAr});

  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'delivered': return const Color(0xFF10B981);
      case 'cancelled': return const Color(0xFFEF4444);
      case 'pending': return const Color(0xFFF59E0B);
      case 'processing': return const Color(0xFF0EA5E9);
      case 'shipped': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF94A3B8);
    }
  }

  IconData get _statusIcon {
    switch (order.status.toLowerCase()) {
      case 'delivered': return Icons.check_circle_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      case 'pending': return Icons.schedule_rounded;
      case 'processing': return Icons.settings_rounded;
      case 'shipped': return Icons.local_shipping_rounded;
      default: return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = order.items;
    final displayItems = items.take(3).toList(); // Show max 3 images stacked
    final extraCount = items.length - 3;

    return Container(
      margin: EdgeInsets.only(bottom: R.pad(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Padding(
        padding: EdgeInsets.all(R.pad(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Order ID + Status badge ──────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isAr ? "طلب #" : "Order #"}${order.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: R.sp(context, 14),
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.pad(context, 10),
                    vertical: R.pad(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(R.r(context, 20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: R.icon(context, 12), color: _statusColor),
                      SizedBox(width: R.pad(context, 4)),
                      Text(
                        isAr ? order.statusArabic : order.status,
                        style: TextStyle(
                          fontSize: R.sp(context, 11),
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: R.pad(context, 4)),

            // ── Date ──────────────────────────────────────────
            Text(
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: TextStyle(
                fontSize: R.sp(context, 12),
                color: const Color(0xFF94A3B8),
              ),
            ),

            SizedBox(height: R.pad(context, 14)),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: R.pad(context, 14)),

            // ── Product Images + Name ─────────────────────────
            Row(
              children: [
                // Stacked product images
                if (items.isNotEmpty)
                  SizedBox(
                    width: R.pad(context, 20) * (displayItems.length.clamp(1, 3).toDouble()) + R.pad(context, 40),
                    height: R.pad(context, 52),
                    child: Stack(
                      children: [
                        ...displayItems.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return Positioned(
                            left: i * R.pad(context, 20),
                            child: Container(
                              width: R.pad(context, 52),
                              height: R.pad(context, 52),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(R.r(context, 12)),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(R.r(context, 10)),
                                child: item.productImage.isNotEmpty
                                    ? Image.network(
                                        item.productImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _ProductPlaceholder(index: i),
                                      )
                                    : _ProductPlaceholder(index: i),
                              ),
                            ),
                          );
                        }),
                        // +N more badge
                        if (extraCount > 0)
                          Positioned(
                            left: 3 * R.pad(context, 20),
                            child: Container(
                              width: R.pad(context, 52),
                              height: R.pad(context, 52),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(R.r(context, 12)),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '+$extraCount',
                                  style: TextStyle(
                                    fontSize: R.sp(context, 13),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                SizedBox(width: R.pad(context, 12)),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items.isNotEmpty
                            ? (items.first.productName.isNotEmpty ? items.first.productName : (isAr ? 'منتج' : 'Product'))
                            : (isAr ? 'لا توجد منتجات' : 'No items'),
                        style: TextStyle(
                          fontSize: R.sp(context, 13),
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (items.length > 1) ...[
                        SizedBox(height: R.pad(context, 2)),
                        Text(
                          isAr ? 'و${items.length - 1} منتجات أخرى' : '+ ${items.length - 1} more item${items.length - 1 > 1 ? "s" : ""}',
                          style: TextStyle(
                            fontSize: R.sp(context, 11),
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: R.pad(context, 14)),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: R.pad(context, 12)),

            // ── Footer: Payment + Total ────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (order.paymentMethod != null)
                  Row(
                    children: [
                      Icon(Icons.payment_rounded, size: R.icon(context, 14), color: const Color(0xFF94A3B8)),
                      SizedBox(width: R.pad(context, 4)),
                      Text(
                        order.paymentMethod!,
                        style: TextStyle(
                          fontSize: R.sp(context, 12),
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(),
                Text(
                  '${order.total.toStringAsFixed(2)} ${order.currency}',
                  style: TextStyle(
                    fontSize: R.sp(context, 16),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
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

// ── Product Image Placeholder ─────────────────────────────────────────────────
class _ProductPlaceholder extends StatelessWidget {
  final int index;
  const _ProductPlaceholder({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFEAF5F5),
      const Color(0xFFFFF3E0),
      const Color(0xFFEDE7F6),
    ];
    final iconColors = [
      AppColors.primary,
      const Color(0xFFF5A623),
      const Color(0xFF7E57C2),
    ];
    return Container(
      color: colors[index % colors.length],
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: iconColors[index % iconColors.length],
          size: 22,
        ),
      ),
    );
  }
}

