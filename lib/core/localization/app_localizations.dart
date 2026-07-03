import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _t(String key) =>
      _translations[locale.languageCode]?[key] ??
      _translations['en']![key] ??
      key;

  //General 
  String get appName => 'BuySawa';
  String get ok => _t('ok');
  String get cancel => _t('cancel');
  String get save => _t('save');
  String get search => _t('search');
  String get seeAll => _t('seeAll');
  String get apply => _t('apply');
  String get logout => _t('logout');
  String get version => _t('version');

  // ─── Auth ────────────────────────────────────────────────────
  String get login => _t('login');
  String get register => _t('register');
  String get email => _t('email');
  String get password => _t('password');
  String get fullName => _t('fullName');
  String get phone => _t('phone');
  String get referralCode => _t('referralCode');
  String get forgotPassword => _t('forgotPassword');
  String get continueWithGoogle => _t('continueWithGoogle');
  String get dontHaveAccount => _t('dontHaveAccount');
  String get createAccount => _t('createAccount');
  String get alreadyHaveAccount => _t('alreadyHaveAccount');
  String get welcomeBack => _t('welcomeBack');
  String get signInToContinue => _t('signInToContinue');
  String get loginSubtitle => _t('loginSubtitle');
  String get browseAsGuest => _t('browseAsGuest');
  String get signInToUnlock => _t('signInToUnlock');

  // ─── Navigation ──────────────────────────────────────────────
  String get home => _t('home');
  String get categories => _t('categories');
  String get deals => _t('deals');
  String get wallet => _t('wallet');
  String get profile => _t('profile');

  // ─── Home ────────────────────────────────────────────────────
  String get featured => _t('featured');
  String get shareAndEarn => _t('shareAndEarn');
  String get shareEarnSubtitle => _t('shareEarnSubtitle');
  String get trendingNow => _t('trendingNow');
  String get groupDeal => _t('groupDeal');
  String get addToCart => _t('addToCart');
  String get buyNow => _t('buyNow');

  // ─── Categories ──────────────────────────────────────────────
  String get categoriesCount => _t('categoriesCount');

  // ─── Deals ───────────────────────────────────────────────────
  String get myDeals => _t('myDeals');
  String get activeGroupBuys => _t('activeGroupBuys');
  String get activeGroupBuysSubtitle => _t('activeGroupBuysSubtitle');
  String get startNewGroupBuy => _t('startNewGroupBuy');
  String get startGroupSubtitle => _t('startGroupSubtitle');
  String get orJoinExisting => _t('orJoinExisting');
  String get enterGroupCode => _t('enterGroupCode');
  String get joinGroup => _t('joinGroup');
  String get members => _t('members');
  String get active => _t('active');
  String get expired => _t('expired');

  // ─── Wallet ──────────────────────────────────────────────────
  String get myWallet => _t('myWallet');
  String get availableBalance => _t('availableBalance');
  String get transactionHistory => _t('transactionHistory');
  String get cashback => _t('cashback');
  String get referralBonus => _t('referralBonus');
  String get purchase => _t('purchase');
  String get groupReward => _t('groupReward');
  String get today => _t('today');
  String get yesterday => _t('yesterday');

  // ─── Profile / Account ───────────────────────────────────────
  String get account => _t('account');
  String get editProfile => _t('editProfile');
  String get helpCenter => _t('helpCenter');
  String get faqs => _t('faqs');
  String get contactUs => _t('contactUs');
  String get language => _t('language');
  String get deleteAccount => _t('deleteAccount');
  String get birthdate => _t('birthdate');
  String get securityReadOnly => _t('securityReadOnly');
  String get saveChanges => _t('saveChanges');
  String get confirm => _t('confirm');
  String get loginToViewProfile => _t('loginToViewProfile');
  String get myFavourites => _t('myFavourites');

  // ─── Language ────────────────────────────────────────────────
  String get chooseLanguage => _t('chooseLanguage');
  String get languageSubtitle => _t('languageSubtitle');

  // ─── Contact ─────────────────────────────────────────────────
  String get yourMessage => _t('yourMessage');
  String get messagePlaceholder => _t('messagePlaceholder');
  String get sendMessage => _t('sendMessage');
  String get orReachDirectly => _t('orReachDirectly');
  String get callUs => _t('callUs');
  String get emailUs => _t('emailUs');
  String get supportAvailable => _t('supportAvailable');

  // ─── Referral ────────────────────────────────────────────────
  String get myReferralCode => _t('myReferralCode');
  String get referralSubtitle => _t('referralSubtitle');
  String get shareCode => _t('shareCode');
  String get totalEarned => _t('totalEarned');
  String get friendsJoined => _t('friendsJoined');

  // ─── Auth Gate ───────────────────────────────────────────────
  String get signInRequired => _t('signInRequired');
  String get signInRequiredSubtitle => _t('signInRequiredSubtitle');

  // ─── Product ─────────────────────────────────────────────────
  String get reviews => _t('reviews');
  String get description => _t('description');
  String get shareAndEarnCashback => _t('shareAndEarnCashback');
  String get startGroupBuy => _t('startGroupBuy');
  String get off => _t('off');
  String get productDetails => _t('productDetails');
  String get specifications => _t('specifications');
  String get viewAllSpecs => _t('viewAllSpecs');
  String get reviewsAndComments => _t('reviewsAndComments');

  // ─── Cart ──────────────────────────────────────────────────
  String get myCart => _t('myCart');
  String get viewCart => _t('viewCart');
  String get subtotal => _t('subtotal');
  String get shipping => _t('shipping');
  String get total => _t('total');
  String get proceedToCheckout => _t('proceedToCheckout');
  String get signInToCheckout => _t('signInToCheckout');
  String get yourCartIsEmpty => _t('yourCartIsEmpty');
  String get continueShopping => _t('continueShopping');
  String get orderPlaced => _t('orderPlaced');
  String get orderPlacedSuccessfully => _t('orderPlacedSuccessfully');

  // ─── Onboarding ──────────────────────────────────────────────
  String get skip => _t('skip');
  String get next => _t('next');
  String get getStarted => _t('getStarted');
  String get onboarding1Title => _t('onboarding1Title');
  String get onboarding1Desc => _t('onboarding1Desc');
  String get onboarding1Tag => _t('onboarding1Tag');
  String get onboarding2Title => _t('onboarding2Title');
  String get onboarding2Desc => _t('onboarding2Desc');
  String get onboarding2Tag => _t('onboarding2Tag');
  String get onboarding3Title => _t('onboarding3Title');
  String get onboarding3Desc => _t('onboarding3Desc');
  String get onboarding3Tag => _t('onboarding3Tag');
  String get startShopping => _t('startShopping');

  // ════════════════════════════════════════════════════════════
  // TRANSLATIONS MAP
  // ════════════════════════════════════════════════════════════
  static const Map<String, Map<String, String>> _translations = {
    //ENGLISH 
    'en': {
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'search': 'Search products...',
      'seeAll': 'See all ›',
      'apply': 'Apply',
      'logout': 'Logout',
      'version': 'Buy SAWA · v1.0.0',
      'login': 'Login',
      'register': 'Create Account',
      'email': 'Email Address',
      'password': 'Password',
      'fullName': 'Full Name',
      'phone': 'Phone Number',
      'referralCode': 'Referral Code (optional)',
      'forgotPassword': 'Forgot Password?',
      'continueWithGoogle': 'Continue with Google',
      'dontHaveAccount': "Don't have an account?",
      'createAccount': 'Create Account',
      'alreadyHaveAccount': 'Already have an account?',
      'welcomeBack': 'Welcome back 👋',
      'signInToContinue': 'Sign in to continue',
      'loginSubtitle': 'Login to unlock cashback, group deals & VIP perks',
      'browseAsGuest': 'Browse as Guest',
      'signInToUnlock': 'Sign in to unlock this feature',
      'home': 'Home',
      'categories': 'Categories',
      'deals': 'Deals',
      'wallet': 'Wallet',
      'profile': 'Profile',
      'featured': 'FEATURED',
      'shareAndEarn': 'Share & Earn Cashback',
      'shareEarnSubtitle': 'Every share earns you up to ',
      'trendingNow': 'Trending Now',
      'groupDeal': 'Group Deal',
      'addToCart': 'Add to Cart',
      'buyNow': 'Buy Now',
      'categoriesCount': '13 categories',
      'myDeals': 'MY DEALS',
      'activeGroupBuys': 'Active Group Buys',
      'activeGroupBuysSubtitle': "Track every group you've joined or started.",
      'startNewGroupBuy': 'Start a new Group Buy',
      'startGroupSubtitle': 'Pool with friends to unlock up to  off',
      'orJoinExisting': 'OR JOIN AN EXISTING GROUP',
      'enterGroupCode': 'Enter Group Code (e.g., GB-X7..)',
      'joinGroup': 'Join Group',
      'members': 'members',
      'active': 'ACTIVE',
      'expired': 'EXPIRED',
      'myWallet': 'Wallet',
      'availableBalance': 'AVAILABLE BALANCE',
      'transactionHistory': 'Transaction History',
      'cashback': 'Cashback',
      'referralBonus': 'Referral Bonus',
      'purchase': 'Purchase',
      'groupReward': 'Group Deal Reward',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'account': 'ACCOUNT',
      'editProfile': 'Profile',
      'helpCenter': 'Help Center',
      'faqs': 'FAQs',
      'contactUs': 'Contact Us',
      'language': 'Language',
      'myFavourites': 'My Favourites',
      'confirm': 'Confirm',
      'loginToViewProfile': 'Please login to view profile details.',
      'deleteAccount': 'Delete Account',
      'birthdate': 'BIRTHDATE',
      'securityReadOnly': 'SECURITY · READ ONLY',
      'saveChanges': 'Save Changes',
      'chooseLanguage': 'Choose Language',
      'languageSubtitle': 'The app will switch instantly to your choice',
      'yourMessage': 'YOUR MESSAGE',
      'messagePlaceholder': 'Tell us how we can help you today...',
      'sendMessage': 'Send Message',
      'orReachDirectly': 'OR REACH US DIRECTLY',
      'callUs': 'CALL US',
      'emailUs': 'EMAIL US',
      'supportAvailable': 'Support team available 24/7',
      'myReferralCode': 'My Referral Code',
      'referralSubtitle': 'Share your code & earn 5% for every purchase',
      'shareCode': 'Share My Code',
      'totalEarned': 'Total Earned',
      'friendsJoined': 'Friends Joined',
      'signInRequired': 'Sign In Required',
      'signInRequiredSubtitle':
          'Create an account to access cart, wallet & group deals',
      'reviews': 'reviews',
      'description': 'Description',
      'shareAndEarnCashback': 'Share & Earn 5% Cashback',
      'startGroupBuy': 'Start Group Buy',
      'off': 'off',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get Started',
      'onboarding1Tag': "LET'S GO",
      'onboarding1Title': 'Ready to\nBuy SAWA?',
      'onboarding1Desc':
          'Join thousands of smart shoppers already saving together every day.',
      'onboarding2Tag': 'GROUP BUYING',
      'onboarding2Title': 'Shop Together,\nSave More',
      'onboarding2Desc':
          'Join forces with friends and family. The more you squad up, the bigger the discount everyone gets.',
      'onboarding3Tag': 'FAST & SECURE',
      'onboarding3Title': 'Safe & Quick\nDelivery',
      'onboarding3Desc':
          'Enjoy secure payments and fast delivery straight to your doorstep for every order.',
      'startShopping': 'Start Shopping',
      'productDetails': 'Product Details',
      'specifications': 'Specifications',
      'viewAllSpecs': 'View all technical specifications →',
      'myCart': 'My Cart',
      'subtotal': 'Subtotal',
      'shipping': 'Shipping',
      'total': 'Total',
      'proceedToCheckout': 'Proceed to Checkout',
      'signInToCheckout': 'Sign In to Checkout',
      'yourCartIsEmpty': 'Your cart is empty',
      'continueShopping': 'Continue Shopping',
      'orderPlaced': 'Order Placed!',
      'orderPlacedSuccessfully': 'Your order has been placed successfully!',
      'viewCart': 'View Cart',
      'reviewsAndComments': 'Reviews & Comments',
    },

    //ARABIC
    'ar': {
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'search': 'دوّر على منتجات...',
      'seeAll': 'عرض الكل ›',
      'apply': 'تطبيق',
      'logout': 'تسجيل خروج',
      'version': 'باي ساوا · v1.0.0',
      'login': 'دخول',
      'register': 'سجل حساب',
      'email': 'الإيميل',
      'password': 'كلمة السر',
      'fullName': 'الاسم الكامل',
      'phone': 'رقم الموبايل',
      'referralCode': 'كود الدعوة (اختياري)',
      'forgotPassword': 'نسيت كلمة السر؟',
      'continueWithGoogle': 'كمل مع جوجل',
      'dontHaveAccount': 'ما عندك حساب؟',
      'createAccount': 'سجل حساب',
      'alreadyHaveAccount': 'عندك حساب؟',
      'welcomeBack': 'يا هلا فيك 👋',
      'signInToContinue': 'سجل دخول عشان تكمل',
      'loginSubtitle': 'سجل عشان تاخذ كاش باك وخصومات جماعية و VIP',
      'browseAsGuest': 'تصفح كزائر',
      'signInToUnlock': 'سجل دخول عشان تفتح هالميزة',
      'home': 'الرئيسية',
      'categories': 'الأقسام',
      'deals': 'العروض',
      'wallet': 'المحفظة',
      'profile': 'حسابي',
      'featured': 'مميز',
      'shareAndEarn': 'شارك واربح كاش باك',
      'shareEarnSubtitle': 'كل مشاركة تربحك لين 5%',
      'trendingNow': 'الترند الحين',
      'groupDeal': 'عرض جماعي',
      'addToCart': 'ضف للسلة',
      'buyNow': 'اشتر ألحين',
      'categoriesCount': '13 قسم',
      'myDeals': 'عروضي',
      'activeGroupBuys': 'الشراء الجماعي الشغال',
      'activeGroupBuysSubtitle': 'تابع كل مجموعة دخلت فيها أو سويتها.',
      'startNewGroupBuy': 'ابدأ شراء جماعي جديد',
      'startGroupSubtitle': 'تجمع ويا ربعك لخصم ',
      'orJoinExisting': 'أو ادخل مجموعة موجودة',
      'enterGroupCode': 'دخل كود المجموعة (مثل: GB-X7..)',
      'joinGroup': 'ادخل المجموعة',
      'members': 'أعضاء',
      'active': 'شغال',
      'expired': 'منتهي',
      'myWallet': 'المحفظة',
      'availableBalance': 'الرصيد المتوفر',
      'transactionHistory': 'سجل العمليات',
      'cashback': 'كاش باك',
      'referralBonus': 'مكافأة دعوة',
      'purchase': 'شراء',
      'groupReward': 'مكافأة المجموعة',
      'today': 'اليوم',
      'yesterday': 'البارحة',
      'account': 'الحساب',
      'editProfile': 'حسابي',
      'helpCenter': 'مركز المساعدة',
      'faqs': 'الأسئلة الشائعة',
      'contactUs': 'تواصل ويانا',
      'language': 'اللغة',
      'myFavourites': 'المفضلة',
      'confirm': 'تأكيد',
      'loginToViewProfile': 'يرجى تسجيل الدخول لعرض تفاصيل الحساب.',
      'deleteAccount': 'احذف الحساب',
      'birthdate': 'تاريخ الميلاد',
      'securityReadOnly': 'الأمان · قراءة فقط',
      'saveChanges': 'حفظ التغييرات',
      'chooseLanguage': 'اختار اللغة',
      'languageSubtitle': 'التطبيق بيتغير فورا لاختيارك',
      'yourMessage': 'رسالتك',
      'messagePlaceholder': 'خبرنا كيف نقدر نساعدك اليوم...',
      'sendMessage': 'طرش الرسالة',
      'orReachDirectly': 'أو تواصل ويانا مباشرة',
      'callUs': 'اتصل بنا',
      'emailUs': 'راسلنا',
      'supportAvailable': 'فريق الدعم متوفر 24/7',
      'myReferralCode': 'كود الدعوة مالي',
      'referralSubtitle': 'شارك كودك واربح 5% من كل شراء',
      'shareCode': 'شارك كودي',
      'totalEarned': 'مجموع الأرباح',
      'friendsJoined': 'ربعك اللي دخلوا',
      'signInRequired': 'لازم تسجل دخول',
      'signInRequiredSubtitle': 'سجل حساب عشان تدخل السلة والمحفظة',
      'reviews': 'تقييم',
      'description': 'الوصف',
      'shareAndEarnCashback': 'شارك واربح 5% كاش باك',
      'startGroupBuy': 'ابدأ شراء جماعي',
      'off': 'خصم',
      'skip': 'تخطي',
      'next': 'التالي',
      'getStarted': 'ابدأ التسوق',
      'onboarding1Tag': 'يلّا نبدأ',
      'onboarding1Title': 'مستعد تشتري\nمع ربعك؟',
      'onboarding1Desc':
          'انضم لآلاف المتسوقين الذكيين اللي يوفّرون ويتمتعون ويربحون كل يوم.',
      'onboarding2Tag': 'شراء جماعي',
      'onboarding2Title': 'اتجمعوا واشتروا،\nوفّروا أكثر',
      'onboarding2Desc':
          'تجمّع ويا ربعك وعيلتك. كل ما زادت المجموعة، كل ما كبر الخصم للكل.',
      'onboarding3Tag': 'سريع وآمن',
      'onboarding3Title': 'توصيل آمن\nوسريع',
      'onboarding3Desc': 'استمتع بدفع آمن وتوصيل سريع لباب بيتك في كل طلب.',
      'startShopping': 'ابدأ التسوق',
      'productDetails': 'تفاصيل المنتج',
      'specifications': 'المواصفات',
      'viewAllSpecs': 'عرض كل المواصفات التقنية ←',
      'myCart': 'سلتي',
      'subtotal': 'المجموع الفرعي',
      'shipping': 'الشحن',
      'total': 'الإجمالي',
      'proceedToCheckout': 'متابعة للدفع',
      'signInToCheckout': 'سجل دخول للدفع',
      'yourCartIsEmpty': 'سلتك فاضية',
      'continueShopping': 'كمل تسوق',
      'orderPlaced': 'تم الطلب!',
      'orderPlacedSuccessfully': 'تم تسجيل طلبك بنجاح!',
      'viewCart': 'عرض السلة',
      'reviewsAndComments': 'التقييمات والتعليقات',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
