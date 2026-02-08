import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(const FineEntryApp());
}

class FineEntryApp extends StatelessWidget {
  const FineEntryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traffic Fines',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4ECDC4),
          secondary: Color(0xFF6EE2D9),
        ),
      ),
      home: ViewFineEntryPage(id: "1"),
    );
  }
}

class ViewFineEntryPage extends StatefulWidget {
  final String id;
  const ViewFineEntryPage({super.key, required this.id});

  @override
  State<ViewFineEntryPage> createState() => _ViewFineEntryPageState();
}

class _ViewFineEntryPageState extends State<ViewFineEntryPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> fines = [];
  bool isLoading = true;
  late Razorpay _razorpay;
  late AnimationController _successController;
  bool showSuccess = false;

  // Eye-Friendly Light Theme Colors (Same as all other screens)
  static const Color bgStart = Color(0xFFE8F5FF);
  static const Color bgEnd = Color(0xFFF5F9FF);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF9BE5E0);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xFF2D3748);
  static const Color textMuted = Color(0xFF718096);
  static const Color success = Color(0xFF48BB78);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF6AD55);
  static const Color shadowColor = Color(0x338EC8E6);

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _successController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _loadFines();
  }

  Future<void> _loadFines() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? imgUrl = sh.getString('img_url');

      if (url == null) return;

      var response = await http.post(
        Uri.parse('$url/user_viewfineentryandpay_post/'),
        body: {'vid': widget.id},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'ok') {
          List<Map<String, dynamic>> temp = [];
          for (var item in data['data']) {
            temp.add({
              'id': item['id'],
              'photo': (imgUrl ?? '') + (item['photo'] ?? ''),
              'date': item['date'] ?? 'N/A',
              'time': item['time'] ?? 'N/A',
              'fine': item['fine'] ?? '0',
              'status': item['status'] ?? 'Pending',
            });
          }
          setState(() {
            fines = temp;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  void _openCheckout(int amount, String fineId) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    await sh.setString("fine_id", fineId);

    var options = {
      'key': 'rzp_test_HKCAwYtLt0rwQe',
      'amount': amount * 100,
      'name': 'Traffic Fine Payment',
      'description': 'Pay your traffic violation fine',
      'prefill': {
        'contact': '9497127407',
        'email': 'user@example.com',
      },
      'theme': {'color': '#4ECDC4'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? fineId = sh.getString("fine_id");

    if (url == null || fineId == null) return;

    var request = http.MultipartRequest('POST', Uri.parse('$url/user_pay/'));
    request.fields['id'] = fineId;

    try {
      var resp = await request.send();
      var respStr = await resp.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (resp.statusCode == 200 && data['status'] == 'ok') {
        setState(() => showSuccess = true);
        _successController.forward();
        Fluttertoast.showToast(
          msg: "Payment Successful!",
          backgroundColor: success,
          textColor: Colors.white,
        );
        await Future.delayed(const Duration(seconds: 2));
        setState(() => showSuccess = false);
        _loadFines();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating payment");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment failed: ${response.message}", backgroundColor: danger);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "Paid via ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textMain,
        title: const Text("Traffic Fines", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21, letterSpacing: 1)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh_rounded, color: accent), onPressed: _loadFines),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              isLoading
                  ? Center(child: CircularProgressIndicator(color: accent, strokeWidth: 4))
                  : fines.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: _loadFines,
                color: accent,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: fines.length,
                  itemBuilder: (context, index) {
                    final fine = fines[index];
                    bool isPaid = fine['status'].toString().toLowerCase() == 'paid';

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isPaid ? success.withOpacity(0.5) : danger.withOpacity(0.5),
                          width: 2.5,
                        ),
                        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 22, offset: const Offset(0, 10))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Violation Photo
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                fine['photo'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: accent.withOpacity(0.15),
                                  child: Icon(Icons.camera_alt_rounded, size: 50, color: accent),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 20, color: accent),
                                      const SizedBox(width:8),
                                      Text(fine['date'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textMain)),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isPaid ? success : danger,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          fine['status'].toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _infoRow(Icons.access_time_rounded, fine['time']),
                                  _infoRow(Icons.currency_rupee_rounded, "₹${fine['fine']}", color: danger),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: isPaid
                                          ? null
                                          : () => _openCheckout(int.parse(fine['fine']), fine['id'].toString()),
                                      icon: isPaid
                                          ? const Icon(Icons.check_circle_rounded, size: 22)
                                          : const Icon(Icons.payment_rounded, size: 22),
                                      label: Text(
                                        isPaid ? "Already Paid" : "Pay Now ₹${fine['fine']}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isPaid ? Colors.grey.shade400 : accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        elevation: isPaid ? 0 : 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Success Animation Overlay
              if (showSuccess)
                Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Center(
                    child: ScaleTransition(
                      scale: CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 140, color: success),
                          const SizedBox(height: 28),
                          const Text(
                            "Payment Successful!",
                            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          const Text("Your fine has been cleared", style: TextStyle(fontSize: 18, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_very_satisfied_rounded, size: 120, color: accent.withOpacity(0.7)),
          const SizedBox(height: 28),
          const Text(
            "No Fines Found",
            style: TextStyle(fontSize: 28, color: textMain, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Text("Great! You're a law-abiding driver", style: TextStyle(color: textMuted, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? accent),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 15.5, color: textMain, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}