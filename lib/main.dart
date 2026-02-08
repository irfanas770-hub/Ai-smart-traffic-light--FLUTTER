import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Server Setup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const IPSetupPage(),
    );
  }
}

class IPSetupPage extends StatefulWidget {
  const IPSetupPage({super.key});

  @override
  State<IPSetupPage> createState() => _IPSetupPageState();
}

class _IPSetupPageState extends State<IPSetupPage> {
  final TextEditingController _ipController = TextEditingController();
  bool _isLoading = false;
  bool _isValid = true;

  // Simple IP validation (basic check)
  bool _validateIP(String ip) {
    final regex = RegExp(r'^((\d{1,3})\.){3}(\d{1,3})$');
    if (!regex.hasMatch(ip)) return false;
    final parts = ip.split('.').map(int.tryParse).toList();
    return parts.every((part) => part != null && part >= 0 && part <= 255);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 25,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon / Logo Area
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.settings_ethernet,
                          size: 60,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        "Connect to Server",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your local server IP address to continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // IP Input Field
                      TextField(
                        controller: _ipController,
                        keyboardType: TextInputType.numberWithOptions(decimal: false),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "192.168.1.100",
                          labelText: "Server IP Address",
                          prefixIcon: const Icon(Icons.computer, color: Colors.deepPurple),
                          suffixIcon: _ipController.text.isNotEmpty
                              ? Icon(
                            _isValid ? Icons.check_circle : Icons.error,
                            color: _isValid ? Colors.green : Colors.red,
                          )
                              : null,
                          filled: true,
                          fillColor: Colors.deepPurple.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.deepPurple.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isValid = _validateIP(value.trim());
                          });
                        },
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "Example: 192.168.43.10 or 10.0.2.2 (for emulator)",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),

                      const SizedBox(height: 40),

                      // Connect Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading || !_isValid
                              ? null
                              : () async {
                            setState(() => _isLoading = true);
                            await _saveAndProceed();
                            setState(() => _isLoading = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shadowColor: Colors.deepPurple.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Connect to Server",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndProceed() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty || !_validateIP(ip)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid IP address")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final baseUrl = 'http://$ip:8000/myapp';
    final imgUrl = 'http://$ip:8000';

    await prefs.setString('url', baseUrl);
    await prefs.setString('img_url', imgUrl);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Connected successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyLoginPage(title: "Login")),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}