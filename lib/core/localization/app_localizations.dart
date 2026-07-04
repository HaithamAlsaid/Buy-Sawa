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
  String get joinSawa => _t('joinSawa');
  String get joinSawaSubtitle => _t('joinSawaSubtitle');

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
  String get addedToCart => _t('addedToCart');
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

  //Profile / Account
  String get account => _t('account');
  String get editProfile => _t('editProfile');
  String get helpCenter => _t('helpCenter');
  String get faqs => _t('faqs');
  String get contactUs => _t('contactUs');
  String get language => _t('language');
  String get deleteAccount => _t('deleteAccount');
  String get deleteAccountPermanent => _t('deleteAccountPermanent');
  String get deleteAccountDesc => _t('deleteAccountDesc');
  String get youWillLose => _t('youWillLose');
  String walletBalanceLoss(String amount) => _t('walletBalanceLoss').replaceAll('{amount}', amount);
  String get orderHistoryLoss => _t('orderHistoryLoss');
  String get savedAddressesLoss => _t('savedAddressesLoss');
  String get referralBonusLoss => _t('referralBonusLoss');
  String get typeDeleteToConfirm => _t('typeDeleteToConfirm');
  String get deleteText => _t('deleteText');
  String get permanentlyDeleteAccount => _t('permanentlyDeleteAccount');
  String get birthdate => _t('birthdate');
  String get securityReadOnly => _t('securityReadOnly');
  String get saveChanges => _t('saveChanges');
  String get confirm => _t('confirm');
  String get loginToViewProfile => _t('loginToViewProfile');
  String get myFavourites => _t('myFavourites');
  String get accountTitle => _t('accountTitle');

  String get welcomeBackTitle => _t('welcomeBackTitle');
  String get shareProductDesc => _t('shareProductDesc');
  String get startGroupBuyDesc => _t('startGroupBuyDesc');
  String get newBadge => _t('newBadge');
  String get hotBadge => _t('hotBadge');
  String get flashSale => _t('flashSale');
  String get flashSaleDesc => _t('flashSaleDesc');
  String get cashbackBadge => _t('cashbackBadge');
  String get earnCashback => _t('earnCashback');
  String get earnCashbackDesc => _t('earnCashbackDesc');

  // ─── Group Buy & Checkout ──────────────────────────────────────────────
  String get groupName => _t('groupName');
  String get addProductsBtn => _t('addProductsBtn');
  String get selectedProducts => _t('selectedProducts');
  String get createGroupInvite => _t('createGroupInvite');
  String get addItemsToPool => _t('addItemsToPool');
  String get searchProductCode => _t('searchProductCode');
  String get filterNew => _t('filterNew');
  String get filterTopBrands => _t('filterTopBrands');
  String get filterPriceLow => _t('filterPriceLow');
  String get filterPriceHigh => _t('filterPriceHigh');
  String get addBtn => _t('addBtn');
  String get inviteCode => _t('inviteCode');
  String get copy => _t('copy');
  String get membersJoined => _t('membersJoined');
  String get productsInGroup => _t('productsInGroup');
  String get fullPrice => _t('fullPrice');
  String get joinPayFullPrice => _t('joinPayFullPrice');
  String get discountRefundNote => _t('discountRefundNote');
  String get groupDealCheckout => _t('groupDealCheckout');
  String get locked => _t('locked');
  String qty(int count) => _t('qty').replaceAll('{qty}', count.toString());
  String get lockedGroupDeal => _t('lockedGroupDeal');
  String get groupDealNote => _t('groupDealNote');
  String get cashbackCreditedAfter => _t('cashbackCreditedAfter');
  String get totalFullPrice => _t('totalFullPrice');
  String get secureLock => _t('secureLock');
  String get payFullAndLock => _t('payFullAndLock');
  String get choosePaymentMethod => _t('choosePaymentMethod');
  String totalAmount(String amount) => _t('totalAmount').replaceAll('{amount}', amount);
  String get popular => _t('popular');
  String get payIn4Tabby => _t('payIn4Tabby');
  String get buyNowPayLaterTamara => _t('buyNowPayLaterTamara');
  String get instant => _t('instant');
  String get creditDebitCard => _t('creditDebitCard');
  String get cardsAccepted => _t('cardsAccepted');
  String get selectPaymentMethod => _t('selectPaymentMethod');
  String get securedBy => _t('securedBy');
  String get joinBtn => _t('joinBtn');
  String get enjoyDiscounts => _t('enjoyDiscounts');
  String expiredTab(int count) => _t('expiredTab').replaceAll('{count}', count.toString());
  String activeTab(int count) => _t('activeTab').replaceAll('{count}', count.toString());
  String get allGroupsTab => _t('allGroupsTab');

  // FAQs
  String get faq1q => _t('faq1q');
  String get faq2q => _t('faq2q');
  String get faq3q => _t('faq3q');
  String get faq4q => _t('faq4q');
  String get faq5q => _t('faq5q');
  String get faq6q => _t('faq6q');


  String get chooseLanguage => _t('chooseLanguage');
  String get languageSubtitle => _t('languageSubtitle');

  //Contact 
  String get yourMessage => _t('yourMessage');
  String get messagePlaceholder => _t('messagePlaceholder');
  String get sendMessage => _t('sendMessage');
  String get orReachDirectly => _t('orReachDirectly');
  String get callUs => _t('callUs');
  String get emailUs => _t('emailUs');
  String get supportAvailable => _t('supportAvailable');

  // Referral 
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

  // ─── Messages / Snackbars ──────────────────────────────────────
  String get changesSaved => _t('changesSaved');
  String removedFromFav(String name) =>
      _t('removedFromFav').replaceAll('{name}', name);
  String get accountDeleted => _t('accountDeleted');
  String get messageSent => _t('messageSent');
  String groupCodeInvalid(String code) =>
      _t('groupCodeInvalid').replaceAll('{code}', code);
  String items(int count) => _t('items').replaceAll('{count}', count.toString());
  String get noFavouritesYet => _t('noFavouritesYet');
  String get loginToSend => _t('loginToSend');
  String get aed => _t('aed');
  String get colorDefaultSizeStandard => _t('colorDefaultSizeStandard');

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
      'joinSawa': 'Join the SAWA squad 🎉',
      'joinSawaSubtitle': 'Join Buy SAWA for exclusive group deals & cashback!',
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
      'addedToCart': 'added to cart',
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
      'deleteAccountPermanent': 'This action is permanent',
      'deleteAccountDesc': 'Deleting your account will remove your profile, orders, wallet balance, and cashback rewards. This cannot be undone.',
      'youWillLose': 'YOU WILL LOSE',
      'walletBalanceLoss': '{amount} AED wallet balance',
      'orderHistoryLoss': 'Order history and tracking',
      'savedAddressesLoss': 'Saved addresses and payment methods',
      'referralBonusLoss': 'Referral bonuses and VIP rank progress',
      'typeDeleteToConfirm': 'TYPE "DELETE" TO CONFIRM',
      'deleteText': 'DELETE',
      'permanentlyDeleteAccount': 'Permanently Delete Account',
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
      'changesSaved': 'Changes saved successfully!',
      'removedFromFav': '{name} removed from favourites',
      'accountDeleted': 'Account deleted successfully.',
      'messageSent': 'Message sent! We\'ll get back to you soon.',
      'groupCodeInvalid': 'Group code "{code}" not found or expired.',
      'items': '{count} items',
      'noFavouritesYet': 'No favourites yet',
      'loginToSend': 'Login to send a message',
      'aed': 'AED',
      'colorDefaultSizeStandard': 'Color: Default | Size: Standard',
      'accountTitle': 'ACCOUNT',

      'shareProductDesc': 'Share this product and get cashback on purchases!',
      'startGroupBuyDesc': 'Start a Group Buy with friends for a bigger discount.',
      'newBadge': 'NEW',
      'hotBadge': 'HOT',
      'flashSale': 'Flash Sale',
      'flashSaleDesc': 'Up to 40% off on selected items today',
      'cashbackBadge': 'CASHBACK',
      'earnCashback': 'Earn Cashback',
      'earnCashbackDesc': 'Get cashback on every group purchase',
      'groupName': 'GROUP NAME',
      'addProductsBtn': 'Add Products +',
      'selectedProducts': 'SELECTED PRODUCTS',
      'createGroupInvite': 'Create Group & Get Invite Link',
      'addItemsToPool': 'Add Items to Pool',
      'searchProductCode': 'Search by Product Name or Code',
      'filterNew': 'New',
      'filterTopBrands': 'Top Brands',
      'filterPriceLow': '↓ Price',
      'filterPriceHigh': '↑ Price',
      'addBtn': 'Add +',
      'inviteCode': 'INVITE CODE',
      'copy': 'Copy',
      'membersJoined': 'MEMBERS JOINED',
      'productsInGroup': 'PRODUCTS IN GROUP',
      'fullPrice': 'Full Price',
      'joinPayFullPrice': 'Join & Pay Full Price',
      'discountRefundNote': 'Discount difference will be refunded to your Wallet once the member target is reached.',
      'groupDealCheckout': 'Group Deal Checkout',
      'locked': 'LOCKED',
      'qty': 'Qty {qty}',
      'lockedGroupDeal': 'Locked Group Deal',
      'groupDealNote': 'Group deals cannot be modified. You will pay the original full price now. Once the group duration expires, your earned cashback discount will be credited to your Wallet.',
      'cashbackCreditedAfter': 'CASHBACK CREDITED TO WALLET AFTER GROUP CLOSES',
      'totalFullPrice': 'TOTAL • FULL PRICE',
      'secureLock': 'SECURE LOCK',
      'payFullAndLock': 'Pay Full Price & Lock Deal',
      'choosePaymentMethod': 'Choose Payment Method',
      'totalAmount': 'Total: {amount} AED',
      'popular': 'POPULAR',
      'payIn4Tabby': 'Pay in 4. No interest, no fees',
      'buyNowPayLaterTamara': 'Buy Now, Pay Later in 3 splits',
      'instant': 'INSTANT',
      'creditDebitCard': 'Credit / Debit Card',
      'cardsAccepted': 'Visa, Mastercard, AMEX accepted',
      'selectPaymentMethod': 'Select a Payment Method',
      'securedBy': 'Secured by 256-bit SSL encryption',
      'joinBtn': 'Join +',
      'enjoyDiscounts': 'Enjoy discounts with friends',
      'expiredTab': 'Expired ({count})',
      'activeTab': 'Active ({count})',
      'allGroupsTab': 'All Groups',
      'faq1q': '?What is Buy SAWA',
      'faq2q': '?How do I join a Group Deal',
      'faq3q': '?Is my payment information secure',
      'faq4q': '?How long does delivery take',
      'faq5q': '?Can I cancel my order',
      'faq6q': '?What are SAWA Coins',
    },

    //ARABIC
    'ar': {
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'search': 'ابحث عن منتجات...',
      'seeAll': 'عرض الكل ›',
      'apply': 'تطبيق',
      'logout': 'تسجيل الخروج',
      'version': 'باي ساوا · v1.0.0',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'fullName': 'الاسم الكامل',
      'phone': 'رقم الهاتف',
      'referralCode': 'رمز الإحالة (اختياري)',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'continueWithGoogle': 'المتابعة مع جوجل',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'createAccount': 'إنشاء حساب',
      'alreadyHaveAccount': 'هل لديك حساب بالفعل؟',
      'welcomeBack': 'أهلاً بعودتك 👋',
      'signInToContinue': 'سجّل دخولك للمتابعة',
      'loginSubtitle': 'سجّل دخولك للحصول على المكافآت والعروض الجماعية ومزايا VIP',
      'browseAsGuest': 'تصفح كضيف',
      'signInToUnlock': 'سجّل دخولك لتفعيل هذه الميزة',
      'joinSawa': 'انضم إلى عائلة ساوا 🎉',
      'joinSawaSubtitle': 'انضم إلى باي ساوا للحصول على عروض جماعية حصرية واسترداد نقدي!',
      'home': 'الرئيسية',
      'categories': 'الأقسام',
      'deals': 'العروض',
      'wallet': 'المحفظة',
      'profile': 'حسابي',
      'featured': 'مميّز',
      'shareAndEarn': 'شارك واكسب مكافأة',
      'shareEarnSubtitle': 'كل مشاركة تُكسبك حتى 5%',
      'trendingNow': 'الأكثر رواجاً',
      'groupDeal': 'شراء جماعي',
      'addToCart': 'أضف للسلة',
      'addedToCart': 'تم الإضافة للسلة',
      'buyNow': 'اشترِ الآن',
      'categoriesCount': '13 قسماً',
      'myDeals': 'عروضي',
      'activeGroupBuys': 'المشتريات الجماعية النشطة',
      'activeGroupBuysSubtitle': 'تابع كل مجموعة انضممت إليها أو أنشأتها.',
      'startNewGroupBuy': 'بدء شراء جماعي جديد',
      'startGroupSubtitle': 'اجمع أصدقاءك للحصول على خصم ',
      'orJoinExisting': 'أو انضم إلى مجموعة موجودة',
      'enterGroupCode': 'أدخل رمز المجموعة (مثال: GB-X7..)',
      'joinGroup': 'الانضمام إلى المجموعة',
      'members': 'أعضاء',
      'active': 'نشط',
      'expired': 'منتهي',
      'myWallet': 'المحفظة',
      'availableBalance': 'الرصيد المتاح',
      'transactionHistory': 'سجل المعاملات',
      'cashback': 'استرداد نقدي',
      'referralBonus': 'مكافأة الإحالة',
      'purchase': 'مشتريات',
      'groupReward': 'مكافأة الشراء الجماعي',
      'today': 'اليوم',
      'yesterday': 'أمس',
      'account': 'الحساب',
      'editProfile': 'حسابي',
      'helpCenter': 'مركز المساعدة',
      'faqs': 'الأسئلة الشائعة',
      'contactUs': 'تواصل معنا',
      'language': 'اللغة',
      'myFavourites': 'المفضلة',
      'confirm': 'تأكيد',
      'loginToViewProfile': 'يرجى تسجيل الدخول لعرض تفاصيل الحساب.',
      'deleteAccount': 'حذف الحساب',
      'deleteAccountPermanent': 'هذا الإجراء نهائي ولا يمكن التراجع عنه',
      'deleteAccountDesc': 'سيؤدي حذف حسابك إلى إزالة ملفك الشخصي وطلباتك ورصيد محفظتك ومكافآت الاسترداد النقدي. لا يمكن التراجع عن هذا الإجراء.',
      'youWillLose': 'سوف تفقد',
      'walletBalanceLoss': 'رصيد محفظة بقيمة {amount} درهم',
      'orderHistoryLoss': 'سجل الطلبات والتتبع',
      'savedAddressesLoss': 'العناوين المحفوظة وطرق الدفع',
      'referralBonusLoss': 'مكافآت الإحالة وتقدم مستوى VIP',
      'typeDeleteToConfirm': 'اكتب "DELETE" للتأكيد',
      'deleteText': 'DELETE',
      'permanentlyDeleteAccount': 'حذف الحساب نهائياً',
      'birthdate': 'تاريخ الميلاد',
      'securityReadOnly': 'الأمان · للقراءة فقط',
      'saveChanges': 'حفظ التغييرات',
      'chooseLanguage': 'اختر اللغة',
      'languageSubtitle': 'سيتغير التطبيق فوراً وفق اختيارك',
      'yourMessage': 'رسالتك',
      'messagePlaceholder': 'أخبرنا كيف يمكننا مساعدتك اليوم...',
      'sendMessage': 'إرسال الرسالة',
      'orReachDirectly': 'أو تواصل معنا مباشرةً',
      'callUs': 'اتصل بنا',
      'emailUs': 'راسلنا عبر البريد',
      'supportAvailable': 'فريق الدعم متاح على مدار الساعة',
      'myReferralCode': 'رمز الإحالة الخاص بي',
      'referralSubtitle': 'شارك رمزك واكسب 5% من كل عملية شراء',
      'shareCode': 'مشاركة رمزي',
      'totalEarned': 'إجمالي الأرباح',
      'friendsJoined': 'الأصدقاء المنضمون',
      'signInRequired': 'تسجيل الدخول مطلوب',
      'signInRequiredSubtitle': 'أنشئ حساباً للوصول إلى السلة والمحفظة والعروض الجماعية',
      'reviews': 'تقييم',
      'description': 'الوصف',
      'shareAndEarnCashback': 'شارك واكسب 5% استرداداً نقدياً',
      'startGroupBuy': 'بدء شراء جماعي',
      'off': 'خصم',
      'skip': 'تخطي',
      'next': 'التالي',
      'getStarted': 'ابدأ الآن',
      'onboarding1Tag': 'هيّا نبدأ',
      'onboarding1Title': 'مستعد للتسوق\nمع أصدقائك؟',
      'onboarding1Desc':
          'انضم إلى آلاف المتسوقين الأذكياء الذين يوفّرون ويستمتعون ويكسبون يومياً.',
      'onboarding2Tag': 'شراء جماعي',
      'onboarding2Title': 'تجمّعوا واشتروا،\nووفّروا أكثر',
      'onboarding2Desc':
          'تجمّع مع أصدقائك وعائلتك. كلما كبرت المجموعة، كلما زاد الخصم للجميع.',
      'onboarding3Tag': 'سريع وآمن',
      'onboarding3Title': 'توصيل آمن\nوسريع',
      'onboarding3Desc': 'استمتع بدفع آمن وتوصيل سريع إلى باب منزلك في كل طلب.',
      'startShopping': 'ابدأ التسوق',
      'productDetails': 'تفاصيل المنتج',
      'specifications': 'المواصفات',
      'viewAllSpecs': 'عرض جميع المواصفات التقنية ←',
      'myCart': 'سلّتي',
      'subtotal': 'المجموع الفرعي',
      'shipping': 'الشحن',
      'total': 'الإجمالي',
      'proceedToCheckout': 'المتابعة للدفع',
      'signInToCheckout': 'سجّل دخولك للدفع',
      'yourCartIsEmpty': 'سلّتك فارغة',
      'continueShopping': 'مواصلة التسوق',
      'orderPlaced': 'تم تقديم الطلب!',
      'orderPlacedSuccessfully': 'تم تسجيل طلبك بنجاح!',
      'viewCart': 'عرض السلة',
      'reviewsAndComments': 'التقييمات والتعليقات',
      'changesSaved': 'تم حفظ التغييرات بنجاح!',
      'removedFromFav': 'تمت إزالة {name} من المفضلة',
      'accountDeleted': 'تم حذف الحساب بنجاح.',
      'messageSent': 'تم إرسال رسالتك! سنرد عليك قريباً.',
      'groupCodeInvalid': 'رمز المجموعة "{code}" غير موجود أو منتهي الصلاحية.',
      'items': '{count} منتج',
      'noFavouritesYet': 'لا توجد مفضلة بعد',
      'loginToSend': 'سجّل دخولك لإرسال رسالة',
      'aed': 'درهم',
      'colorDefaultSizeStandard': 'اللون: افتراضي | المقاس: قياسي',
      'accountTitle': 'الحساب',
      'shareProductDesc': 'شارك هذا المنتج واحصل على كاش باك عند الشراء!',
      'startGroupBuyDesc': 'ابدأ شراء جماعي مع أصدقائك للحصول على خصم أكبر.',
      'newBadge': 'جديد',
      'hotBadge': 'رائج',
      'flashSale': 'تخفيضات سريعة',
      'flashSaleDesc': 'خصم حتى 40٪ على سلع مختارة اليوم',
      'cashbackBadge': 'كاش باك',
      'earnCashback': 'اكسب كاش باك',
      'earnCashbackDesc': 'احصل على كاش باك على كل عملية شراء جماعية',
      'groupName': 'اسم المجموعة',
      'addProductsBtn': 'إضافة منتجات +',
      'selectedProducts': 'المنتجات المحددة',
      'createGroupInvite': 'إنشاء المجموعة والحصول على رابط الدعوة',
      'addItemsToPool': 'إضافة منتجات للمجموعة',
      'searchProductCode': 'ابحث باسم المنتج أو الرمز',
      'filterNew': 'جديد',
      'filterTopBrands': 'أفضل الماركات',
      'filterPriceLow': 'السعر ↓',
      'filterPriceHigh': 'السعر ↑',
      'addBtn': 'إضافة +',
      'inviteCode': 'رمز الدعوة',
      'copy': 'نسخ',
      'membersJoined': 'الأعضاء المنضمون',
      'productsInGroup': 'المنتجات في المجموعة',
      'fullPrice': 'السعر الكامل',
      'joinPayFullPrice': 'انضمام ودفع السعر الكامل',
      'discountRefundNote': 'سيتم استرداد فرق الخصم إلى محفظتك بمجرد وصول المجموعة للعدد المطلوب.',
      'groupDealCheckout': 'إتمام شراء المجموعة',
      'locked': 'مقفل',
      'qty': 'الكمية {qty}',
      'lockedGroupDeal': 'عرض مجموعة مقفل',
      'groupDealNote': 'لا يمكن تعديل عروض المجموعة. ستدفع السعر الأصلي الكامل الآن. بمجرد انتهاء مدة المجموعة، سيتم إضافة خصم الكاش باك إلى محفظتك.',
      'cashbackCreditedAfter': 'يتم إضافة الكاش باك للمحفظة بعد إغلاق المجموعة',
      'totalFullPrice': 'الإجمالي • السعر الكامل',
      'secureLock': 'قفل آمن',
      'payFullAndLock': 'دفع السعر الكامل وقفل العرض',
      'choosePaymentMethod': 'اختر طريقة الدفع',
      'totalAmount': 'الإجمالي: {amount} درهم',
      'popular': 'شائع',
      'payIn4Tabby': 'قسمها على 4. بدون فوائد أو رسوم',
      'buyNowPayLaterTamara': 'اشتر الآن وادفع لاحقاً على 3 دفعات',
      'instant': 'فوري',
      'creditDebitCard': 'بطاقة ائتمان / مدى',
      'cardsAccepted': 'نقبل فيزا، ماستركارد، وأمريكان إكسبريس',
      'selectPaymentMethod': 'حدد طريقة الدفع',
      'securedBy': 'مؤمن بتشفير SSL 256-bit',
      'joinBtn': 'انضمام +',
      'enjoyDiscounts': 'استمتع بخصومات مع أصدقائك',
      'expiredTab': 'منتهية ({count})',
      'activeTab': 'نشطة ({count})',
      'allGroupsTab': 'كل المجموعات',
      'faq1q': 'ما هو تطبيق باي ساوا؟',
      'faq2q': 'كيف يمكنني الانضمام لعرض جماعي؟',
      'faq3q': 'هل معلومات الدفع الخاصة بي آمنة؟',
      'faq4q': 'كم يستغرق التوصيل؟',
      'faq5q': 'هل يمكنني إلغاء طلبي؟',
      'faq6q': 'ما هي عملات ساوا؟',
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
