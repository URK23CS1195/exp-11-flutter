import 'package:flutter/material.dart';

// ---------- THEME COLORS ----------
const Color bg = Color(0xFF0B0F1E);
const Color cardColor = Color(0xFF161B33);
const Color borderColor = Color(0xFF272D52);
const Color muted = Color(0xFF9AA0C3);
const Color violet = Color(0xFF6C63FF);
const Color cyan = Color(0xFF22D3EE);
const Color pink = Color(0xFFEC4899);
const Color green = Color(0xFF4ADE80);

Color alpha(Color c, double o) => c.withAlpha((o * 255).round());

BoxDecoration panel() => BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: borderColor),
    );

// Shared between tabs (text field -> greeting everywhere)
final ValueNotifier<String> userName = ValueNotifier<String>('');

void main() => runApp(const IosTestApp());

class IosTestApp extends StatelessWidget {
  const IosTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Test App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: violet,
        scaffoldBackgroundColor: bg,
      ),
      home: const AppShell(),
    );
  }
}

// ---------- SCREEN TRANSITIONS ----------
Route<void> slideRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(offset),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

Route<void> fadeScaleRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final scale = Tween<double>(begin: 0.92, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation.drive(scale), child: child),
      );
    },
  );
}

// ---------- SHELL WITH BOTTOM TAB BAR ----------
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeTab(),
          GalleryTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: cardColor,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library_rounded),
              label: 'Gallery'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------- SHARED HEADER ----------
class GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const GradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.colors = const [violet, Color(0xFF8E54E9), cyan],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: TextStyle(color: alpha(Colors.white, 0.85))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: alpha(Colors.white, 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// TAB 1: HOME  (text field, buttons, checklist, navigation)
// =====================================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController nameCtrl = TextEditingController();
  int counter = 0;

  final Map<String, bool> checklist = {
    'UI looks correct': false,
    'Navigation works': false,
    'Text fields work': false,
    'Buttons respond': false,
    'Images load': false,
    'Screen transitions': false,
  };

  int get done => checklist.values.where((v) => v).length;

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  void openAbout() {
    final name = nameCtrl.text.trim().isEmpty ? 'Guest' : nameCtrl.text.trim();
    Navigator.push(context, slideRoute(AboutScreen(name: name, taps: counter)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          ValueListenableBuilder<String>(
            valueListenable: userName,
            builder: (context, name, _) {
              return GradientHeader(
                title: name.isEmpty ? 'Hello, Guest' : 'Hello, $name',
                subtitle: 'Flutter app running as an iOS build target',
                icon: Icons.phone_iphone_rounded,
              );
            },
          ),
          const SizedBox(height: 20),

          // ---- TEXT FIELD ----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: panel(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Text field',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onChanged: (v) => userName.value = v.trim(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- BUTTONS ----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: panel(),
            child: Column(
              children: [
                const Text('Buttons',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    '$counter',
                    key: ValueKey<int>(counter),
                    style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w800,
                        color: cyan),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => setState(() => counter--),
                      icon: const Icon(Icons.remove),
                      label: const Text('Minus'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => setState(() => counter++),
                      icon: const Icon(Icons.add),
                      label: const Text('Plus'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(() => counter = 0),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- TEST CHECKLIST ----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: panel(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Test checklist',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    Text('$done / ${checklist.length}',
                        style: const TextStyle(color: green)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                        begin: 0, end: done / checklist.length),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      color: green,
                      backgroundColor: alpha(Colors.white, 0.08),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...checklist.keys.map((k) {
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(k),
                    value: checklist[k],
                    onChanged: (v) =>
                        setState(() => checklist[k] = v ?? false),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- NAVIGATION ----
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: openAbout,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Open details screen'),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SECOND SCREEN (pushed with a slide + fade transition)
// =====================================================================
class AboutScreen extends StatelessWidget {
  final String name;
  final int taps;

  const AboutScreen({super.key, required this.name, required this.taps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientHeader(
                title: 'Welcome, $name',
                subtitle: 'You pressed the buttons $taps time(s).',
                icon: Icons.check_circle_rounded,
                colors: const [pink, Color(0xFFF97316)],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: panel(),
                child: const Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.text_fields, color: cyan),
                      title: Text('Text field'),
                      subtitle: Text('Your name was passed to this screen'),
                    ),
                    ListTile(
                      leading: Icon(Icons.touch_app, color: green),
                      title: Text('Buttons'),
                      subtitle: Text('The counter value was passed too'),
                    ),
                    ListTile(
                      leading: Icon(Icons.swap_horiz, color: pink),
                      title: Text('Screen transition'),
                      subtitle: Text('Slide + fade animation'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// TAB 2: GALLERY  (images, Hero transition)
// =====================================================================
const List<int> photoIds = [1015, 1018, 1025, 1039, 1043, 1062];
const List<String> photoNames = [
  'Mountain lake',
  'River valley',
  'Puppy',
  'Waterfall',
  'Forest path',
  'Golden retriever',
];

Widget networkPhoto(int id, {double? height}) {
  return Image.network(
    'https://picsum.photos/id/$id/600/600',
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(
        height: height,
        color: cardColor,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    },
    // Fallback if the network image cannot load
    errorBuilder: (context, error, stack) => Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [violet, cyan]),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: Colors.white),
      ),
    ),
  );
}

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const GradientHeader(
            title: 'Gallery',
            subtitle: 'Tap a photo to open it with a Hero animation',
            icon: Icons.photo_library_rounded,
            colors: [Color(0xFF0EA5E9), cyan, green],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: photoIds.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  fadeScaleRoute(PhotoScreen(index: i)),
                ),
                child: Hero(
                  tag: 'photo_${photoIds[i]}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: networkPhoto(photoIds[i]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PhotoScreen extends StatefulWidget {
  final int index;
  const PhotoScreen({super.key, required this.index});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    final id = photoIds[widget.index];
    return Scaffold(
      appBar: AppBar(
        title: Text(photoNames[widget.index]),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Hero(
                tag: 'photo_$id',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: networkPhoto(id, height: 340),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(photoNames[widget.index],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    iconSize: 32,
                    onPressed: () => setState(() => liked = !liked),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey<bool>(liked),
                        color: liked ? pink : muted,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to gallery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// TAB 3: PROFILE  (more text fields, switch, slider)
// =====================================================================
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  bool notifications = true;
  bool darkMode = true;
  double level = 0.6;

  @override
  void dispose() {
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  void save() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Saved: ${emailCtrl.text.isEmpty ? "no email" : emailCtrl.text}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          ValueListenableBuilder<String>(
            valueListenable: userName,
            builder: (context, name, _) {
              return GradientHeader(
                title: name.isEmpty ? 'Guest profile' : name,
                subtitle: 'Edit your details below',
                icon: Icons.person_rounded,
                colors: const [pink, violet],
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: panel(),
            child: Column(
              children: [
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: panel(),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications'),
                  secondary: const Icon(Icons.notifications_none_rounded),
                  value: notifications,
                  onChanged: (v) => setState(() => notifications = v),
                ),
                SwitchListTile(
                  title: const Text('Dark mode'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: darkMode,
                  onChanged: (v) => setState(() => darkMode = v),
                ),
                ListTile(
                  leading: const Icon(Icons.volume_up_outlined),
                  title: Text('Volume ${(level * 100).round()}%'),
                  subtitle: Slider(
                    value: level,
                    onChanged: (v) => setState(() => level = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save profile'),
            ),
          ),
        ],
      ),
    );
  }
}