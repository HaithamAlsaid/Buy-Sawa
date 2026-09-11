import '../../models/donation_campaign_model.dart';

class DonationService {
  // Mock function to return dummy data for UI testing
  static Future<List<DonationCampaignModel>> getActiveCampaigns() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock data
    return [
      DonationCampaignModel(
        id: '1',
        slug: 'ramadan-iftar',
        title: 'إفطار صائم - رمضان 2026',
        description: 'ساهم في توفير وجبات الإفطار للأسر المحتاجة خلال الشهر الكريم.',
        targetAmount: 50000.0,
        collectedAmount: 32500.0,
        endDate: DateTime.now().add(const Duration(days: 14)),
        foundationName: 'مؤسسة الهلال الأحمر',
        imageUrl: 'https://images.unsplash.com/photo-1593113630400-ea4288922497?auto=format&fit=crop&q=80&w=800&h=400',
      ),
      DonationCampaignModel(
        id: '2',
        slug: 'build-mosque',
        title: 'بناء مسجد النور',
        description: 'صدقة جارية لبناء بيت من بيوت الله وتجهيزه بالكامل.',
        targetAmount: 120000.0,
        collectedAmount: 11000.0,
        endDate: DateTime.now().add(const Duration(days: 45)),
        foundationName: 'جمعية الإحسان الخيرية',
        imageUrl: 'https://images.unsplash.com/photo-1585036156171-384164a8c675?auto=format&fit=crop&q=80&w=800&h=400',
      ),
      DonationCampaignModel(
        id: '3',
        slug: 'water-well',
        title: 'حفر بئر مياه ارتوازي',
        description: 'سقيا الماء هي أفضل الصدقات، ساهم في حفر بئر لتوفير مياه نقية لقرية كاملة.',
        targetAmount: 15000.0,
        collectedAmount: 14500.0,
        endDate: DateTime.now().add(const Duration(days: 3)),
        foundationName: 'مؤسسة سقيا الأمل',
        imageUrl: 'https://images.unsplash.com/photo-1504221507732-5246c045949b?auto=format&fit=crop&q=80&w=800&h=400',
      ),
      DonationCampaignModel(
        id: '4',
        slug: 'orphan-sponsorship',
        title: 'كفالة أيتام - سنابل الخير',
        description: 'شاركنا في كفالة 50 يتيم وتوفير الرعاية الصحية والتعليمية لهم.',
        targetAmount: 100000.0,
        collectedAmount: 65000.0,
        endDate: DateTime.now().add(const Duration(days: 20)),
        foundationName: 'جمعية رسالة',
        imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&q=80&w=800&h=400',
      ),
      DonationCampaignModel(
        id: '5',
        slug: 'medical-convoy',
        title: 'قافلة طبية لعلاج العيون',
        description: 'تجهيز قافلة طبية لعمل عمليات المياه البيضاء في القرى النائية.',
        targetAmount: 80000.0,
        collectedAmount: 12000.0,
        endDate: DateTime.now().add(const Duration(days: 7)),
        foundationName: 'مؤسسة مجدي يعقوب',
        imageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=800&h=400',
      ),
    ];
  }
}
