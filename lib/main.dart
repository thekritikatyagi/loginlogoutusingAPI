import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IDEXCH Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController(text: '46161637');
  final TextEditingController _passwordController = TextEditingController(text: '1234567');
  final TextEditingController _captchaController = TextEditingController();

  bool _isLoading = false;
  bool _biometricFailed = false;
  bool _showPassword = false;
  bool _expired = false;
  Timer? _expireTimer;
  int _remainingTime = 600; // Increased to 600 seconds
  String _captchaCode = '';

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
    _startExpireTimer();
  }

  void _generateCaptcha() {
    final random = Random();
    _captchaCode = (1000 + random.nextInt(9000)).toString();
  }

  void _refreshCaptcha() {
    setState(() {
      _generateCaptcha();
      _captchaController.clear();
    });
  }

  void _startExpireTimer() {
    _remainingTime = 600; // Reset to 600 seconds
    _expired = false;
    _expireTimer?.cancel();
    
    _expireTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _expired = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _expireTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6A1B9A),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('BACKUP', style: TextStyle(color: Colors.white)),
                      Switch(value: true, onChanged: (_) {}),
                    ],
                  ),
                ),
                SizedBox(height: 35),
                Text('iDX', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.yellow)),
                Text('IDEXCH', style: TextStyle(fontSize: 24, color: Colors.white, letterSpacing: 2)),
                SizedBox(height: 32),
                
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: _expired
                      ? Text('Login time expired',
                          style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold))
                      : Text('Time remaining: ${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.lightGreen, fontSize: 18, fontWeight: FontWeight.bold),
                        ),

                ),
                
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter username' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter password' : null,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _captchaController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Enter Captcha',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white.withOpacity(0.1),
                          filled: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter captcha';
                          if (value != _captchaCode) return 'Invalid captcha';
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_captchaCode, 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.white),
                            onPressed: _refreshCaptcha,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (_biometricFailed)
                  Text('Biometric authentication failed.',
                      style: TextStyle(color: Colors.red)),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: (_isLoading || _expired) ? null : _handleLogin,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('LOGIN', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 150, vertical: 16),
                    backgroundColor: Colors.orange,
                    side: BorderSide(color: Colors.red),
                  ),
                ),
                SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: (_expired) ? null : _handleFingerprintLogin,
                  icon: Icon(Icons.fingerprint, color: Colors.white),
                  label: Text('Login with fingerprint', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                   
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Set expiry time to 10 minutes from now
        DateTime expiryTime = DateTime.now().add(Duration(minutes: 10));
        
        final response = await http.post(
          Uri.parse('https://www.xch99.com/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': _usernameController.text,
            'password': _passwordController.text,
            'captcha': _captchaController.text,
            'expireTime': expiryTime.toIso8601String(), 
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.body}')),
          );
          _startExpireTimer(); // Reset timer on failed login
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        _startExpireTimer(); // Reset timer on error
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleFingerprintLogin() async {
    setState(() => _biometricFailed = false);
    await Future.delayed(Duration(seconds: 1));
    if (DateTime.now().second % 3 == 0) {
      setState(() => _biometricFailed = true);
    } else {
      _handleLogin();
    }
  }

}

class HomePage extends StatelessWidget {
  void _handleLogout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // First try the API logout
        final response = await http.post(
          Uri.parse('https://www.xch99.com/api/logout'),
          headers: {'Content-Type': 'application/json'},
        );
  
        // Check if response is HTML redirect
        if (response.body.contains('<!DOCTYPE html>') || 
            response.statusCode == 302) {
          // Handle the redirect case - just navigate to login page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } 
        // Handle successful JSON response (if API changes in future)
        else if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } 
        // Handle other cases
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout completed')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } catch (e) {
        // Even if error occurs, still navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IDEXCH'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Logged In Successfully',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Username: 46161637',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}