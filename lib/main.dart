import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const kPink = Color(0xFFE0488F);
const kPurple = Color(0xFF7E4BB8);
const kBrown = Color(0xFF6D4C41);
const kCream = Color(0xFFFFF4F8);

class City {
  final String country, name, tzName, method;
  final double lat, lng;
  const City(this.country, this.name, this.lat, this.lng, this.tzName, this.method);
}

const cities = <City>[
  City('مصر', 'القاهرة', 30.0444, 31.2357, 'Africa/Cairo', 'egy'),
  City('مصر', 'الإسكندرية', 31.2001, 29.9187, 'Africa/Cairo', 'egy'),
  City('مصر', 'أسوان', 24.0889, 32.8998, 'Africa/Cairo', 'egy'),
  City('مصر', 'الأقصر', 25.6872, 32.6396, 'Africa/Cairo', 'egy'),
  City('مصر', 'المنصورة', 31.0364, 31.3807, 'Africa/Cairo', 'egy'),
  City('السعودية', 'مكة المكرمة', 21.3891, 39.8579, 'Asia/Riyadh', 'umm'),
  City('السعودية', 'المدينة المنورة', 24.4709, 39.6122, 'Asia/Riyadh', 'umm'),
  City('السعودية', 'الرياض', 24.7136, 46.6753, 'Asia/Riyadh', 'umm'),
  City('الإمارات', 'دبي', 25.2048, 55.2708, 'Asia/Dubai', 'mwl'),
  City('الكويت', 'الكويت', 29.3759, 47.9774, 'Asia/Kuwait', 'mwl'),
  City('قطر', 'الدوحة', 25.2854, 51.5310, 'Asia/Qatar', 'mwl'),
  City('الأردن', 'عمّان', 31.9454, 35.9284, 'Asia/Amman', 'mwl'),
  City('فلسطين', 'القدس', 31.7683, 35.2137, 'Asia/Jerusalem', 'mwl'),
  City('لبنان', 'بيروت', 33.8938, 35.5018, 'Asia/Beirut', 'mwl'),
  City('سوريا', 'دمشق', 33.5138, 36.2765, 'Asia/Damascus', 'mwl'),
  City('العراق', 'بغداد', 33.3152, 44.3661, 'Asia/Baghdad', 'mwl'),
  City('اليمن', 'صنعاء', 15.3694, 44.1910, 'Asia/Aden', 'mwl'),
  City('السودان', 'الخرطوم', 15.5007, 32.5599, 'Africa/Khartoum', 'egy'),
  City('ليبيا', 'طرابلس', 32.8872, 13.1913, 'Africa/Tripoli', 'mwl'),
  City('تونس', 'تونس', 36.8065, 10.1815, 'Africa/Tunis', 'mwl'),
  City('الجزائر', 'الجزائر', 36.7538, 3.0588, 'Africa/Algiers', 'mwl'),
  City('المغرب', 'الرباط', 34.0209, -6.8416, 'Africa/Casablanca', 'mwl'),
  City('تركيا', 'إسطنبول', 41.0082, 28.9784, 'Europe/Istanbul', 'mwl'),
  City('بريطانيا', 'لندن', 51.5074, -0.1278, 'Europe/London', 'mwl'),
  City('فرنسا', 'باريس', 48.8566, 2.3522, 'Europe/Paris', 'mwl'),
  City('أمريكا', 'نيويورك', 40.7128, -74.0060, 'America/New_York', 'mwl'),
];

class Dhikr {
  final String text;
  final int count;
  const Dhikr(this.text, this.count);
}

