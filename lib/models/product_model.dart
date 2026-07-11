class ProductModel {
  final String id;
  final String name;
  final String arabicName;
  final String category;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String>? alternateImages;
  final String description;
  final String arabicDescription;
  final bool hasGroupDeal;
  final int? groupDealDiscount;
  final double? shareEarnPercent;
  final List<ProductReview> reviews;

  ProductModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.alternateImages,
    required this.description,
    required this.arabicDescription,
    this.hasGroupDeal = false,
    this.groupDealDiscount,
    this.shareEarnPercent,
    this.reviews = const [],
  });

  double get discount {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      arabicName: json['arabic_name'] as String? ?? json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String,
      alternateImages: (json['alternate_images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String,
      arabicDescription: json['arabic_description'] as String? ?? json['description'] as String,
      hasGroupDeal: json['has_group_deal'] as bool? ?? false,
      groupDealDiscount: json['group_deal_discount'] as int?,
      shareEarnPercent: (json['share_earn_percent'] as num?)?.toDouble(),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ProductReview {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final DateTime date;
  final String comment;

  ProductReview({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.date,
    required this.comment,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] as String,
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String? ?? '',
      rating: (json['rating'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      comment: json['comment'] as String,
    );
  }
}

// ──── Mock Data ────────────────────────────────────────────────
final List<ProductModel> mockProducts = [
  ProductModel(
    id: 'p1',
    name: 'Sony WH-1000XM5',
    arabicName: 'سوني WH-1000XM5',
    category: 'Electronics',
    price: 1299,
    originalPrice: 1499,
    rating: 4.8,
    reviewCount: 1248,
    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    alternateImages: const [
      'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400',
      'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400',
    ],
    description: 'Industry-leading noise canceling with two processors and eight microphones. 30-hour battery life with quick charge.',
    arabicDescription: 'عزل ضوضاء رائد في الصناعة مع معالجين وثمانية ميكروفونات. عمر بطارية 30 ساعة مع شحن سريع.',
    hasGroupDeal: true,
    groupDealDiscount: 15,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r1',
        userName: 'Ahmed K.',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        comment: 'صوت خرافي وعزل النويز ملوش حل! أفضل سماعة استخدمتها لحد دلوقتي بصراحة وتستاهل كل قرش.',
      ),
      ProductReview(
        id: 'r2',
        userName: 'Sarah M.',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
        rating: 4.5,
        date: DateTime.now().subtract(const Duration(days: 5)),
        comment: 'ممتازة جداً وخفيفة على الراس، بس حسيت المايك في المكالمات كان ممكن يكون أحسن شوية.',
      ),
      ProductReview(
        id: 'r3',
        userName: 'Omar T.',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=a04258114e29026702d',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 12)),
        comment: 'وصلتني متغلفة كويس جداً والأصلي 100%. الشحن سريع والبطارية بتقعد أيام، تجربة شراء ممتازة من التطبيق.',
      ),
    ],
  ),
  ProductModel(
    id: 'p2',
    name: 'Apple Watch Series 9',
    arabicName: 'ساعة أبل الجيل التاسع',
    category: 'Watches',
    price: 1899,
    originalPrice: 2099,
    rating: 4.9,
    reviewCount: 892,
    imageUrl: 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400',
    alternateImages: const [
      'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400',
      'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400',
    ],
    description: 'The most powerful Apple Watch yet. Features the new S9 chip, Double Tap gesture, and brighter display.',
    arabicDescription: 'أقوى ساعة أبل على الإطلاق. تتميز بشريحة S9 الجديدة، وإيماءة النقر المزدوج، وشاشة أكثر سطوعاً.',
    hasGroupDeal: false,
    shareEarnPercent: 7,
    reviews: [
      ProductReview(
        id: 'r4',
        userName: 'Mona Y.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=5',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        comment: 'حركة الدبل تاب بتسهل الاستخدام جداً خصوصاً لو إيدك مشغولة. الشاشة سطوعها جبار في الشمس.',
      ),
    ],
  ),
  ProductModel(
    id: 'p3',
    name: 'Nike Air Max 270',
    arabicName: 'نايك إير ماكس 270',
    category: 'Shoes',
    price: 549,
    originalPrice: 699,
    rating: 4.6,
    reviewCount: 2341,
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    alternateImages: const [
      'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=400',
      'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=400',
    ],
    description: 'The Nike Air Max 270 delivers unparalleled comfort with its large Air unit.',
    arabicDescription: 'يوفر حذاء نايك إير ماكس 270 راحة لا مثيل لها بفضل وحدة Air الكبيرة.',
    hasGroupDeal: true,
    groupDealDiscount: 10,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r5',
        userName: 'Khaled S.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=11',
        rating: 4.5,
        date: DateTime.now().subtract(const Duration(days: 3)),
        comment: 'مريحة جداً في المشي والجري وشكلها شيك، المقاس مضبوط بالملي.',
      ),
      ProductReview(
        id: 'r6',
        userName: 'Nour A.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=12',
        rating: 4.0,
        date: DateTime.now().subtract(const Duration(days: 8)),
        comment: 'جودة الكوتشي حلوة بس السعر كان ممكن يكون أقل شوية.',
      ),
    ],
  ),
  ProductModel(
    id: 'p4',
    name: 'Samsung Galaxy S24',
    arabicName: 'سامسونج جالاكسي S24',
    category: 'Electronics',
    price: 3299,
    originalPrice: 3699,
    rating: 4.7,
    reviewCount: 567,
    imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
    description: 'The Galaxy S24 features the most advanced AI camera system, a stunning 6.2-inch display, and all-day battery.',
    arabicDescription: 'يتميز Galaxy S24 بنظام كاميرا الذكاء الاصطناعي الأكثر تقدماً، وشاشة مذهلة مقاس 6.2 بوصة، وبطارية تدوم طوال اليوم.',
    hasGroupDeal: true,
    groupDealDiscount: 12,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r7',
        userName: 'Ali M.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=13',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        comment: 'كاميرا الذكاء الاصطناعي خرافية. أفضل موبايل نزل السنة دي من غير منازع.',
      ),
    ],
  ),
  ProductModel(
    id: 'p5',
    name: 'Glow Serum Premium',
    arabicName: 'سيروم نضارة فاخر',
    category: 'Women',
    price: 189,
    originalPrice: 249,
    rating: 4.5,
    reviewCount: 3120,
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
    description: 'Advanced brightening serum with vitamin C and hyaluronic acid for glowing skin.',
    arabicDescription: 'سيروم تفتيح متطور مع فيتامين سي وحمض الهيالورونيك لبشرة متوهجة.',
    hasGroupDeal: false,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r8',
        userName: 'Dina E.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=16',
        rating: 4.5,
        date: DateTime.now().subtract(const Duration(days: 10)),
        comment: 'النتيجة بانت من أول أسبوعين، بيخلي البشرة نضرة جداً.',
      ),
      ProductReview(
        id: 'r9',
        userName: 'Yasmin W.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=19',
        rating: 4.0,
        date: DateTime.now().subtract(const Duration(days: 14)),
        comment: 'حلو بس الكمية قليلة شوية مقارنة بالسعر.',
      ),
    ],
  ),
  ProductModel(
    id: 'p6',
    name: 'MacBook Air M3',
    arabicName: 'ماك بوك اير M3',
    category: 'Laptops',
    price: 5499,
    originalPrice: 5999,
    rating: 4.9,
    reviewCount: 445,
    imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
    description: 'Supercharged by M3, MacBook Air is faster and more capable than before.',
    arabicDescription: 'يعمل بشريحة M3، جهاز MacBook Air أسرع وأكثر قدرة من ذي قبل.',
    hasGroupDeal: true,
    groupDealDiscount: 8,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r10',
        userName: 'Mahmoud O.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=33',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 4)),
        comment: 'جهاز يعتمد عليه للشغل والدراسة، بطارية بتكمل اليوم مستريح.',
      ),
    ],
  ),
  ProductModel(
    id: 'p7',
    name: 'Adidas Ultraboost 23',
    arabicName: 'أديداس ألترا بوست 23',
    category: 'Shoes',
    price: 699,
    originalPrice: 849,
    rating: 4.7,
    reviewCount: 1892,
    imageUrl: 'https://images.unsplash.com/photo-1556906781-9a412961a28c?w=400',
    description: 'Responsive BOOST cushioning returns energy with every stride.',
    arabicDescription: 'بطانة BOOST سريعة الاستجابة تعيد الطاقة مع كل خطوة.',
    hasGroupDeal: false,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r11',
        userName: 'Tarek G.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=51',
        rating: 4.5,
        date: DateTime.now().subtract(const Duration(days: 6)),
        comment: 'ممتاز للجري، كأنك بتمشي على سحاب.',
      ),
    ],
  ),
  ProductModel(
    id: 'p8',
    name: 'Canon EOS R50',
    arabicName: 'كانون EOS R50',
    category: 'Cameras',
    price: 3199,
    originalPrice: 3599,
    rating: 4.6,
    reviewCount: 234,
    imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400',
    description: 'Compact mirrorless camera with 24.2MP sensor, 4K video, and AI-powered autofocus.',
    arabicDescription: 'كاميرا بدون مرآة مدمجة مع مستشعر 24.2 ميجابكسل وفيديو بدقة 4K وتركيز تلقائي مدعوم بالذكاء الاصطناعي.',
    hasGroupDeal: true,
    groupDealDiscount: 11,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r12',
        userName: 'Yousef B.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=60',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 20)),
        comment: 'كاميرا مثالية للمبتدئين في التصوير وتصوير الفلوجات.',
      ),
    ],
  ),
  ProductModel(
    id: 'p9',
    name: 'AirPods Pro 2',
    arabicName: 'سماعات أيربودز برو 2',
    category: 'Electronics',
    price: 949,
    originalPrice: 1049,
    rating: 4.8,
    reviewCount: 4210,
    imageUrl: 'https://images.unsplash.com/photo-1606220838315-056192d5e927?w=400',
    description: 'Active Noise Cancellation reduces unwanted background noise. Adaptive Transparency lets outside sounds in while reducing loud environmental noise.',
    arabicDescription: 'يقلل إلغاء الضوضاء النشط من ضوضاء الخلفية غير المرغوب فيها. تسمح لك الشفافية التكيفية بسماع الأصوات الخارجية مع تقليل ضوضاء البيئة الصاخبة.',
    hasGroupDeal: true,
    groupDealDiscount: 10,
    shareEarnPercent: 5,
    reviews: [
      ProductReview(
        id: 'r13',
        userName: 'Hassan K.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=68',
        rating: 4.8,
        date: DateTime.now().subtract(const Duration(days: 2)),
        comment: 'العزل فيها قوي جداً، وصوت البيس ممتاز.',
      ),
    ],
  ),
  ProductModel(
    id: 'p10',
    name: 'Puma RS-X',
    arabicName: 'بوما RS-X',
    category: 'Shoes',
    price: 450,
    originalPrice: 550,
    rating: 4.5,
    reviewCount: 890,
    imageUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=400',
    description: 'The RS-X is back. The future-retro silhouette of this sneaker returns with progressive aesthetic and angular details.',
    arabicDescription: 'عاد RS-X. تعود صورة هذا الحذاء ذو التصميم المستقبلي الكلاسيكي بجمالية تدريجية وتفاصيل زاويّة.',
    hasGroupDeal: false,
    shareEarnPercent: 4,
    reviews: [
      ProductReview(
        id: 'r14',
        userName: 'Ramy W.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=69',
        rating: 4.0,
        date: DateTime.now().subtract(const Duration(days: 18)),
        comment: 'شيك ومختلفة بس محتاجة تتلبس كام مرة عشان تليّن.',
      ),
    ],
  ),
  ProductModel(
    id: 'p11',
    name: 'Logitech MX Master 3S',
    arabicName: 'لوجيتك MX Master 3S',
    category: 'Electronics',
    price: 399,
    originalPrice: 499,
    rating: 4.9,
    reviewCount: 1530,
    imageUrl: 'https://images.unsplash.com/photo-1586816879360-004f5b0c51e3?w=400',
    description: 'Performance wireless mouse with an 8K DPI track-on-glass sensor and Quiet Clicks.',
    arabicDescription: 'ماوس لاسلكي عالي الأداء مزود بمستشعر تتبع على الزجاج بدقة 8K DPI ونقرات هادئة.',
    hasGroupDeal: true,
    groupDealDiscount: 15,
    shareEarnPercent: 6,
    reviews: [
      ProductReview(
        id: 'r15',
        userName: 'Mostafa H.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=70',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 25)),
        comment: 'ماوس جبار للمبرمجين والمصممين، مريح جداً للإيد.',
      ),
    ],
  ),
  ProductModel(
    id: 'p12',
    name: 'Nespresso Vertuo Next',
    arabicName: 'نسبريسو فيرتو نكست',
    category: 'Electronics',
    price: 699,
    originalPrice: 899,
    rating: 4.7,
    reviewCount: 320,
    imageUrl: 'https://images.unsplash.com/photo-1596079827161-5cb14002641e?w=400',
    description: 'Nespresso Vertuo Next takes the full range of Nespresso coffee styles even further with its innovative Centrifusion technology.',
    arabicDescription: 'ترتقي آلة Nespresso Vertuo Next بالمجموعة الكاملة من أنماط قهوة نسبريسو إلى أبعد من ذلك بتقنية Centrifusion المبتكرة.',
    hasGroupDeal: false,
    shareEarnPercent: 3,
    reviews: [
      ProductReview(
        id: 'r16',
        userName: 'Mai O.',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=43',
        rating: 4.7,
        date: DateTime.now().subtract(const Duration(days: 1)),
        comment: 'قهوة ممتازة وسريعة، والوش بيطلع مظبوط دايماً.',
      ),
    ],
  ),
];
