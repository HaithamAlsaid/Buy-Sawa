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

  // ─── General ────────────────────────────────────────────────
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
    // ──── ENGLISH ────
    'en': {
      'ok': 'OK', 'cancel': 'Cancel', 'save': 'Save',
      'search': 'Search products...', 'seeAll': 'See all ›',
      'apply': 'Apply', 'logout': 'Logout', 'version': 'Buy SAWA · v1.0.0',
      'login': 'Login', 'register': 'Create Account',
      'email': 'Email Address', 'password': 'Password',
      'fullName': 'Full Name', 'phone': 'Phone Number',
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
      'home': 'Home', 'categories': 'Categories',
      'deals': 'Deals', 'wallet': 'Wallet', 'profile': 'Profile',
      'featured': 'FEATURED', 'shareAndEarn': 'Share & Earn Cashback',
      'shareEarnSubtitle': 'Every share earns you up to 5%',
      'trendingNow': 'Trending Now', 'groupDeal': 'Group Deal',
      'addToCart': 'Add to Cart', 'buyNow': 'Buy Now',
      'categoriesCount': '13 categories',
      'myDeals': 'MY DEALS', 'activeGroupBuys': 'Active Group Buys',
      'activeGroupBuysSubtitle': "Track every group you've joined or started.",
      'startNewGroupBuy': 'Start a new Group Buy',
      'startGroupSubtitle': 'Pool with friends to unlock up to 15% off',
      'orJoinExisting': 'OR JOIN AN EXISTING GROUP',
      'enterGroupCode': 'Enter Group Code (e.g., GB-X7..)',
      'joinGroup': 'Join Group',
      'members': 'members', 'active': 'ACTIVE', 'expired': 'EXPIRED',
      'myWallet': 'Wallet', 'availableBalance': 'AVAILABLE BALANCE',
      'transactionHistory': 'Transaction History',
      'cashback': 'Cashback', 'referralBonus': 'Referral Bonus',
      'purchase': 'Purchase', 'groupReward': 'Group Deal Reward',
      'today': 'Today', 'yesterday': 'Yesterday',
      'account': 'ACCOUNT', 'editProfile': 'Profile',
      'helpCenter': 'Help Center', 'faqs': 'FAQs',
      'contactUs': 'Contact Us', 'language': 'Language',
      'deleteAccount': 'Delete Account', 'birthdate': 'BIRTHDATE',
      'securityReadOnly': 'SECURITY · READ ONLY', 'saveChanges': 'Save Changes',
      'chooseLanguage': 'Choose Language',
      'languageSubtitle': 'The app will switch instantly to your choice',
      'yourMessage': 'YOUR MESSAGE',
      'messagePlaceholder': 'Tell us how we can help you today...',
      'sendMessage': 'Send Message',
      'orReachDirectly': 'OR REACH US DIRECTLY',
      'callUs': 'CALL US', 'emailUs': 'EMAIL US',
      'supportAvailable': 'Support team available 24/7',
      'myReferralCode': 'My Referral Code',
      'referralSubtitle': 'Share your code & earn 5% for every purchase',
      'shareCode': 'Share My Code',
      'totalEarned': 'Total Earned', 'friendsJoined': 'Friends Joined',
      'signInRequired': 'Sign In Required',
      'signInRequiredSubtitle': 'Create an account to access cart, wallet & group deals',
      'reviews': 'reviews', 'description': 'Description',
      'shareAndEarnCashback': 'Share & Earn 5% Cashback',
      'startGroupBuy': 'Start Group Buy', 'off': 'off',
      'skip': 'Skip', 'next': 'Next', 'getStarted': 'Get Started',
      'onboarding1Tag': 'LET\'S GO',
      'onboarding1Title': 'Ready to\nBuy SAWA?',
      'onboarding1Desc': 'Join thousands of smart shoppers already saving together every day.',
      'onboarding2Tag': 'GROUP BUYING',
      'onboarding2Title': 'Shop Together,\nSave More',
      'onboarding2Desc': 'Join forces with friends and family. The more you squad up, the bigger the discount everyone gets.',
      'onboarding3Tag': 'FAST & SECURE',
      'onboarding3Title': 'Safe & Quick\nDelivery',
      'onboarding3Desc': 'Enjoy secure payments and fast delivery straight to your doorstep for every order.',
      'startShopping': 'Start Shopping',
    },

    // ──── ARABIC (EMIRATI) ────
    'ar': {
      'ok': 'موافق', 'cancel': 'إلغاء', 'save': 'حفظ',
      'search': 'دوّر على منتجات...', 'seeAll': 'عرض الكل ›',
      'apply': 'تطبيق', 'logout': 'تسجيل خروج', 'version': 'باي ساوا · v1.0.0',
      'login': 'دخول', 'register': 'سجل حساب',
      'email': 'الإيميل', 'password': 'كلمة السر',
      'fullName': 'الاسم الكامل', 'phone': 'رقم الموبايل',
      'referralCode': 'كود الدعوة (اختياري)',
      'forgotPassword': 'نسيت كلمة السر؟',
      'continueWithGoogle': 'كمل مع Google',
      'dontHaveAccount': 'ما عندك حساب؟',
      'createAccount': 'سجل حساب',
      'alreadyHaveAccount': 'عندك حساب؟',
      'welcomeBack': 'يا هلا فيك 👋',
      'signInToContinue': 'سجل دخول عشان تكمل',
      'loginSubtitle': 'سجل عشان تاخذ كاش باك وخصومات جماعية و VIP',
      'browseAsGuest': 'تصفح كزائر',
      'signInToUnlock': 'سجل دخول عشان تفتح هالميزة',
      'home': 'الرئيسية', 'categories': 'الأقسام',
      'deals': 'العروض', 'wallet': 'المحفظة', 'profile': 'حسابي',
      'featured': 'مميز', 'shareAndEarn': 'شارك واربح كاش باك',
      'shareEarnSubtitle': 'كل مشاركة تربحك لين 5%',
      'trendingNow': 'الترند الحين', 'groupDeal': 'عرض جماعي',
      'addToCart': 'ضف للسلة', 'buyNow': 'اشتر ألحين',
      'categoriesCount': '13 قسم',
      'myDeals': 'عروضي', 'activeGroupBuys': 'الشراء الجماعي الشغال',
      'activeGroupBuysSubtitle': 'تابع كل مجموعة دخلت فيها أو سويتها.',
      'startNewGroupBuy': 'ابدأ شراء جماعي جديد',
      'startGroupSubtitle': 'تجمع ويا ربعك لخصم 15%',
      'orJoinExisting': 'أو ادخل مجموعة موجودة',
      'enterGroupCode': 'دخل كود المجموعة (مثل: GB-X7..)',
      'joinGroup': 'ادخل المجموعة',
      'members': 'أعضاء', 'active': 'شغال', 'expired': 'منتهي',
      'myWallet': 'المحفظة', 'availableBalance': 'الرصيد المتوفر',
      'transactionHistory': 'سجل العمليات',
      'cashback': 'كاش باك', 'referralBonus': 'مكافأة دعوة',
      'purchase': 'شراء', 'groupReward': 'مكافأة المجموعة',
      'today': 'اليوم', 'yesterday': 'البارحة',
      'account': 'الحساب', 'editProfile': 'حسابي',
      'helpCenter': 'مركز المساعدة', 'faqs': 'الأسئلة الشائعة',
      'contactUs': 'تواصل ويانا', 'language': 'اللغة',
      'deleteAccount': 'احذف الحساب', 'birthdate': 'تاريخ الميلاد',
      'securityReadOnly': 'الأمان · قراءة فقط', 'saveChanges': 'حفظ التغييرات',
      'chooseLanguage': 'اختار اللغة',
      'languageSubtitle': 'التطبيق بيتغير فورا لاختيارك',
      'yourMessage': 'رسالتك',
      'messagePlaceholder': 'خبرنا كيف نقدر نساعدك اليوم...',
      'sendMessage': 'طرش الرسالة',
      'orReachDirectly': 'أو تواصل ويانا مباشرة',
      'callUs': 'اتصل بنا', 'emailUs': 'راسلنا',
      'supportAvailable': 'فريق الدعم متوفر 24/7',
      'myReferralCode': 'كود الدعوة مالي',
      'referralSubtitle': 'شارك كودك واربح 5% من كل شراء',
      'shareCode': 'شارك كودي',
      'totalEarned': 'مجموع الأرباح', 'friendsJoined': 'ربعك اللي دخلوا',
      'signInRequired': 'لازم تسجل دخول',
      'signInRequiredSubtitle': 'سجل حساب عشان تدخل السلة والمحفظة',
      'reviews': 'تقييم', 'description': 'الوصف',
      'shareAndEarnCashback': 'شارك واربح 5% كاش باك',
      'startGroupBuy': 'ابدأ شراء جماعي', 'off': 'خصم',
      'skip': 'تخطي', 'next': 'التالي', 'getStarted': 'ابدأ التسوق',
      'onboarding1Tag': 'LET\'S GO',
      'onboarding1Title': 'Ready to\nBuy SAWA?',
      'onboarding1Desc': 'Join thousands of smart shoppers already saving together every day.',
      'onboarding2Tag': 'GROUP BUYING',
      'onboarding2Title': 'Shop Together,\nSave More',
      'onboarding2Desc': 'Join forces with friends and family. The more you squad up, the bigger the discount everyone gets.',
      'onboarding3Tag': 'FAST & SECURE',
      'onboarding3Title': 'Safe & Quick\nDelivery',
      'onboarding3Desc': 'Enjoy secure payments and fast delivery straight to your doorstep for every order.',
      'startShopping': 'Start Shopping',
    },

    // ──── CHINESE ────
    'zh': {
      'ok': '确定', 'cancel': '取消', 'save': '保存',
      'search': '搜索产品...', 'seeAll': '查看全部 ›',
      'apply': '应用', 'logout': '退出登录', 'version': 'Buy SAWA · v1.0.0',
      'login': '登录', 'register': '创建账户',
      'email': '电子邮件', 'password': '密码',
      'fullName': '全名', 'phone': '电话号码',
      'referralCode': '推荐码（可选）',
      'forgotPassword': '忘记密码？',
      'continueWithGoogle': '使用 Google 继续',
      'dontHaveAccount': '没有账户？',
      'createAccount': '创建账户',
      'alreadyHaveAccount': '已有账户？',
      'welcomeBack': '欢迎回来 👋',
      'signInToContinue': '登录以继续',
      'loginSubtitle': '登录解锁返现、团购优惠和VIP特权',
      'browseAsGuest': '以访客身份浏览',
      'signInToUnlock': '登录以解锁此功能',
      'home': '首页', 'categories': '分类',
      'deals': '优惠', 'wallet': '钱包', 'profile': '我的',
      'featured': '精选', 'shareAndEarn': '分享赚返现',
      'shareEarnSubtitle': '每次分享最高赚5%',
      'trendingNow': '热销商品', 'groupDeal': '团购',
      'addToCart': '加入购物车', 'buyNow': '立即购买',
      'categoriesCount': '13个分类',
      'myDeals': '我的优惠', 'activeGroupBuys': '活跃团购',
      'activeGroupBuysSubtitle': '跟踪您参与或创建的每个团购。',
      'startNewGroupBuy': '发起新团购',
      'startGroupSubtitle': '与朋友合购最高享15%折扣',
      'orJoinExisting': '或加入现有团购',
      'enterGroupCode': '输入团购码 (如: GB-X7..)',
      'joinGroup': '加入团购',
      'members': '人', 'active': '活跃', 'expired': '已过期',
      'myWallet': '钱包', 'availableBalance': '可用余额',
      'transactionHistory': '交易记录',
      'cashback': '返现', 'referralBonus': '推荐奖励',
      'purchase': '购买', 'groupReward': '团购奖励',
      'today': '今天', 'yesterday': '昨天',
      'account': '账户', 'editProfile': '个人资料',
      'helpCenter': '帮助中心', 'faqs': '常见问题',
      'contactUs': '联系我们', 'language': '语言',
      'deleteAccount': '删除账户', 'birthdate': '出生日期',
      'securityReadOnly': '安全 · 只读', 'saveChanges': '保存更改',
      'chooseLanguage': '选择语言',
      'languageSubtitle': '应用将立即切换到您的选择',
      'yourMessage': '您的消息',
      'messagePlaceholder': '告诉我们今天如何帮助您...',
      'sendMessage': '发送消息',
      'orReachDirectly': '或直接联系我们',
      'callUs': '致电我们', 'emailUs': '邮件联系',
      'supportAvailable': '客服团队全天候24/7服务',
      'myReferralCode': '我的推荐码',
      'referralSubtitle': '分享您的推荐码，每次购买赚取5%',
      'shareCode': '分享我的推荐码',
      'totalEarned': '总收益', 'friendsJoined': '好友已加入',
      'signInRequired': '需要登录',
      'signInRequiredSubtitle': '创建账户以访问购物车、钱包和团购',
      'reviews': '评价', 'description': '商品描述',
      'shareAndEarnCashback': '分享赚5%返现',
      'startGroupBuy': '发起团购', 'off': '折扣',
      'skip': '跳过', 'next': '下一步', 'getStarted': '开始',
      'onboarding1Tag': 'LET\'S GO',
      'onboarding1Title': 'Ready to\nBuy SAWA?',
      'onboarding1Desc': 'Join thousands of smart shoppers already saving together every day.',
      'onboarding2Tag': 'GROUP BUYING',
      'onboarding2Title': 'Shop Together,\nSave More',
      'onboarding2Desc': 'Join forces with friends and family. The more you squad up, the bigger the discount everyone gets.',
      'onboarding3Tag': 'FAST & SECURE',
      'onboarding3Title': 'Safe & Quick\nDelivery',
      'onboarding3Desc': 'Enjoy secure payments and fast delivery straight to your doorstep for every order.',
      'startShopping': 'Start Shopping',
    },

    // ──── FRENCH ────
    'fr': {
      'ok': 'OK', 'cancel': 'Annuler', 'save': 'Sauvegarder',
      'search': 'Rechercher des produits...', 'seeAll': 'Voir tout ›',
      'apply': 'Appliquer', 'logout': 'Déconnexion', 'version': 'Buy SAWA · v1.0.0',
      'login': 'Connexion', 'register': 'Créer un compte',
      'email': 'Adresse e-mail', 'password': 'Mot de passe',
      'fullName': 'Nom complet', 'phone': 'Numéro de téléphone',
      'referralCode': 'Code de parrainage (optionnel)',
      'forgotPassword': 'Mot de passe oublié ?',
      'continueWithGoogle': 'Continuer avec Google',
      'dontHaveAccount': "Pas de compte ?",
      'createAccount': 'Créer un compte',
      'alreadyHaveAccount': 'Déjà un compte ?',
      'welcomeBack': 'Bon retour 👋',
      'signInToContinue': 'Connectez-vous pour continuer',
      'loginSubtitle': 'Connectez-vous pour accéder au cashback, aux achats groupés et aux avantages VIP',
      'browseAsGuest': 'Naviguer en tant qu\'invité',
      'signInToUnlock': 'Connectez-vous pour accéder à cette fonctionnalité',
      'home': 'Accueil', 'categories': 'Catégories',
      'deals': 'Offres', 'wallet': 'Portefeuille', 'profile': 'Profil',
      'featured': 'EN VEDETTE', 'shareAndEarn': 'Partagez et gagnez',
      'shareEarnSubtitle': 'Chaque partage vous rapporte jusqu\'à 5%',
      'trendingNow': 'Tendances', 'groupDeal': 'Achat groupé',
      'addToCart': 'Ajouter au panier', 'buyNow': 'Acheter maintenant',
      'categoriesCount': '13 catégories',
      'myDeals': 'MES OFFRES', 'activeGroupBuys': 'Achats groupés actifs',
      'activeGroupBuysSubtitle': 'Suivez chaque groupe que vous avez rejoint ou créé.',
      'startNewGroupBuy': 'Démarrer un achat groupé',
      'startGroupSubtitle': 'Regroupez-vous avec des amis pour économiser jusqu\'à 15%',
      'orJoinExisting': 'OU REJOINDRE UN GROUPE EXISTANT',
      'enterGroupCode': 'Entrez le code du groupe (ex: GB-X7..)',
      'joinGroup': 'Rejoindre le groupe',
      'members': 'membres', 'active': 'ACTIF', 'expired': 'EXPIRÉ',
      'myWallet': 'Portefeuille', 'availableBalance': 'SOLDE DISPONIBLE',
      'transactionHistory': 'Historique des transactions',
      'cashback': 'Cashback', 'referralBonus': 'Bonus de parrainage',
      'purchase': 'Achat', 'groupReward': 'Récompense de groupe',
      'today': 'Aujourd\'hui', 'yesterday': 'Hier',
      'account': 'COMPTE', 'editProfile': 'Profil',
      'helpCenter': 'Centre d\'aide', 'faqs': 'FAQ',
      'contactUs': 'Contactez-nous', 'language': 'Langue',
      'deleteAccount': 'Supprimer le compte', 'birthdate': 'DATE DE NAISSANCE',
      'securityReadOnly': 'SÉCURITÉ · LECTURE SEULE', 'saveChanges': 'Sauvegarder',
      'chooseLanguage': 'Choisir la langue',
      'languageSubtitle': 'L\'application changera instantanément selon votre choix',
      'yourMessage': 'VOTRE MESSAGE',
      'messagePlaceholder': 'Dites-nous comment nous pouvons vous aider...',
      'sendMessage': 'Envoyer le message',
      'orReachDirectly': 'OU CONTACTEZ-NOUS DIRECTEMENT',
      'callUs': 'APPELEZ-NOUS', 'emailUs': 'ÉCRIVEZ-NOUS',
      'supportAvailable': 'Équipe d\'assistance disponible 24h/24 7j/7',
      'myReferralCode': 'Mon code de parrainage',
      'referralSubtitle': 'Partagez votre code et gagnez 5% sur chaque achat',
      'shareCode': 'Partager mon code',
      'totalEarned': 'Total gagné', 'friendsJoined': 'Amis inscrits',
      'signInRequired': 'Connexion requise',
      'signInRequiredSubtitle': 'Créez un compte pour accéder au panier, portefeuille et achats groupés',
      'reviews': 'avis', 'description': 'Description',
      'shareAndEarnCashback': 'Partagez et gagnez 5% de cashback',
      'startGroupBuy': 'Démarrer un achat groupé', 'off': 'de réduction',
      'skip': 'Passer', 'next': 'Suivant', 'getStarted': 'Commencer',
      'onboarding1Tag': 'LET\'S GO',
      'onboarding1Title': 'Ready to\nBuy SAWA?',
      'onboarding1Desc': 'Join thousands of smart shoppers already saving together every day.',
      'onboarding2Tag': 'GROUP BUYING',
      'onboarding2Title': 'Shop Together,\nSave More',
      'onboarding2Desc': 'Join forces with friends and family. The more you squad up, the bigger the discount everyone gets.',
      'onboarding3Tag': 'FAST & SECURE',
      'onboarding3Title': 'Safe & Quick\nDelivery',
      'onboarding3Desc': 'Enjoy secure payments and fast delivery straight to your doorstep for every order.',
      'startShopping': 'Start Shopping',
    },

    // ──── SPANISH ────
    'es': {
      'ok': 'Aceptar', 'cancel': 'Cancelar', 'save': 'Guardar',
      'search': 'Buscar productos...', 'seeAll': 'Ver todo ›',
      'apply': 'Aplicar', 'logout': 'Cerrar sesión', 'version': 'Buy SAWA · v1.0.0',
      'login': 'Iniciar sesión', 'register': 'Crear cuenta',
      'email': 'Correo electrónico', 'password': 'Contraseña',
      'fullName': 'Nombre completo', 'phone': 'Número de teléfono',
      'referralCode': 'Código de referido (opcional)',
      'forgotPassword': '¿Olvidaste tu contraseña?',
      'continueWithGoogle': 'Continuar con Google',
      'dontHaveAccount': '¿No tienes cuenta?',
      'createAccount': 'Crear cuenta',
      'alreadyHaveAccount': '¿Ya tienes cuenta?',
      'welcomeBack': '¡Bienvenido de vuelta! 👋',
      'signInToContinue': 'Inicia sesión para continuar',
      'loginSubtitle': 'Accede al cashback, compras grupales y ventajas VIP',
      'browseAsGuest': 'Navegar como invitado',
      'signInToUnlock': 'Inicia sesión para desbloquear esta función',
      'home': 'Inicio', 'categories': 'Categorías',
      'deals': 'Ofertas', 'wallet': 'Cartera', 'profile': 'Perfil',
      'featured': 'DESTACADO', 'shareAndEarn': 'Comparte y gana',
      'shareEarnSubtitle': 'Cada vez que compartes ganas hasta 5%',
      'trendingNow': 'Tendencias', 'groupDeal': 'Compra grupal',
      'addToCart': 'Añadir al carrito', 'buyNow': 'Comprar ahora',
      'categoriesCount': '13 categorías',
      'myDeals': 'MIS OFERTAS', 'activeGroupBuys': 'Compras grupales activas',
      'activeGroupBuysSubtitle': 'Sigue cada grupo al que te has unido o creado.',
      'startNewGroupBuy': 'Iniciar una compra grupal',
      'startGroupSubtitle': 'Únete con amigos para ahorrar hasta 15%',
      'orJoinExisting': 'O UNIRSE A UN GRUPO EXISTENTE',
      'enterGroupCode': 'Ingresa el código del grupo (ej: GB-X7..)',
      'joinGroup': 'Unirse al grupo',
      'members': 'miembros', 'active': 'ACTIVO', 'expired': 'EXPIRADO',
      'myWallet': 'Cartera', 'availableBalance': 'SALDO DISPONIBLE',
      'transactionHistory': 'Historial de transacciones',
      'cashback': 'Cashback', 'referralBonus': 'Bono de referido',
      'purchase': 'Compra', 'groupReward': 'Premio grupal',
      'today': 'Hoy', 'yesterday': 'Ayer',
      'account': 'CUENTA', 'editProfile': 'Perfil',
      'helpCenter': 'Centro de ayuda', 'faqs': 'Preguntas frecuentes',
      'contactUs': 'Contáctanos', 'language': 'Idioma',
      'deleteAccount': 'Eliminar cuenta', 'birthdate': 'FECHA DE NACIMIENTO',
      'securityReadOnly': 'SEGURIDAD · SOLO LECTURA', 'saveChanges': 'Guardar cambios',
      'chooseLanguage': 'Elegir idioma',
      'languageSubtitle': 'La app cambiará instantáneamente a tu elección',
      'yourMessage': 'TU MENSAJE',
      'messagePlaceholder': 'Cuéntanos cómo podemos ayudarte hoy...',
      'sendMessage': 'Enviar mensaje',
      'orReachDirectly': 'O CONTÁCTANOS DIRECTAMENTE',
      'callUs': 'LLÁMANOS', 'emailUs': 'ESCRÍBENOS',
      'supportAvailable': 'Equipo de soporte disponible 24/7',
      'myReferralCode': 'Mi código de referido',
      'referralSubtitle': 'Comparte tu código y gana 5% por cada compra',
      'shareCode': 'Compartir mi código',
      'totalEarned': 'Total ganado', 'friendsJoined': 'Amigos unidos',
      'signInRequired': 'Inicio de sesión requerido',
      'signInRequiredSubtitle': 'Crea una cuenta para acceder al carrito, cartera y compras grupales',
      'reviews': 'reseñas', 'description': 'Descripción',
      'shareAndEarnCashback': 'Comparte y gana 5% de cashback',
      'startGroupBuy': 'Iniciar compra grupal', 'off': 'de descuento',
      'skip': 'Omitir', 'next': 'Siguiente', 'getStarted': 'Empezar',
      'onboarding1Tag': 'LET\'S GO',
      'onboarding1Title': 'Ready to\nBuy SAWA?',
      'onboarding1Desc': 'Join thousands of smart shoppers already saving together every day.',
      'onboarding2Tag': 'GROUP BUYING',
      'onboarding2Title': 'Shop Together,\nSave More',
      'onboarding2Desc': 'Join forces with friends and family. The more you squad up, the bigger the discount everyone gets.',
      'onboarding3Tag': 'FAST & SECURE',
      'onboarding3Title': 'Safe & Quick\nDelivery',
      'onboarding3Desc': 'Enjoy secure payments and fast delivery straight to your doorstep for every order.',
      'startShopping': 'Start Shopping',
    },

    // ──── RUSSIAN ────
    'ru': {
      'ok': 'ОК', 'cancel': 'Отмена', 'save': 'Сохранить',
      'search': 'Поиск товаров...', 'seeAll': 'Смотреть все ›',
      'apply': 'Применить', 'logout': 'Выйти', 'version': 'Buy SAWA · v1.0.0',
      'login': 'Войти', 'register': 'Создать аккаунт',
      'email': 'Электронная почта', 'password': 'Пароль',
      'fullName': 'Полное имя', 'phone': 'Номер телефона',
      'referralCode': 'Реферальный код (необязательно)',
      'forgotPassword': 'Забыли пароль?',
      'continueWithGoogle': 'Продолжить с Google',
      'dontHaveAccount': 'Нет аккаунта?',
      'createAccount': 'Создать аккаунт',
      'alreadyHaveAccount': 'Уже есть аккаунт?',
      'welcomeBack': 'С возвращением 👋',
      'signInToContinue': 'Войдите, чтобы продолжить',
      'loginSubtitle': 'Войдите, чтобы получить кэшбэк, групповые скидки и VIP',
      'browseAsGuest': 'Продолжить как гость',
      'signInToUnlock': 'Войдите, чтобы разблокировать эту функцию',
      'home': 'Главная', 'categories': 'Категории',
      'deals': 'Акции', 'wallet': 'Кошелек', 'profile': 'Профиль',
      'featured': 'РЕКОМЕНДУЕМ', 'shareAndEarn': 'Делись и зарабатывай',
      'shareEarnSubtitle': 'Каждое приглашение приносит до 5%',
      'trendingNow': 'Популярное', 'groupDeal': 'Групповая сделка',
      'addToCart': 'В корзину', 'buyNow': 'Купить сейчас',
      'categoriesCount': '13 категорий',
      'myDeals': 'МОИ АКЦИИ', 'activeGroupBuys': 'Активные совместные покупки',
      'activeGroupBuysSubtitle': 'Отслеживайте каждую группу.',
      'startNewGroupBuy': 'Начать новую покупку',
      'startGroupSubtitle': 'Объединяйтесь с друзьями для скидки до 15%',
      'orJoinExisting': 'ИЛИ ПРИСОЕДИНИТЕСЬ К ГРУППЕ',
      'enterGroupCode': 'Введите код группы (напр. GB-X7..)',
      'joinGroup': 'Присоединиться',
      'members': 'участников', 'active': 'АКТИВНО', 'expired': 'ИСТЕКЛО',
      'myWallet': 'Кошелек', 'availableBalance': 'ДОСТУПНЫЙ БАЛАНС',
      'transactionHistory': 'История транзакций',
      'cashback': 'Кэшбэк', 'referralBonus': 'Реферальный бонус',
      'purchase': 'Покупка', 'groupReward': 'Групповая награда',
      'today': 'Сегодня', 'yesterday': 'Вчера',
      'account': 'АККАУНТ', 'editProfile': 'Профиль',
      'helpCenter': 'Служба поддержки', 'faqs': 'Частые вопросы',
      'contactUs': 'Связаться с нами', 'language': 'Язык',
      'deleteAccount': 'Удалить аккаунт', 'birthdate': 'ДАТА РОЖДЕНИЯ',
      'securityReadOnly': 'БЕЗОПАСНОСТЬ · ТОЛЬКО ЧТЕНИЕ', 'saveChanges': 'Сохранить',
      'chooseLanguage': 'Выберите язык',
      'languageSubtitle': 'Приложение моментально переключится',
      'yourMessage': 'ВАШЕ СООБЩЕНИЕ',
      'messagePlaceholder': 'Расскажите, как мы можем вам помочь...',
      'sendMessage': 'Отправить сообщение',
      'orReachDirectly': 'ИЛИ СВЯЖИТЕСЬ НАПРЯМУЮ',
      'callUs': 'ПОЗВОНИТЬ', 'emailUs': 'НАПИСАТЬ',
      'supportAvailable': 'Поддержка доступна 24/7',
      'myReferralCode': 'Мой реферальный код',
      'referralSubtitle': 'Делитесь кодом и получайте 5% с каждой покупки',
      'shareCode': 'Поделиться кодом',
      'totalEarned': 'Всего заработано', 'friendsJoined': 'Друзей присоединилось',
      'signInRequired': 'Требуется вход',
      'signInRequiredSubtitle': 'Создайте аккаунт для доступа',
      'reviews': 'отзывов', 'description': 'Описание',
      'shareAndEarnCashback': 'Делись и зарабатывай 5% кэшбэк',
      'startGroupBuy': 'Начать групповую покупку', 'off': 'скидка',
      'skip': 'Пропустить', 'next': 'Далее', 'getStarted': 'Начать',
      'onboarding1Tag': 'LET\'S GO',
      'onboarding1Title': 'Ready to\nBuy SAWA?',
      'onboarding1Desc': 'Join thousands of smart shoppers already saving together every day.',
      'onboarding2Tag': 'GROUP BUYING',
      'onboarding2Title': 'Shop Together,\nSave More',
      'onboarding2Desc': 'Join forces with friends and family. The more you squad up, the bigger the discount everyone gets.',
      'onboarding3Tag': 'FAST & SECURE',
      'onboarding3Title': 'Safe & Quick\nDelivery',
      'onboarding3Desc': 'Enjoy secure payments and fast delivery straight to your doorstep for every order.',
      'startShopping': 'Start Shopping',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar', 'zh', 'fr', 'es', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