const adhkarData = <String, List<Dhikr>>{
  'أذكار الصباح': [
    Dhikr('أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ... (آية الكرسي)', 1),
    Dhikr('قُلْ هُوَ اللَّهُ أَحَدٌ ... (الإخلاص)', 3),
    Dhikr('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ... (الفلق)', 3),
    Dhikr('قُلْ أَعُوذُ بِرَبِّ النَّاسِ ... (الناس)', 3),
    Dhikr('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ', 1),
    Dhikr('اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ', 1),
    Dhikr('اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ', 1),
    Dhikr('بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ', 3),
    Dhikr('رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صلى الله عليه وسلم نَبِيًّا', 3),
    Dhikr('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100),
    Dhikr('أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', 100),
    Dhikr('لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ', 10),
  ],
  'أذكار المساء': [
    Dhikr('آية الكرسي', 1),
    Dhikr('الإخلاص والفلق والناس', 3),
    Dhikr('أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ', 1),
    Dhikr('اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ', 1),
    Dhikr('أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', 3),
    Dhikr('بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ', 3),
    Dhikr('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 100),
    Dhikr('اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ', 10),
  ],
  'أذكار بعد الصلاة': [
    Dhikr('أَسْتَغْفِرُ اللَّهَ', 3),
    Dhikr('اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ', 1),
    Dhikr('سُبْحَانَ اللَّهِ', 33),
    Dhikr('الْحَمْدُ لِلَّهِ', 33),
    Dhikr('اللَّهُ أَكْبَرُ', 33),
    Dhikr('لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ', 1),
    Dhikr('آية الكرسي', 1),
  ],
  'أذكار النوم': [
    Dhikr('بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', 1),
    Dhikr('الإخلاص والفلق والناس (ينفث في كفيه ويمسح جسده)', 3),
    Dhikr('سُبْحَانَ اللَّهِ', 33),
    Dhikr('الْحَمْدُ لِلَّهِ', 33),
    Dhikr('اللَّهُ أَكْبَرُ', 34),
  ],
  'أذكار متفرقة': [
    Dhikr('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 10),
    Dhikr('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ', 10),
    Dhikr('اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي', 10),
    Dhikr('رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ', 3),
  ],
};

const reciters = <String, String>{
  'مشاري العفاسي': 'https://server8.mp3quran.net/afs/',
  'محمود خليل الحصري': 'https://server13.mp3quran.net/husr/',
  'محمد صديق المنشاوي': 'https://server10.mp3quran.net/minsh/',
  'عبد الباسط عبد الصمد': 'https://server7.mp3quran.net/basit/',
  'سعود الشريم': 'https://server7.mp3quran.net/shur/',
};

CalculationParameters paramsFor(City c) {
  switch (c.method) {
    case 'umm':
      return CalculationMethod.umm_al_qura.getParameters();
    case 'egy':
      return CalculationMethod.egyptian.getParameters();
    default:
      return CalculationMethod.muslim_world_league.getParameters();
  }
}

Map<String, tz.TZDateTime> timesFor(City c, tz.TZDateTime day) {
  final loc = tz.getLocation(c.tzName);
  final pt = PrayerTimes(Coordinates(c.lat, c.lng),
      DateComponents(day.year, day.month, day.day), paramsFor(c));
  tz.TZDateTime t(DateTime d) => tz.TZDateTime.from(d.toUtc(), loc);
  return {
    'الفجر': t(pt.fajr),
    'الشروق': t(pt.sunrise),
    'الظهر': t(pt.dhuhr),
    'العصر': t(pt.asr),
    'المغرب': t(pt.maghrib),
    'العشاء': t(pt.isha),
  };
}

String fmt(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'ص' : 'م'}';
}

const _months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const _days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

String gregorianText(DateTime d) => '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year} م';

String hijriText(DateTime d) {
  HijriCalendar.setLocal('ar');
  final h = HijriCalendar.fromDate(d);
  return '${h.hDay} ${h.longMonthName} ${h.hYear} هـ';
}

bool isRamadan(DateTime d) => HijriCalendar.fromDate(d).hMonth == 9;

final np = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  await np.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ));
  final a = np.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await a?.requestNotificationsPermission();
  await a?.requestExactAlarmsPermission();
}

