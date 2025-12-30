import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'login_page.dart';
import 'admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const AbhilekhApp());
}

class AbhilekhApp extends StatelessWidget {
  const AbhilekhApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Abhilekh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasData) return const MainPage();
        return const LoginPage();
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const PunchPage(), const ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 400), child: _pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sensors_rounded), label: 'Punch'),
          NavigationDestination(icon: Icon(Icons.data_exploration_rounded), label: 'Activity'),
        ],
      ),
    );
  }
}

class PunchPage extends StatefulWidget {
  const PunchPage({super.key});
  @override
  State<PunchPage> createState() => _PunchPageState();
}

class _PunchPageState extends State<PunchPage> with SingleTickerProviderStateMixin {
  final NetworkInfo _networkInfo = NetworkInfo();
  bool _isProcessing = false;
  final String authorizedBSSID = "f0:ed:b8:ad:5f:e5";

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePunch() async {
    if (kIsWeb) return;

    var status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission required")));
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      String? currentBSSID = await _networkInfo.getWifiBSSID();

      if (currentBSSID != null && currentBSSID.toLowerCase() == authorizedBSSID.toLowerCase()) {
        final user = FirebaseAuth.instance.currentUser;
        final lastLog = await FirebaseFirestore.instance
            .collection('logs')
            .where('email', isEqualTo: user?.email)
            .orderBy('timestamp', descending: true)
            .limit(1).get();

        String pStatus = (lastLog.docs.isNotEmpty && lastLog.docs.first['status'] == "Entry") ? "Exit" : "Entry";

        await FirebaseFirestore.instance.collection('logs').add({
          'email': user?.email,
          'timestamp': FieldValue.serverTimestamp(),
          'status': pStatus,
          'bssid': currentBSSID,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$pStatus Confirmed")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Access Denied: Not at authorized gate. Current BSSID: $currentBSSID")));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(backgroundColor: Colors.transparent, actions: [
        IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () => FirebaseAuth.instance.signOut())
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Text("Abhilekh", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const Text("Smart Gate Access", style: TextStyle(color: Colors.grey)),
            const Spacer(),
            Center(
              child: _isProcessing ? const CircularProgressIndicator() : GestureDetector(
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) { _controller.reverse(); _handlePunch(); },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 240, height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.indigo.shade800]),
                      boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 20))],
                    ),
                    child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 80),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Color(0xFFF8FAFF),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Activity History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20)),
              titlePadding: EdgeInsets.only(left: 24, bottom: 16),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('logs').where('email', isEqualTo: user?.email).orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              final docs = snapshot.data!.docs;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final bool isEntry = data['status'] == "Entry";
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Container(width: 2, height: 20, color: index == 0 ? Colors.transparent : Colors.grey.shade300),
                                  Container(
                                    width: 14, height: 14,
                                    decoration: BoxDecoration(
                                      color: isEntry ? Colors.green.shade400 : Colors.orange.shade400,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                  ),
                                  Expanded(child: Container(width: 2, color: index == docs.length - 1 ? Colors.transparent : Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['status'] ?? "Entry", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                      Text("${date.hour}:${date.minute.toString().padLeft(2, '0')} • ${date.day}/${date.month}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}