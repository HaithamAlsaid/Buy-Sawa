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

  final _tabs = ['All', 'Pending', 'Processing', 'Delivered', 'Cancelled'];

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

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await OrderService.getOrders(perPage: 50);
    if (mounted) {
      setState(() {
        _orders = orders;
        _loading = false;
      });
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
      default: return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

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
            // Top row: Order ID + Status
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
                  child: Text(
                    isAr ? order.statusArabic : order.status,
                    style: TextStyle(
                      fontSize: R.sp(context, 11),
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.pad(context, 4)),
            // Date
            Text(
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: TextStyle(
                fontSize: R.sp(context, 12),
                color: const Color(0xFF94A3B8),
              ),
            ),
            if (firstItem != null) ...[
              SizedBox(height: R.pad(context, 12)),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: R.pad(context, 12)),
              // First product name + items count
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: R.icon(context, 18),
                    color: const Color(0xFF94A3B8),
                  ),
                  SizedBox(width: R.pad(context, 8)),
                  Expanded(
                    child: Text(
                      firstItem.productName.isNotEmpty
                          ? firstItem.productName
                          : (isAr ? 'منتج' : 'Product'),
                      style: TextStyle(
                        fontSize: R.sp(context, 13),
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (order.items.length > 1)
                    Text(
                      '+${order.items.length - 1} ${isAr ? "أخرى" : "more"}',
                      style: TextStyle(
                        fontSize: R.sp(context, 11),
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ],
            SizedBox(height: R.pad(context, 12)),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: R.pad(context, 12)),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'الإجمالي' : 'Total',
                  style: TextStyle(
                    fontSize: R.sp(context, 13),
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${order.total.toStringAsFixed(2)} ${order.currency}',
                  style: TextStyle(
                    fontSize: R.sp(context, 15),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
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