NotificationDetails _details(String channel, String name) => NotificationDetails(
      android: AndroidNotificationDetails(
        channel, name,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: const DarwinNotificationDetails(presentSound: true),
    );

Future<void> _sched(int id, String title, String body, tz.TZDateTime when, String ch, String chName) async {
  await np.zonedSchedule(
    id, title, body, when, _details(ch, chName),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Future<void> scheduleAll(City c, bool adhkarOn) async {
  await np.cancelAll();
  final loc = tz.getLocation(c.tzName);
  final now = tz.TZDateTime.now(loc);
  int id = 1;
  for (int d = 0; d < 7; d++) {
    final day = tz.TZDateTime(loc, now.year, now.month, now.day + d);
    final times = timesFor(c, day);
    for (final e in times.entries) {
      if (e.key == 'الشروق') continue;
      final alert = e.value.subtract(const Duration(minutes: 2));
      if (alert.isAfter(now)) {
        await _sched(id++, 'باقي دقيقتين على صلاة ${e.key} 🤍',
            'استعد للصلاة يا غالي، حيّ على الفلاح 🌸', alert, 'prayer_alert', 'تنبيه الصلاة');
      }
    }
    if (isRamadan(day)) {
      final suhoor = times['الفجر']!.subtract(const Duration(minutes: 45));
      if (suhoor.isAfter(now)) {
        await _sched(id++, 'السحور 🌙', 'باقي ٤٥ دقيقة على أذان الفجر', suhoor, 'ramadan', 'رمضان');
      }
      final iftar = times['المغرب']!.subtract(const Duration(minutes: 10));
      if (iftar.isAfter(now)) {
        await _sched(id++, 'اقترب الإفطار 🌙', 'باقي ١٠ دقائق على أذان المغرب، تقبل الله صيامك', iftar, 'ramadan', 'رمضان');
      }
    }
    if (adhkarOn) {
      final morning = tz.TZDateTime(loc, day.year, day.month, day.day, 6, 0);
      final evening = tz.TZDateTime(loc, day.year, day.month, day.day, 17, 0);
      if (morning.isAfter(now)) {
        await _sched(id++, 'أذكار الصباح ☀️', 'اذكر الله يذكرك', morning, 'adhkar', 'الأذكار');
      }
      if (evening.isAfter(now)) {
        await _sched(id++, 'أذكار المساء 🌙', 'حان وقت أذكار المساء', evening, 'adhkar', 'الأذكار');
      }
    }
  }
}

class Settings extends ChangeNotifier {
  int cityIndex = 0;
  bool adhkarOn = true;
  int reciterIndex = 0;
  late SharedPreferences _p;

  City get city => cities[cityIndex];

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    cityIndex = _p.getInt('city') ?? 0;
    adhkarOn = _p.getBool('adhkar') ?? true;
    reciterIndex = _p.getInt('reciter') ?? 0;
  }

  Future<void> save() async {
    await _p.setInt('city', cityIndex);
    await _p.setBool('adhkar', adhkarOn);
    await _p.setInt('reciter', reciterIndex);
    notifyListeners();
    await scheduleAll(city, adhkarOn);
  }
}

final settings = Settings();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  await settings.load();
  await initNotifications();
  await scheduleAll(settings.city, settings.adhkarOn);
  runApp(const SakinaApp());
}

class SakinaApp extends StatelessWidget {
  const SakinaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سكينة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPink, secondary: kPurple, tertiary: kBrown),
        scaffoldBackgroundColor: kCream,
      ),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const PrayerPage(), const AdhkarPage(), const QuranPage(), const SettingsPage()];
    return Scaffold(
      body: SafeArea(child: pages[i]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        indicatorColor: kPink.withOpacity(.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mosque_outlined), label: 'الصلاة'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'الأذكار'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'المصحف'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});
  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    settings.addListener(_r);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _r());
  }

  void _r() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    settings.removeListener(_r);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = settings.city;
    final loc = tz.getLocation(c.tzName);
    final now = tz.TZDateTime.now(loc);
    final today = tz.TZDateTime(loc, now.year, now.month, now.day);
    final times = timesFor(c, today);
    final prayerNames = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];

    String nextName = 'الفجر';
    tz.TZDateTime nextTime;
    final upcoming = prayerNames.where((n) => times[n]!.isAfter(now)).toList();
    if (upcoming.isNotEmpty) {
      nextName = upcoming.first;
      nextTime = times[nextName]!;
    } else {
      nextTime = timesFor(c, tz.TZDateTime(loc, now.year, now.month, now.day + 1))['الفجر']!;
    }
    final diff = nextTime.difference(now);
    String two(int n) => n.toString().padLeft(2, '0');
    final countdown = '${two(diff.inHours)}:${two(diff.inMinutes % 60)}:${two(diff.inSeconds % 60)}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(colors: [kPink, kPurple, kBrown], begin: Alignment.topRight, end: Alignment.bottomLeft),
          ),
          child: Column(children: [
            Text('سكينة 🌸', style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 18)),
            const SizedBox(height: 6),
            Text(fmt(now), style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
            Text(gregorianText(now), style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(hijriText(now), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${c.country} - ${c.name}', style: const TextStyle(color: Colors.white70)),
            if (isRamadan(now))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('🌙 رمضان كريم', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            const Divider(color: Colors.white38, height: 24),
            Text('الصلاة القادمة: $nextName', style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text(countdown, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 14),
        ...times.entries.map((e) {
          final isNext = e.key == nextName;
          return Card(
            color: isNext ? kPink.withOpacity(.15) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: isNext ? kPink : kPurple.withOpacity(.15)),
            ),
            child: ListTile(
              leading: Icon(e.key == 'الشروق' ? Icons.wb_sunny_outlined : Icons.access_time_filled, color: isNext ? kPink : kPurple),
              title: Text(e.key, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: isNext ? kPink : kBrown)),
              trailing: Text(fmt(e.value), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ),
          );
        }),
      ],
    );
  }
}

class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});
  @override
  Widget build(BuildContext context) {
    final keys = adhkarData.keys.toList();
    final colors = [kPink, kPurple, kBrown, const Color(0xFFB04A8F), const Color(0xFF9C6BCF)];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (_, i) => Card(
        color: colors[i % colors.length],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          title: Text(keys[i], style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.chevron_left, color: Colors.white),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DhikrListPage(title: keys[i], items: adhkarData[keys[i]]!))),
        ),
      ),
    );
  }
}

class DhikrListPage extends StatefulWidget {
  final String title;
  final List<Dhikr> items;
  const DhikrListPage({super.key, required this.title, required this.items});
  @override
  State<DhikrListPage> createState() => _DhikrListPageState();
}

class _DhikrListPageState extends State<DhikrListPage> {
  late List<int> left = widget.items.map((e) => e.count).toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: kPurple, foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: widget.items.length,
        itemBuilder: (_, i) {
          final done = left[i] == 0;
          return GestureDetector(
            onTap: () => setState(() { if (left[i] > 0) left[i]--; }),
            child: Card(
              color: done ? Colors.green.shade50 : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: done ? Colors.green : kPink.withOpacity(.4))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text(widget.items[i].text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, height: 1.9, color: kBrown)),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    backgroundColor: done ? Colors.green : kPink,
                    child: done ? const Icon(Icons.check, color: Colors.white) : Text('${left[i]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: quran.totalSurahCount,
      itemBuilder: (_, i) {
        final n = i + 1;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: i.isEven ? kPink : kPurple, child: Text('$n', style: const TextStyle(color: Colors.white))),
            title: Text('سورة ${quran.getSurahNameArabic(n)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kBrown)),
            subtitle: Text('${quran.getVerseCount(n)} آية - ${quran.getPlaceOfRevelation(n) == 'Makkah' ? 'مكية' : 'مدنية'}'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahPage(number: n))),
          ),
        );
      },
    );
  }
}

class SurahPage extends StatefulWidget {
  final int number;
  const SurahPage({super.key, required this.number});
  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  final player = AudioPlayer();
  int reciter = settings.reciterIndex;
  bool loading = false;

  Future<void> play() async {
    setState(() => loading = true);
    try {
      final base = reciters.values.elementAt(reciter);
      final file = widget.number.toString().padLeft(3, '0');
      await player.setAudioSource(LockCachingAudioSource(Uri.parse('$base$file.mp3')));
      player.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('محتاج نت أول مرة لتحميل صوت هذه السورة')));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.number;
    final verses = List.generate(quran.getVerseCount(n), (i) => quran.getVerse(n, i + 1, verseEndSymbol: true));
    return Scaffold(
      appBar: AppBar(title: Text('سورة ${quran.getSurahNameArabic(n)}'), backgroundColor: kPink, foregroundColor: Colors.white),
      body: Column(children: [
        Container(
          color: kPurple.withOpacity(.1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            Expanded(
              child: DropdownButton<int>(
                value: reciter,
                isExpanded: true,
                items: [for (int i = 0; i < reciters.length; i++) DropdownMenuItem(value: i, child: Text(reciters.keys.elementAt(i)))],
                onChanged: (v) => setState(() => reciter = v!),
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (_, snap) {
                final playing = snap.data?.playing ?? false;
                if (loading) return const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)));
                return IconButton(
                  iconSize: 38,
                  color: kPink,
                  icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                  onPressed: () => playing ? player.pause() : (player.audioSource == null ? play() : player.play()),
                );
              },
            ),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              if (n != 1 && n != 9)
                Center(child: Text(quran.basmala, style: const TextStyle(fontSize: 26, color: kPurple, height: 2))),
              Text(verses.join(' '), textAlign: TextAlign.justify, style: const TextStyle(fontSize: 26, height: 2.2, color: kBrown)),
            ],
          ),
        ),
      ]),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('الإعدادات', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kBrown)),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('الدولة / المدينة', style: TextStyle(fontWeight: FontWeight.bold, color: kPurple)),
            DropdownButton<int>(
              value: settings.cityIndex,
              isExpanded: true,
              items: [for (int i = 0; i < cities.length; i++) DropdownMenuItem(value: i, child: Text('${cities[i].country} - ${cities[i].name}'))],
              onChanged: (v) async {
                settings.cityIndex = v!;
                await settings.save();
                setState(() {});
              },
            ),
          ]),
        ),
      ),
      Card(
        child: SwitchListTile(
          activeColor: kPink,
          title: const Text('تنبيه الأذكار (الصباح ٦ ص / المساء ٥ م)'),
          value: settings.adhkarOn,
          onChanged: (v) async {
            settings.adhkarOn = v;
            await settings.save();
            setState(() {});
          },
        ),
      ),
      const Card(
        child: ListTile(
          leading: Icon(Icons.notifications_active, color: kPink),
          title: Text('تنبيه قبل كل صلاة بدقيقتين'),
          subtitle: Text('شغّال دايمًا. وفي رمضان: تنبيه السحور والإفطار تلقائيًا.'),
        ),
      ),
      const Card(
        child: ListTile(
          leading: Icon(Icons.access_time, color: kPurple),
          title: Text('التوقيت الصيفي والشتوي'),
          subtitle: Text('بيتظبط تلقائيًا حسب قاعدة بيانات المناطق الزمنية لكل دولة، من غير نت.'),
        ),
      ),
    ]);
  }
}
